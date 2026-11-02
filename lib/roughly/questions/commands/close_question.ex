defmodule Roughly.Questions.Commands.CloseQuestion do
  @moduledoc "Command to close a question, preventing further votes."
  @type t :: %__MODULE__{
          question_uuid: Ecto.UUID.t() | nil,
          closed_by: Ecto.UUID.t() | nil,
          reason: String.t() | nil
        }
  defstruct [:question_uuid, :closed_by, :reason]

  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command),
    do: [question_uuid: :uuid, closed_by: {:optional, :uuid}, reason: {:optional, {:text, 500}}]
end
