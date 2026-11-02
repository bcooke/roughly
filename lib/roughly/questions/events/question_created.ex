defmodule Roughly.Questions.Events.QuestionCreated do
  @moduledoc "Event emitted when a question is created."
  @derive Jason.Encoder
  defstruct [:question_uuid, :text, :question_type, :options, :created_by, :category]
end
