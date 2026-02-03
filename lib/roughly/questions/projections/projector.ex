defmodule Roughly.Questions.Projections.Projector do
  @moduledoc """
  Projector for the Questions domain.

  Listens to question events and updates the read model.
  """

  use Commanded.Projections.Ecto,
    application: Roughly.App,
    repo: Roughly.Repo,
    name: "QuestionProjector"

  alias Roughly.Questions.Events.{QuestionCreated, QuestionClosed}
  alias Roughly.Questions.Projections.Question

  project(%QuestionCreated{} = event, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :question, %Question{
      uuid: event.question_uuid,
      text: event.text,
      question_type: event.question_type,
      options: event.options || [],
      category: event.category,
      created_by: event.created_by,
      status: :active
    })
  end)

  project(%QuestionClosed{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :question, fn repo, _changes ->
      case repo.get(Question, event.question_uuid) do
        nil ->
          {:error, :not_found}

        question ->
          question
          |> Ecto.Changeset.change(status: :closed)
          |> repo.update()
      end
    end)
  end)
end
