defmodule Roughly.Questions.Projections.ProjectorTest do
  use Roughly.DataCase, async: true

  alias Commanded.Serialization.JsonSerializer
  alias Roughly.Questions.Events.{QuestionClosed, QuestionCreated}
  alias Roughly.Questions.Projections.{Projector, Question}

  test "projects a JSON round trip, then closes the question and ignores duplicate delivery" do
    id = Ecto.UUID.generate()

    event = %QuestionCreated{
      question_uuid: id,
      slug: Roughly.Questions.Instrument.slug_base("Do you like coffee?"),
      text: "Do you like coffee?",
      question_type: :binary,
      options: Enum.map(["Yes", "No"], &Roughly.Questions.Option.new(Ecto.UUID.generate(), &1)),
      language: "en"
    }

    restored =
      event
      |> JsonSerializer.serialize()
      |> JsonSerializer.deserialize(type: Atom.to_string(QuestionCreated))

    assert restored.question_type == :binary
    metadata = %{handler_name: "test-#{id}", event_number: 1}
    assert :ok = Projector.handle(restored, metadata)
    assert %Question{question_type: :binary, status: :active} = Repo.get!(Question, id)
    assert Repo.get!(Question, id).slug == "do-you-like-coffee"
    assert :ok = Projector.handle(restored, metadata)

    assert :ok =
             Projector.handle(%QuestionClosed{question_uuid: id}, %{metadata | event_number: 2})

    assert %Question{status: :closed} = Repo.get!(Question, id)
  end
end
