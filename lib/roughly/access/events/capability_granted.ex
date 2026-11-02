defmodule Roughly.Access.Events.CapabilityGranted do
  @moduledoc "A principal received a capability."
  @type t :: %__MODULE__{principal_uuid: Ecto.UUID.t() | nil, capability: String.t() | nil}
  @derive Jason.Encoder
  defstruct [:principal_uuid, :capability]
end
