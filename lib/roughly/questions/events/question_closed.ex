defmodule Roughly.Questions.Events.QuestionClosed do
  @moduledoc "Event emitted when a question is closed."
  @type t :: %__MODULE__{
          question_uuid: Ecto.UUID.t() | nil,
          closed_by: Ecto.UUID.t() | nil,
          reason: String.t() | nil
        }
  @derive Jason.Encoder
  defstruct [:question_uuid, :closed_by, :reason]
end
