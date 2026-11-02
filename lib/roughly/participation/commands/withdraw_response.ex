defmodule Roughly.Participation.Commands.WithdrawResponse do
  @moduledoc "Command to retract a previously cast response."
  @type t :: %__MODULE__{
          actor_uuid: Ecto.UUID.t() | nil,
          response_uuid: Ecto.UUID.t() | nil,
          reason: String.t() | nil
        }
  defstruct [:actor_uuid, :response_uuid, :reason]

  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command),
    do: [response_uuid: :uuid, reason: {:optional, {:text, 500}}, actor_uuid: {:optional, :uuid}]
end
