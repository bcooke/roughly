defmodule Roughly.Questions.Events.QuestionUpdated do
  @moduledoc "Event emitted when a question is updated."
  @derive Jason.Encoder
  defstruct [:question_uuid, :text, :category, :updated_by]
end
