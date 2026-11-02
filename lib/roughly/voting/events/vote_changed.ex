defmodule Roughly.Voting.Events.VoteChanged do
  @moduledoc "Event emitted when a vote is changed."
  @derive Jason.Encoder
  defstruct [:vote_uuid, :old_option_id, :new_option_id]
end
