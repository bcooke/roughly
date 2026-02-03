defmodule Roughly.Questions.Question do
  @moduledoc """
  Aggregate for the Questions domain.

  Handles commands and emits events for question lifecycle management.
  State is rebuilt by applying events in sequence.
  """

  defstruct uuid: nil,
            text: nil,
            question_type: nil,
            options: [],
            status: nil,
            created_by: nil,
            category: nil

  alias Roughly.Questions.Commands.{CreateQuestion, CloseQuestion}
  alias Roughly.Questions.Events.{QuestionCreated, QuestionClosed}

  # ============================================================================
  # Command Handlers
  # ============================================================================

  @doc """
  Execute commands on the Question aggregate.

  Returns event(s) on success, or `{:error, reason}` on failure.
  """
  def execute(question, command)

  def execute(%__MODULE__{uuid: nil}, %CreateQuestion{} = cmd) do
    %QuestionCreated{
      question_uuid: cmd.question_uuid,
      text: cmd.text,
      question_type: cmd.question_type,
      options: cmd.options,
      created_by: cmd.created_by,
      category: cmd.category
    }
  end

  def execute(%__MODULE__{uuid: _existing}, %CreateQuestion{}) do
    {:error, :question_already_exists}
  end

  def execute(%__MODULE__{status: :active}, %CloseQuestion{} = cmd) do
    %QuestionClosed{
      question_uuid: cmd.question_uuid,
      closed_by: cmd.closed_by,
      reason: cmd.reason
    }
  end

  def execute(%__MODULE__{status: :closed}, %CloseQuestion{}) do
    {:error, :question_already_closed}
  end

  # ============================================================================
  # Event Applicators
  # ============================================================================

  @doc """
  Apply events to rebuild aggregate state.
  """
  def apply(state, event)

  def apply(%__MODULE__{} = state, %QuestionCreated{} = event) do
    %__MODULE__{
      state
      | uuid: event.question_uuid,
        text: event.text,
        question_type: event.question_type,
        options: event.options,
        status: :active,
        created_by: event.created_by,
        category: event.category
    }
  end

  def apply(%__MODULE__{} = state, %QuestionClosed{}) do
    %__MODULE__{state | status: :closed}
  end
end
