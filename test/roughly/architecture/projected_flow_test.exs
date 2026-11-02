defmodule Roughly.Architecture.ProjectedFlowTest do
  use Roughly.DataCase, async: false
  alias Roughly.{EventStore, Questions, Participation}
  alias Roughly.Access.Actor
  alias Roughly.Questions.Projections.{Projector, Question}
  alias Roughly.Participation.Projections.Projector, as: ResponseProjector

  test "persisted events project into aggregate-only queries, including equal-worded instruments" do
    actor = Actor.system("test-maintenance")
    user_id = Ecto.UUID.generate()

    assert :ok =
             Roughly.Identity.register(actor, user_id)

    participant = Actor.principal(user_id)
    text = "Repeated instrument #{Ecto.UUID.generate()}?"
    attrs = %{text: text, question_type: :binary, options: choices(["Yes", "No"])}
    assert {:ok, first} = Questions.create(actor, attrs)
    assert {:ok, second} = Questions.create(actor, attrs)

    for id <- [first, second] do
      assert {:ok, [event]} = EventStore.read_stream_forward(id)

      assert :ok =
               Projector.handle(event.data, %{handler_name: "question-#{id}", event_number: 1})
    end

    first_projection = Repo.get!(Question, first)
    refute first_projection.slug == Repo.get!(Question, second).slug

    assert {:ok, vote} =
             Participation.record(
               participant,
               first,
               selection(first, "Yes"),
               Roughly.Participation.Context.new(%{
                 answered_at: DateTime.utc_now(),
                 field_sources: %{answered_at: :reported}
               })
             )

    assert :ok = Participation.change(participant, vote, selection(first, "No"))
    assert {:ok, events} = EventStore.read_stream_forward(vote)

    for event <- events do
      metadata = %{handler_name: "vote-#{vote}", event_number: event.stream_version}
      assert :ok = ResponseProjector.handle(event.data, metadata)
      assert :ok = ResponseProjector.handle(event.data, metadata)
    end

    result = Questions.get_question(first_projection.slug)
    assert result.total == 1
    assert Enum.find(result.answers, &(&1.label == "No")).count == 1

    assert Map.keys(result) |> Enum.sort() == [
             :answers,
             :category,
             :language,
             :question_type,
             :slug,
             :text,
             :total,
             :uuid
           ]

    assert :ok = Participation.withdraw(participant, vote)
    assert {:ok, [retracted]} = EventStore.read_stream_forward(vote, 3)

    assert :ok =
             ResponseProjector.handle(retracted.data, %{
               handler_name: "vote-#{vote}",
               event_number: 3
             })

    assert Questions.get_question(first_projection.slug).total == 0
  end

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
