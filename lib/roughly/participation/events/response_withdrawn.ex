defmodule Roughly.Participation.Events.ResponseWithdrawn do
  @moduledoc "Event emitted when a response is retracted."
  @type t :: %__MODULE__{
          response_uuid: Ecto.UUID.t() | nil,
          reason: String.t() | nil
        }
  @derive Jason.Encoder
  defstruct [:response_uuid, :reason]
end
