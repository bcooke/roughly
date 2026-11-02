defmodule Roughly.Voting.Commands.CastVote do
  @moduledoc "Command to cast a vote on a question."
  defstruct [:vote_uuid, :question_uuid, :user_uuid, :option_id]
end
