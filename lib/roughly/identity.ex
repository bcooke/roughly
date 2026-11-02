defmodule Roughly.Identity do
  @moduledoc "Principal lifecycle, separate from authentication credentials and participant attributes."
  alias Roughly.Access.Actor
  alias Roughly.Identity.Commands.{RegisterPrincipal, DeactivatePrincipal}

  @doc false
  @spec active?(Ecto.UUID.t()) :: boolean()
  def active?(id), do: Roughly.History.load(Roughly.Identity.Principal, id).status == :active

  @spec register(Actor.t(), Ecto.UUID.t()) :: :ok | {:error, term()}
  def register(actor, id),
    do: Roughly.Dispatch.dispatch(%RegisterPrincipal{principal_uuid: id}, actor)

  @spec deactivate(Actor.t()) :: :ok | {:error, term()}
  def deactivate(actor),
    do: Roughly.Dispatch.dispatch(%DeactivatePrincipal{principal_uuid: actor.id}, actor)
end
