defmodule Roughly.Identity.Commands.RegisterPrincipal do
  @moduledoc "Establish a principal without defining an authentication method or a demographic profile."
  @type t :: %__MODULE__{principal_uuid: Ecto.UUID.t() | nil}
  defstruct [:principal_uuid]
  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command), do: [principal_uuid: :uuid]
end
