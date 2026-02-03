defmodule Roughly.Questions.Commands do
  @moduledoc """
  Command structs for the Questions aggregate.

  Commands represent intent to change state. They are validated
  by the aggregate before producing events.
  """

  defmodule CreateQuestion do
    @moduledoc "Command to create a new question."
    defstruct [:question_uuid, :text, :question_type, :options, :created_by, :category]
  end

  defmodule CloseQuestion do
    @moduledoc "Command to close a question, preventing further votes."
    defstruct [:question_uuid, :closed_by, :reason]
  end

  defmodule UpdateQuestion do
    @moduledoc "Command to update question metadata (not options after votes exist)."
    defstruct [:question_uuid, :text, :category, :updated_by]
  end
end
