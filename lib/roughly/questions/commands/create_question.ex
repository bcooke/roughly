defmodule Roughly.Questions.Commands.CreateQuestion do
  @moduledoc "Command to create a new question."
  defstruct [:question_uuid, :text, :question_type, :options, :created_by, :category]
end
