defmodule Roughly.Architecture.ReplayTest do
  use ExUnit.Case, async: true
  alias Commanded.Serialization.JsonSerializer
  alias Roughly.Questions.{Question, Events.QuestionCreated}
  alias Roughly.Identity.{Principal, Events.PrincipalRegistered}
  alias Roughly.Participation.{Response, Events.ResponseRecorded}

  test "serialized domain facts rebuild state independently of command admission" do
    question_id = Ecto.UUID.generate()
    principal_id = Ecto.UUID.generate()
    response_id = Roughly.Participation.identity(question_id, principal_id)

    question =
      roundtrip(%QuestionCreated{
        question_uuid: question_id,
        text: "Coffee?",
        slug: "coffee-#{question_id}",
        question_type: :binary,
        options: Enum.map(["Yes", "No"], &Roughly.Questions.Option.new(Ecto.UUID.generate(), &1))
      })

    assert %Question{question_type: :binary, status: :active} =
             Question.apply(%Question{}, question)

    principal = roundtrip(%PrincipalRegistered{principal_uuid: principal_id})

    assert %Principal{uuid: ^principal_id, status: :active} =
             Principal.apply(%Principal{}, principal)

    response =
      roundtrip(%ResponseRecorded{
        response_uuid: response_id,
        principal_uuid: principal_id,
        question_uuid: question_id,
        option_ids: [hd(question.options).id],
        context: %Roughly.Participation.Context{}
      })

    assert %Response{principal_uuid: ^principal_id, option_ids: [_], status: :active} =
             Response.apply(%Response{}, response)

    assert response.context == %Roughly.Participation.Context{}
  end

  defp roundtrip(event),
    do:
      JsonSerializer.deserialize(JsonSerializer.serialize(event),
        type: Atom.to_string(event.__struct__)
      )
end
