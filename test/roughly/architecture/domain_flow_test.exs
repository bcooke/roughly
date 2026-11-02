defmodule Roughly.Architecture.DomainFlowTest do
  use ExUnit.Case, async: false

  alias Roughly.{Access, App, Dispatch, EventStore, Questions, Participation}
  alias Roughly.Access.Actor
  alias Roughly.Questions.Commands.CreateQuestion
  alias Roughly.Participation.Commands.RecordResponse

  setup do
    operator = Actor.system("test-maintenance")
    owner = Ecto.UUID.generate()
    other = Ecto.UUID.generate()

    assert :ok =
             Roughly.Identity.register(operator, owner)

    assert :ok =
             Roughly.Identity.register(operator, other)

    %{operator: operator, owner: Actor.principal(owner), other: Actor.principal(other)}
  end

  test "unattributed and forged privileged metadata cannot write", %{owner: owner} do
    id = Ecto.UUID.generate()

    command = %CreateQuestion{
      question_uuid: id,
      text: "Coffee?",
      question_type: :binary,
      options: choices(["Yes", "No"])
    }

    assert {:error, :unauthorized} = App.dispatch(command)

    assert {:error, :forbidden} =
             Dispatch.dispatch(command, owner, metadata: %{"role" => "admin"})

    assert {:error, :stream_not_found} = EventStore.read_stream_forward(id)
  end

  test "permission grants are authoritative immediately, including revocation", ctx do
    assert {:error, :forbidden} = Questions.create(ctx.owner, definition())
    assert :ok = Access.grant(ctx.operator, ctx.owner.id, :curate_questions)
    assert {:ok, id} = Questions.create(ctx.owner, definition())
    assert :ok = Access.revoke(ctx.operator, ctx.owner.id, :curate_questions)
    assert {:error, :forbidden} = Questions.close(ctx.owner, id)
    assert {:ok, [_created]} = EventStore.read_stream_forward(id)
  end

  test "invalid commands are refused before events are written", ctx do
    id = Ecto.UUID.generate()

    command = %CreateQuestion{
      question_uuid: id,
      text: " ",
      question_type: :binary,
      options: choices(["Yes", "Yes"])
    }

    assert {:error, {:invalid_command, errors}} = Dispatch.dispatch(command, ctx.operator)
    assert Keyword.has_key?(errors, :text)
    assert Keyword.has_key?(errors, :options)
    assert {:error, :stream_not_found} = EventStore.read_stream_forward(id)
  end

  test "the response path validates instruments, ownership, closure and retraction", ctx do
    assert {:ok, question} = Questions.create(ctx.operator, definition())

    assert {:error, :invalid_option} =
             Participation.record(ctx.owner, question, [Ecto.UUID.generate()])

    assert {:ok, vote} = Participation.record(ctx.owner, question, selection(question, "Yes"))

    assert {:error, :response_already_exists} =
             Participation.record(ctx.owner, question, selection(question, "No"))

    assert {:error, :not_owner} = Participation.change(ctx.other, vote, selection(question, "No"))
    assert {:ok, [_cast]} = EventStore.read_stream_forward(vote)
    assert :ok = Participation.change(ctx.owner, vote, selection(question, "No"))
    assert :ok = Questions.close(ctx.operator, question)

    assert {:error, :question_closed} =
             Participation.change(ctx.owner, vote, selection(question, "Yes"))

    assert {:error, :question_closed} =
             Participation.record(ctx.other, question, selection(question, "Yes"))

    assert :ok = Participation.withdraw(ctx.owner, vote)
    assert {:error, :response_already_withdrawn} = Participation.withdraw(ctx.owner, vote)
    assert {:ok, events} = EventStore.read_stream_forward(vote)
    assert length(events) == 3
    assert Enum.all?(events, &(&1.metadata["actor_id"] == ctx.owner.id))
  end

  test "normal participants cannot choose alternate streams for duplicate responses", ctx do
    assert {:ok, question} = Questions.create(ctx.operator, definition())
    id = Ecto.UUID.generate()

    command = %RecordResponse{
      response_uuid: id,
      question_uuid: question,
      principal_uuid: ctx.owner.id,
      option_ids: selection(question, "Yes")
    }

    assert {:error, :invalid_response_identity} = Dispatch.dispatch(command, ctx.owner)
    assert {:error, :stream_not_found} = EventStore.read_stream_forward(id)
  end

  test "concurrent submissions share one response stream", ctx do
    assert {:ok, question} = Questions.create(ctx.operator, definition())

    results =
      1..8
      |> Task.async_stream(
        fn _ -> Participation.record(ctx.owner, question, selection(question, "Yes")) end,
        timeout: :infinity
      )
      |> Enum.map(fn {:ok, result} -> result end)

    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &(&1 == {:error, :response_already_exists})) == 7
  end

  test "deactivated actors lose authority without waiting for a projector", ctx do
    assert :ok = Access.grant(ctx.operator, ctx.owner.id, :curate_questions)
    assert :ok = Roughly.Identity.deactivate(ctx.owner)
    assert {:error, :inactive_actor} = Questions.create(ctx.owner, definition())
  end

  test "trusted actor attribution cannot be replaced by caller metadata", ctx do
    id = Ecto.UUID.generate()

    command = %CreateQuestion{
      question_uuid: id,
      text: "Coffee?",
      question_type: :binary,
      options: choices(["Yes", "No"])
    }

    assert {:error, :forbidden} =
             Dispatch.dispatch(command, ctx.owner,
               metadata: %{
                 "actor_kind" => "system",
                 "actor_source" => "test-maintenance",
                 "actor_id" => ctx.other.id
               }
             )

    assert {:error, :stream_not_found} = EventStore.read_stream_forward(id)
    assert {:error, :forbidden} = Questions.create(Actor.system("unconfigured-job"), definition())
  end

  test "participants cannot grant themselves capabilities", ctx do
    assert {:error, :forbidden} = Access.grant(ctx.owner, ctx.owner.id, :manage_access)
    assert {:error, :stream_not_found} = EventStore.read_stream_forward("access-" <> ctx.owner.id)
  end

  defp definition,
    do: %{text: "Do you like coffee?", question_type: :binary, options: choices(["Yes", "No"])}

  defp choices(labels),
    do: Enum.map(labels, &Roughly.Questions.Option.new(Ecto.UUID.generate(), &1))

  defp selection(id, label),
    do: [
      Enum.find(
        Roughly.History.load(Roughly.Questions.Question, id).options,
        &(&1.label == label)
      ).id
    ]
end
