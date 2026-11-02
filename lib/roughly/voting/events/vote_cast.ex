defmodule Roughly.Voting.Events.VoteCast do
  @moduledoc "Event emitted when a vote is cast."
  @derive Jason.Encoder
  defstruct [:vote_uuid, :question_uuid, :user_uuid, :option_id]
end
