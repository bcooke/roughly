defmodule Roughly.Identity.Projections.Projector do
  @moduledoc "Projects principal standing without storing credentials or demographic attributes."
  use Commanded.Projections.Ecto,
    application: Roughly.App,
    repo: Roughly.Repo,
    name: "IdentityProjector"

  alias Roughly.Identity.Events.{PrincipalRegistered, PrincipalDeactivated}
  alias Roughly.Identity.Projections.Principal

  project(%PrincipalRegistered{} = event, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :principal, %Principal{uuid: event.principal_uuid, status: :active})
  end)

  project(%PrincipalDeactivated{} = event, _metadata, fn multi ->
    Ecto.Multi.update_all(
      multi,
      :principal,
      from(p in Principal, where: p.uuid == ^event.principal_uuid),
      set: [status: :deactivated]
    )
  end)
end
