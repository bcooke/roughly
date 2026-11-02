defmodule Roughly.Identity.Events.PrincipalRegistered do
  @moduledoc "A principal was established. Contains no credential or personal profile payload."
  @type t :: %__MODULE__{principal_uuid: Ecto.UUID.t() | nil}
  @derive Jason.Encoder
  defstruct [:principal_uuid]
end
