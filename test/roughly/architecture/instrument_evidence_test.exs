defmodule Roughly.Architecture.InstrumentEvidenceTest do
  use ExUnit.Case, async: false
  alias Roughly.{Identity, Questions, Participation, EventStore}
  alias Roughly.Access.Actor
  alias Roughly.Questions.Option
  alias Roughly.Participation.Context

  test "responses preserve exact option identity and observed collection context" do
    actor = Actor.system("test-maintenance")
    principal = Ecto.UUID.generate()
    assert :ok = Identity.register(actor, principal)
    yes = Option.new(Ecto.UUID.generate(), "Yes")
    no = Option.new(Ecto.UUID.generate(), "No")

    assert {:ok, question} =
             Questions.create(actor, %{
               text: "Have you entered salt water?",
               language: "en",
               question_type: :binary,
               options: [yes, no]
             })

    context =
      Context.new(%{
        option_order: [no.id, yes.id],
        results_exposure: :not_shown,
        answered_at: DateTime.utc_now(),
        field_sources: %{
          results_exposure: :observed,
          option_order: :observed,
          answered_at: :reported
        },
        mode: :internal
      })

    assert {:ok, response} =
             Participation.record(Actor.principal(principal), question, [yes.id], context)

    assert {:ok, [recorded]} = EventStore.read_stream_forward(response)
    assert recorded.data.option_ids == [yes.id]
    assert recorded.data.context == context

    assert {:error, :invalid_option} =
             Participation.change(
               Actor.principal(principal),
               response,
               [Ecto.UUID.generate()],
               context
             )
  end

  test "format cardinality and presentation order are enforced independently" do
    operator = Actor.system("test-maintenance")
    principal = Ecto.UUID.generate()
    assert :ok = Identity.register(operator, principal)
    options = for label <- ["Walk", "Cycle", "Train"], do: Option.new(Ecto.UUID.generate(), label)
    ids = Enum.map(options, & &1.id)

    attrs = %{
      text: "Which travel modes did you use this week?",
      question_type: :multiple_select,
      options: options
    }

    assert {:ok, question} = Questions.create(operator, attrs)
    actor = Actor.principal(principal)

    assert {:error, :invalid_presentation_order} =
             Participation.record(
               actor,
               question,
               Enum.take(ids, 2),
               Context.new(%{option_order: Enum.take(ids, 2)})
             )

    assert {:ok, _} =
             Participation.record(
               actor,
               question,
               Enum.take(ids, 2),
               Context.new(%{option_order: Enum.reverse(ids)})
             )

    assert {:ok, single} = Questions.create(operator, %{attrs | question_type: :single_choice})

    assert {:error, :invalid_answer_cardinality} =
             Participation.record(actor, single, Enum.take(ids, 2))

    assert {:error, {:invalid_command, _}} =
             Participation.record(actor, single, [hd(ids), hd(ids)])
  end

  test "multiple selections are sets rather than click-order measurements" do
    operator = Actor.system("test-maintenance")
    principal = Ecto.UUID.generate()
    assert :ok = Identity.register(operator, principal)
    options = for label <- ["Walk", "Cycle"], do: Option.new(Ecto.UUID.generate(), label)
    ids = Enum.map(options, & &1.id)

    assert {:ok, question} =
             Questions.create(operator, %{
               text: "Modes used?",
               question_type: :multiple_select,
               options: options
             })

    actor = Actor.principal(principal)
    assert {:ok, response} = Participation.record(actor, question, ids)
    assert {:error, :same_answer} = Participation.change(actor, response, Enum.reverse(ids))
  end

  test "even trusted collection sources must reference an active principal" do
    operator = Actor.system("test-maintenance")
    option = Option.new(Ecto.UUID.generate(), "Yes")
    other = Option.new(Ecto.UUID.generate(), "No")

    assert {:ok, question} =
             Questions.create(operator, %{
               text: "An experience?",
               question_type: :binary,
               options: [option, other]
             })

    principal = Ecto.UUID.generate()

    command = %Roughly.Participation.Commands.RecordResponse{
      response_uuid: Participation.identity(question, principal),
      question_uuid: question,
      principal_uuid: principal,
      option_ids: [option.id]
    }

    assert {:error, :principal_not_found} =
             Roughly.Participation.Admission.admit(command, operator)
  end
end
