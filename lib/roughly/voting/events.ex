defmodule Roughly.Voting.Events do
  @moduledoc """
  Event structs for the Voting aggregate.
  """

  defmodule VoteCast do
    @moduledoc "Event emitted when a vote is cast."
    @derive Jason.Encoder
    defstruct [:vote_uuid, :question_uuid, :user_uuid, :option_id]
  end

  defmodule VoteRetracted do
    @moduledoc "Event emitted when a vote is retracted."
    @derive Jason.Encoder
    defstruct [:vote_uuid, :reason]
  end

  defmodule VoteChanged do
    @moduledoc "Event emitted when a vote is changed."
    @derive Jason.Encoder
    defstruct [:vote_uuid, :old_option_id, :new_option_id]
  end
end
