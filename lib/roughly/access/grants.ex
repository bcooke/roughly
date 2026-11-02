defmodule Roughly.Access.Grants do
  @moduledoc "Capability history for one principal; separate from account credentials and answers."
  alias Roughly.Access.Commands.{GrantCapability, RevokeCapability}
  alias Roughly.Access.Events.{CapabilityGranted, CapabilityRevoked}
  @type t :: %__MODULE__{capabilities: MapSet.t(String.t())}
  defstruct capabilities: MapSet.new()

  @spec execute(t(), GrantCapability.t() | RevokeCapability.t()) ::
          CapabilityGranted.t() | CapabilityRevoked.t() | []
  def execute(state, %GrantCapability{} = cmd) do
    if MapSet.member?(state.capabilities, cmd.capability),
      do: [],
      else: %CapabilityGranted{principal_uuid: cmd.principal_uuid, capability: cmd.capability}
  end

  def execute(state, %RevokeCapability{} = cmd) do
    if MapSet.member?(state.capabilities, cmd.capability),
      do: %CapabilityRevoked{principal_uuid: cmd.principal_uuid, capability: cmd.capability},
      else: []
  end

  @spec apply(t(), CapabilityGranted.t() | CapabilityRevoked.t()) :: t()
  def apply(state, %CapabilityGranted{capability: value}),
    do: %{state | capabilities: MapSet.put(state.capabilities, value)}

  def apply(state, %CapabilityRevoked{capability: value}),
    do: %{state | capabilities: MapSet.delete(state.capabilities, value)}
end
