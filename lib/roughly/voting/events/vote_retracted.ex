defmodule Roughly.Voting.Events.VoteRetracted do
  @moduledoc "Event emitted when a vote is retracted."
  @derive Jason.Encoder
  defstruct [:vote_uuid, :reason]
end
