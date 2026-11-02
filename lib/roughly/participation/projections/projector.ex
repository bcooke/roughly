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

  project(%ResponseRecorded{} = event, metadata, fn multi ->
    multi
    |> Ecto.Multi.insert(:response, %Response{
      uuid: event.response_uuid,
      question_uuid: event.question_uuid,
      principal_uuid: event.principal_uuid,
      option_ids: event.option_ids,
      context: Map.from_struct(event.context),
      status: :active
    })
    |> history(event.context, metadata)
  end)

  project(%ResponseWithdrawn{} = event, metadata, fn multi ->
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
    |> history(nil, metadata)
  end)

  project(%ResponseChanged{} = event, metadata, fn multi ->
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
    |> history(event.context, metadata)
  end)

  defp history(multi, context, metadata) do
    recorded_at = Map.fetch!(metadata, :created_at)
    answered_at = if context, do: context.answered_at

    source =
      if answered_at,
        do: to_string(Map.get(context.field_sources, :answered_at, :unspecified)),
        else: "receipt"

    Ecto.Multi.run(multi, :history, fn repo, %{response: response} ->
      repo.insert(%Roughly.Analysis.Projections.ResponseVersion{
        event_number: metadata.event_number,
        response_uuid: response.uuid,
        question_uuid: response.question_uuid,
        principal_uuid: response.principal_uuid,
        option_ids: response.option_ids,
        status: response.status,
        recorded_at: precision(recorded_at),
        answered_at: precision(answered_at || recorded_at),
        date_source: source
      })
    end)
  end

  defp precision(time),
    do: DateTime.from_unix!(DateTime.to_unix(time, :microsecond), :microsecond)
end
