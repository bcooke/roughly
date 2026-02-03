defmodule Roughly.Voting.Vote do
  @moduledoc """
  Vote aggregate - records a user's response to a question.

  Votes are immutable events. Users can retract votes but the
  original vote event remains in the event store for auditability.
  """

  defstruct [:uuid, :question_uuid, :user_uuid, :response_uuid, :status]

  # Commands (to be implemented)
  # - CastVote
  # - RetractVote

  # Events (to be implemented)
  # - VoteCast
  # - VoteRetracted
end
