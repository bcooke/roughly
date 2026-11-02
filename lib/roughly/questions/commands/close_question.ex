defmodule Roughly.Questions.Commands.CloseQuestion do
  @moduledoc "Command to close a question, preventing further votes."
  defstruct [:question_uuid, :closed_by, :reason]
end
