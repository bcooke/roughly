defmodule Roughly.Voting.Vote do
  @moduledoc """
  Aggregate for the Voting domain.

  Handles commands and emits events for vote lifecycle management.
  Each vote represents one user's response to one question.
  """

  defstruct uuid: nil,
            question_uuid: nil,
            user_uuid: nil,
            option_id: nil,
            status: nil

  alias Roughly.Voting.Commands.{CastVote, RetractVote, ChangeVote}
  alias Roughly.Voting.Events.{VoteCast, VoteRetracted, VoteChanged}

  # ============================================================================
  # Command Handlers
  # ============================================================================

  @doc """
  Execute commands on the Vote aggregate.

  Returns event(s) on success, or `{:error, reason}` on failure.
  """
  def execute(vote, command)

  def execute(%__MODULE__{uuid: nil}, %CastVote{} = cmd) do
    %VoteCast{
      vote_uuid: cmd.vote_uuid,
      question_uuid: cmd.question_uuid,
      user_uuid: cmd.user_uuid,
      option_id: cmd.option_id
    }
  end

  def execute(%__MODULE__{uuid: _existing}, %CastVote{}) do
    {:error, :vote_already_exists}
  end

  def execute(%__MODULE__{status: :active}, %RetractVote{} = cmd) do
    %VoteRetracted{
      vote_uuid: cmd.vote_uuid,
      reason: cmd.reason
    }
  end

  def execute(%__MODULE__{status: :retracted}, %RetractVote{}) do
    {:error, :vote_already_retracted}
  end

  def execute(%__MODULE__{status: :active, option_id: current}, %ChangeVote{new_option_id: new})
      when current == new do
    {:error, :same_option}
  end

  def execute(%__MODULE__{status: :active, option_id: old}, %ChangeVote{} = cmd) do
    %VoteChanged{
      vote_uuid: cmd.vote_uuid,
      old_option_id: old,
      new_option_id: cmd.new_option_id
    }
  end

  # ============================================================================
  # Event Applicators
  # ============================================================================

  @doc """
  Apply events to rebuild aggregate state.
  """
  def apply(state, event)

  def apply(%__MODULE__{} = state, %VoteCast{} = event) do
    %__MODULE__{
      state
      | uuid: event.vote_uuid,
        question_uuid: event.question_uuid,
        user_uuid: event.user_uuid,
        option_id: event.option_id,
        status: :active
    }
  end

  def apply(%__MODULE__{} = state, %VoteRetracted{}) do
    %__MODULE__{state | status: :retracted}
  end

  def apply(%__MODULE__{} = state, %VoteChanged{new_option_id: new}) do
    %__MODULE__{state | option_id: new}
  end
end
