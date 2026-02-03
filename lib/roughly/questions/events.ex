defmodule Roughly.Questions.Events do
  @moduledoc """
  Event structs for the Questions aggregate.

  Events represent facts that have occurred. They are immutable
  and are stored in the event store.
  """

  defmodule QuestionCreated do
    @moduledoc "Event emitted when a question is created."
    @derive Jason.Encoder
    defstruct [:question_uuid, :text, :question_type, :options, :created_by, :category]
  end

  defmodule QuestionClosed do
    @moduledoc "Event emitted when a question is closed."
    @derive Jason.Encoder
    defstruct [:question_uuid, :closed_by, :reason]
  end

  defmodule QuestionUpdated do
    @moduledoc "Event emitted when a question is updated."
    @derive Jason.Encoder
    defstruct [:question_uuid, :text, :category, :updated_by]
  end
end
