defmodule Roughly.Dev.Seeds do
  @moduledoc """
  Repeatable development-only data written through Commanded.
  Stable IDs and read-side skip checks make reruns resumable; aggregate duplicate
  errors also protect against lagging projections. The dataset is not polling evidence.
  """
  import Ecto.Query
  alias Roughly.{App, Repo}
  alias Roughly.Dev.{Identity, SeedCatalog}
  alias Roughly.Questions.Commands.CreateQuestion
  alias Roughly.Questions.Projections.Question
  alias Roughly.Users.Commands.RegisterUser
  alias Roughly.Users.Projections.User
  alias Roughly.Voting.Commands.CastVote
  alias Roughly.Voting.Projections.Vote

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

      users =
        Enum.map(
          1..@participants,
          &%RegisterUser{
            user_uuid: Identity.uuid("participant:#{&1}"),
            email: "participant-#{&1}@roughly-seed.invalid"
          }
        )

      topic_count = questions |> Enum.map(& &1.category) |> Enum.uniq() |> length()

      IO.puts(
        "Seeding #{length(questions)} questions across #{topic_count} topics and #{@participants} participants..."
      )

      seed(User, users, :user_uuid, :user_already_exists)

      seed(
        Question,
        Enum.map(questions, &question_command/1),
        :question_uuid,
        :question_already_exists
      )

      votes = Enum.flat_map(questions, &responses/1)
      seed(Vote, votes, :vote_uuid, :vote_already_exists)
      await_projections(questions, users, votes, System.monotonic_time(:millisecond) + 120_000)

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

    if total == 0, do: [], else: Enum.map(1..total, &response_for(question, &1))
  end

  defp response_for(question, index) do
    bucket = :erlang.phash2({question.slug, index}, 100)
    option = pick_option(Enum.zip(question.options, question.weights), bucket)

    %CastVote{
      vote_uuid: Identity.uuid("response:#{question.slug}:#{index}"),
      question_uuid: question.uuid,
      user_uuid: Identity.uuid("participant:#{index}"),
      option_id: option
    }
  end

  defp pick_option(options, bucket) do
    Enum.reduce_while(options, bucket, fn {option, weight}, remaining ->
      if remaining < weight, do: {:halt, option}, else: {:cont, remaining - weight}
    end)
  end

  defp question_command(question) do
    %CreateQuestion{
      question_uuid: question.uuid,
      text: question.text,
      category: question.category,
      options: question.options,
      question_type: if(length(question.options) == 2, do: :binary, else: :multiple_choice)
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
      |> Task.async_stream(fn command -> App.dispatch(command, metadata: @metadata) end,
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

  defp await_projections(questions, users, votes, deadline) do
    question_ids = Enum.map(questions, & &1.uuid)
    user_ids = Enum.map(users, & &1.user_uuid)

    ready? =
      Repo.aggregate(from(q in Question, where: q.uuid in ^question_ids), :count) ==
        length(questions) and
        Repo.aggregate(from(u in User, where: u.uuid in ^user_ids), :count) == length(users) and
        Repo.aggregate(from(v in Vote, where: v.question_uuid in ^question_ids), :count) ==
          length(votes)

    cond do
      ready? ->
        :ok

      System.monotonic_time(:millisecond) >= deadline ->
        raise "Timed out waiting for development projections"

      true ->
        Process.sleep(200)
        await_projections(questions, users, votes, deadline)
    end
  end
end
