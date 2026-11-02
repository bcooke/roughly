defmodule Roughly.Questions.Question do
  @moduledoc """
  Aggregate for the Questions domain.

  Handles commands and emits events for question lifecycle management.
  State is rebuilt by applying events in sequence.
  """

  @type t :: %__MODULE__{
          uuid: Ecto.UUID.t() | nil,
          text: String.t() | nil,
          language: String.t() | nil,
          question_type: Roughly.Questions.Instrument.kind() | nil,
          options: [Roughly.Questions.Option.t()],
          status: :active | :closed | nil,
          created_by: Ecto.UUID.t() | nil,
          category: String.t() | nil
        }

  defstruct uuid: nil,
            text: nil,
            language: nil,
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
  @spec execute(t(), CreateQuestion.t() | CloseQuestion.t()) ::
          QuestionCreated.t() | QuestionClosed.t() | {:error, atom()}
  def execute(question, command)

  def execute(%__MODULE__{uuid: nil}, %CreateQuestion{} = cmd) do
    %QuestionCreated{
      question_uuid: cmd.question_uuid,
      text: cmd.text,
      language: cmd.language,
      question_type: cmd.question_type,
      options: cmd.options,
      created_by: cmd.created_by,
      category: cmd.category,
      slug: cmd.slug
    }
  end

  def execute(%__MODULE__{uuid: _existing}, %CreateQuestion{}) do
    {:error, :question_already_exists}
  end

  def execute(%__MODULE__{uuid: nil}, %CloseQuestion{}), do: {:error, :question_not_found}

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
  @spec apply(t(), QuestionCreated.t() | QuestionClosed.t()) :: t()
  def apply(state, event)

  def apply(%__MODULE__{} = state, %QuestionCreated{} = event) do
    %__MODULE__{
      state
      | uuid: event.question_uuid,
        text: event.text,
        language: event.language,
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
