defmodule Roughly.Access do
  @moduledoc "Identity/access boundary. No public authentication adapter is enabled."
  alias Roughly.Access.{Actor, Grants}
  alias Roughly.Access.Commands.{GrantCapability, RevokeCapability}
  @type capability :: :curate_questions | :manage_access

  @spec grant(Actor.t(), Ecto.UUID.t(), capability()) :: :ok | {:error, term()}
  def grant(actor, principal_uuid, capability),
    do:
      Roughly.Dispatch.dispatch(
        %GrantCapability{principal_uuid: principal_uuid, capability: capability_name(capability)},
        actor
      )

  @spec revoke(Actor.t(), Ecto.UUID.t(), capability()) :: :ok | {:error, term()}
  def revoke(actor, principal_uuid, capability),
    do:
      Roughly.Dispatch.dispatch(
        %RevokeCapability{
          principal_uuid: principal_uuid,
          capability: capability_name(capability)
        },
        actor
      )

  @doc false
  @spec capabilities(Ecto.UUID.t()) :: MapSet.t(String.t())
  def capabilities(id), do: Roughly.History.load(Grants, "access-" <> id).capabilities

  defp capability_name(value) when is_atom(value), do: Atom.to_string(value)
  defp capability_name(value), do: value
end
