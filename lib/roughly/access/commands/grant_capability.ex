defmodule Roughly.Access.Commands.GrantCapability do
  @moduledoc "Grant a named capability to a principal."
  @type t :: %__MODULE__{principal_uuid: Ecto.UUID.t() | nil, capability: String.t() | nil}
  defstruct [:principal_uuid, :capability]

  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command),
    do: [principal_uuid: :uuid, capability: {:in, ["curate_questions", "manage_access"]}]
end
