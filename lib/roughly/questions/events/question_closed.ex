defmodule Roughly.Questions.Events.QuestionClosed do
  @moduledoc "Event emitted when a question is closed."
  @derive Jason.Encoder
  defstruct [:question_uuid, :closed_by, :reason]
end
