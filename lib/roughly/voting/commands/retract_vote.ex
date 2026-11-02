defmodule Roughly.Voting.Commands.RetractVote do
  @moduledoc "Command to retract a previously cast vote."
  defstruct [:vote_uuid, :reason]
end
