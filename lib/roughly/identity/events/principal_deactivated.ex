defmodule Roughly.Identity.Events.PrincipalDeactivated do
  @moduledoc "A principal’s participation authority was deactivated."
  @type t :: %__MODULE__{
          principal_uuid: Ecto.UUID.t() | nil,
          reason: String.t() | nil
        }
  @derive Jason.Encoder
  defstruct [:principal_uuid, :reason]
end
