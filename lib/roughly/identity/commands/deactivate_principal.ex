defmodule Roughly.Identity.Commands.DeactivatePrincipal do
  @moduledoc "Deactivate a principal’s participation authority."
  @type t :: %__MODULE__{
          principal_uuid: Ecto.UUID.t() | nil,
          reason: String.t() | nil
        }
  defstruct [:principal_uuid, :reason]

  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command), do: [principal_uuid: :uuid, reason: {:optional, {:text, 500}}]
end
