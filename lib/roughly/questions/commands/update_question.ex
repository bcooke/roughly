defmodule Roughly.Questions.Commands.UpdateQuestion do
  @moduledoc "Command to update question metadata (not options after votes exist)."
  defstruct [:question_uuid, :text, :category, :updated_by]
end
