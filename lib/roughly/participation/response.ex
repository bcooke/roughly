defmodule Roughly.Participation.Response do
  @moduledoc """
  Aggregate for the Participation domain.

  Handles commands and emits events for response lifecycle management.
  Each response records a principal’s selections for one exact instrument.
  """

  @type t :: %__MODULE__{
          uuid: Ecto.UUID.t() | nil,
          question_uuid: Ecto.UUID.t() | nil,
          principal_uuid: Ecto.UUID.t() | nil,
          option_ids: [Ecto.UUID.t()] | nil,
          status: :active | :withdrawn | nil
        }

  defstruct uuid: nil,
            question_uuid: nil,
            principal_uuid: nil,
            option_ids: nil,
            status: nil

  alias Roughly.Participation.Commands.{RecordResponse, WithdrawResponse, ChangeResponse}
  alias Roughly.Participation.Events.{ResponseRecorded, ResponseWithdrawn, ResponseChanged}

  # ============================================================================
  # Command Handlers
  # ============================================================================

  @doc """
  Execute commands on the Response aggregate.

  Returns event(s) on success, or `{:error, reason}` on failure.
  """
  @spec execute(t(), RecordResponse.t() | ChangeResponse.t() | WithdrawResponse.t()) ::
          ResponseRecorded.t() | ResponseChanged.t() | ResponseWithdrawn.t() | {:error, atom()}
  def execute(response, command)

  def execute(%__MODULE__{uuid: nil}, %RecordResponse{} = cmd) do
    %ResponseRecorded{
      response_uuid: cmd.response_uuid,
      question_uuid: cmd.question_uuid,
      principal_uuid: cmd.principal_uuid,
      option_ids: cmd.option_ids,
      context: cmd.context
    }
  end

  def execute(%__MODULE__{uuid: _existing}, %RecordResponse{}) do
    {:error, :response_already_exists}
  end

  def execute(%__MODULE__{uuid: nil}, %ChangeResponse{}), do: {:error, :response_not_found}
  def execute(%__MODULE__{uuid: nil}, %WithdrawResponse{}), do: {:error, :response_not_found}

  def execute(%__MODULE__{principal_uuid: owner}, %ChangeResponse{actor_uuid: actor})
      when owner != actor,
      do: {:error, :not_owner}

  def execute(%__MODULE__{principal_uuid: owner}, %WithdrawResponse{actor_uuid: actor})
      when owner != actor,
      do: {:error, :not_owner}

  def execute(%__MODULE__{status: :withdrawn}, %ChangeResponse{}),
    do: {:error, :response_already_withdrawn}

  def execute(%__MODULE__{status: :active}, %WithdrawResponse{} = cmd) do
    %ResponseWithdrawn{
      response_uuid: cmd.response_uuid,
      reason: cmd.reason
    }
  end

  def execute(%__MODULE__{status: :withdrawn}, %WithdrawResponse{}) do
    {:error, :response_already_withdrawn}
  end

  def execute(%__MODULE__{status: :active, option_ids: current}, %ChangeResponse{
        new_option_ids: new
      })
      when current == new do
    {:error, :same_answer}
  end

  def execute(%__MODULE__{status: :active, option_ids: old}, %ChangeResponse{} = cmd) do
    %ResponseChanged{
      response_uuid: cmd.response_uuid,
      old_option_ids: old,
      new_option_ids: cmd.new_option_ids,
      context: cmd.context
    }
  end

  # ============================================================================
  # Event Applicators
  # ============================================================================

  @doc """
  Apply events to rebuild aggregate state.
  """
  @spec apply(t(), ResponseRecorded.t() | ResponseChanged.t() | ResponseWithdrawn.t()) :: t()
  def apply(state, event)

  def apply(%__MODULE__{} = state, %ResponseRecorded{} = event) do
    %__MODULE__{
      state
      | uuid: event.response_uuid,
        question_uuid: event.question_uuid,
        principal_uuid: event.principal_uuid,
        option_ids: event.option_ids,
        status: :active
    }
  end

  def apply(%__MODULE__{} = state, %ResponseWithdrawn{}) do
    %__MODULE__{state | status: :withdrawn}
  end

  def apply(%__MODULE__{} = state, %ResponseChanged{new_option_ids: new}) do
    %__MODULE__{state | option_ids: new}
  end
end
