defmodule Roughly.Dev.Seeds do
  @moduledoc """
  Repeatable development-only data written through Commanded.
  Stable IDs and read-side skip checks make reruns resumable; aggregate duplicate
  errors also protect against lagging projections. The dataset is not polling evidence.
  """
  import Ecto.Query
  alias Roughly.{Dispatch, Repo}
  alias Roughly.Access.Actor
  alias Roughly.Dev.{Identity, SeedCatalog}
  alias Roughly.Questions.Commands.CreateQuestion
  alias Roughly.Questions.Projections.Question
  alias Roughly.Identity.Commands.RegisterPrincipal
  alias Roughly.Identity.Projections.Principal
  alias Roughly.Participation.Commands.{RecordResponse, ChangeResponse}
  alias Roughly.Participation.Projections.Response

  @participants 360
  @metadata %{"source" => "development-fixtures", "dataset" => "roughly-v1"}

  def run do
    unless Application.get_env(:roughly, :allow_dev_seeds, false) do
      raise "Fixture seeding is restricted to an explicitly enabled development environment"
    end

    level = Logger.level()
    Logger.configure(level: :warning)

    try do
      questions = SeedCatalog.questions()

      principals =
        Enum.map(
          1..@participants,
          &%RegisterPrincipal{
            principal_uuid: Identity.uuid("participant:#{&1}")
          }
        )

      topic_count = questions |> Enum.map(& &1.category) |> Enum.uniq() |> length()

      IO.puts(
        "Seeding #{length(questions)} questions across #{topic_count} topics and #{@participants} participants..."
      )

      seed(Principal, principals, :principal_uuid, :principal_already_exists)

      seed(
        Question,
        Enum.map(questions, &question_command/1),
        :question_uuid,
        :question_already_exists
      )

      votes = Enum.flat_map(questions, &responses/1)
      seed(Response, votes, :response_uuid, :response_already_exists)

      await_projections(
        questions,
        principals,
        votes,
        System.monotonic_time(:millisecond) + 120_000
      )

      seed_revisions(questions)

      IO.puts(
        "Ready: #{length(questions)} questions, #{@participants} participants, #{length(votes)} responses. Rerunning preserves these counts."
      )

      %{questions: length(questions), participants: @participants, responses: length(votes)}
    after
      Logger.configure(level: level)
    end
  end

  def responses(question) do
    # A stable range of participation levels, including a few unanswered questions.
    total =
      if :erlang.phash2(question.slug, 31) == 0,
        do: 0,
        else: 24 + :erlang.phash2(question.slug, 277)

    indices = if total == 0, do: [], else: Enum.to_list(1..total)

    indices =
      if question.slug == "how-do-you-usually-take-your-coffee",
        do: Enum.to_list(1..@participants),
        else: indices

    indices =
      if question.category == "About you",
        do: Enum.reject(1..@participants, &(rem(&1, 19) == 0)),
        else: indices

    Enum.map(indices, &response_for(question, &1))
  end

  defp response_for(question, index) do
    bucket = :erlang.phash2({question.slug, index}, 100)
    weights = fixture_weights(question, index)

    options =
      if Map.get(question, :question_type) == :multiple_select do
        selected =
          Enum.zip(question.options, weights)
          |> Enum.filter(fn {label, weight} ->
            :erlang.phash2({question.slug, index, label}, 100) < weight
          end)
          |> Enum.map(&elem(&1, 0))

        if selected == [], do: [List.last(question.options)], else: selected
      else
        [pick_option(Enum.zip(question.options, weights), bucket)]
      end

    %RecordResponse{
      response_uuid:
        Roughly.Participation.identity(question.uuid, Identity.uuid("participant:#{index}")),
      question_uuid: question.uuid,
      principal_uuid: Identity.uuid("participant:#{index}"),
      option_ids: Enum.map(options, &option_id(question, &1)),
      context: %Roughly.Participation.Context{
        mode: :development_fixture,
        answered_at: fixture_date(question, index),
        field_sources: %{answered_at: :inferred, mode: :observed},
        option_order: Enum.map(question.options, &option_id(question, &1))
      }
    }
  end

  defp fixture_date(%{category: "About you"}, _), do: ~U[2025-10-01 12:00:00Z]

  defp fixture_date(question, index),
    do:
      DateTime.add(
        ~U[2025-11-01 12:00:00Z],
        :erlang.phash2({question.slug, index, :date}, 365) * 86_400
      )

  defp fixture_weights(%{slug: "how-do-you-usually-take-your-coffee"} = question, index) do
    month = div(Date.diff(DateTime.to_date(fixture_date(question, index)), ~D[2025-11-01]), 31)

    young = :erlang.phash2({"which-age-group-are-you-in", index}, 100) < 36

    if young,
      do: [15 - month, 55 + month, 20, 10],
      else: [45 - month, 25 + month, 20, 10]
  end

  defp fixture_weights(question, _), do: question.weights

  defp seed_revisions(questions) do
    question = Enum.find(questions, &(&1.slug == "how-do-you-usually-take-your-coffee"))

    Enum.each(1..5, fn index ->
      original = response_for(question, index)
      id = original.response_uuid
      desired = [option_id(question, "With milk or cream")]
      current = Repo.get!(Response, id)

      if current.option_ids != desired do
        actor = Actor.principal(original.principal_uuid)

        command = %ChangeResponse{
          response_uuid: id,
          actor_uuid: actor.id,
          new_option_ids: desired,
          context: %Roughly.Participation.Context{
            mode: :development_fixture,
            answered_at: ~U[2026-11-01 12:00:00Z],
            field_sources: %{answered_at: :inferred}
          }
        }

        dispatch_revision(command, actor)

        await_revision(id, desired, System.monotonic_time(:millisecond) + 30_000)
      end
    end)
  end

  defp dispatch_revision(command, actor) do
    case Dispatch.dispatch(command, actor, metadata: @metadata) do
      :ok -> :ok
      {:error, :same_answer} -> :ok
      error -> raise "Fixture revision failed: #{inspect(error)}"
    end
  end

  defp await_revision(id, desired, deadline) do
    cond do
      Repo.get!(Response, id).option_ids == desired ->
        :ok

      System.monotonic_time(:millisecond) >= deadline ->
        raise "Fixture revision projection timed out"

      true ->
        Process.sleep(100)
        await_revision(id, desired, deadline)
    end
  end

  defp pick_option(options, bucket) do
    Enum.reduce_while(options, bucket, fn {option, weight}, remaining ->
      if remaining < weight, do: {:halt, option}, else: {:cont, remaining - weight}
    end)
  end

  defp option_id(question, label), do: Identity.uuid("option:#{question.uuid}:#{label}")

  defp question_command(question) do
    %CreateQuestion{
      question_uuid: question.uuid,
      text: question.text,
      category: question.category,
      options:
        Enum.map(question.options, &Roughly.Questions.Option.new(option_id(question, &1), &1)),
      question_type: question.question_type
    }
  end

  defp seed(schema, commands, identity_field, duplicate_error) do
    existing = schema |> select([row], row.uuid) |> Repo.all() |> MapSet.new()
    pending = Enum.reject(commands, &MapSet.member?(existing, Map.fetch!(&1, identity_field)))

    pending
    |> Enum.chunk_every(1000)
    |> Enum.with_index(1)
    |> Enum.each(fn {batch, index} ->
      batch
      |> Task.async_stream(
        fn command ->
          dispatch(command)
        end,
        timeout: :infinity,
        max_concurrency: 8,
        ordered: false
      )
      |> Enum.each(fn
        {:ok, :ok} -> :ok
        {:ok, {:error, ^duplicate_error}} -> :ok
        result -> raise "Development seeding failed: #{inspect(result)}"
      end)

      IO.puts(
        "  #{inspect(schema)}: #{min(index * 1000, length(pending))}/#{length(pending)} new records dispatched"
      )
    end)
  end

  defp dispatch(%CreateQuestion{} = command),
    do:
      Roughly.Questions.publish(Actor.system("development-fixtures"), command,
        metadata: @metadata
      )

  defp dispatch(command),
    do: Dispatch.dispatch(command, Actor.system("development-fixtures"), metadata: @metadata)

  defp await_projections(questions, principals, votes, deadline) do
    question_ids = Enum.map(questions, & &1.uuid)
    user_ids = Enum.map(principals, & &1.principal_uuid)

    ready? =
      Repo.aggregate(from(q in Question, where: q.uuid in ^question_ids), :count) ==
        length(questions) and
        Repo.aggregate(from(u in Principal, where: u.uuid in ^user_ids), :count) ==
          length(principals) and
        Repo.aggregate(from(v in Response, where: v.question_uuid in ^question_ids), :count) ==
          length(votes)

    cond do
      ready? ->
        :ok

      System.monotonic_time(:millisecond) >= deadline ->
        raise "Timed out waiting for development projections"

      true ->
        Process.sleep(200)
        await_projections(questions, principals, votes, deadline)
    end
  end
end
