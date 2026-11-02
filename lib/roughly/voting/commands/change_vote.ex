defmodule Roughly.Voting.Commands.ChangeVote do
  @moduledoc "Command to change a vote to a different option."
  defstruct [:vote_uuid, :new_option_id]
end
