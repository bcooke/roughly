defmodule Roughly.Participation.Projections.Projector do
  @moduledoc """
  Projector for the Participation domain.

  Listens to participation events and updates the read model.
  """

  use Commanded.Projections.Ecto,
    application: Roughly.App,
    repo: Roughly.Repo,
    name: "ParticipationProjector"

  alias Roughly.Participation.Events.{ResponseRecorded, ResponseWithdrawn, ResponseChanged}
  alias Roughly.Participation.Projections.Response

  project(%ResponseRecorded{} = event, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :response, %Response{
      uuid: event.response_uuid,
      question_uuid: event.question_uuid,
      principal_uuid: event.principal_uuid,
      option_ids: event.option_ids,
      context: Map.from_struct(event.context),
      status: :active
    })
  end)

  project(%ResponseWithdrawn{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :response, fn repo, _changes ->
      case repo.get(Response, event.response_uuid) do
        nil ->
          {:error, :not_found}

        response ->
          response
          |> Ecto.Changeset.change(status: :withdrawn)
          |> repo.update()
      end
    end)
  end)

  project(%ResponseChanged{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :response, fn repo, _changes ->
      case repo.get(Response, event.response_uuid) do
        nil ->
          {:error, :not_found}

        response ->
          response
          |> Ecto.Changeset.change(
            option_ids: event.new_option_ids,
            context: Map.from_struct(event.context)
          )
          |> repo.update()
      end
    end)
  end)
end
