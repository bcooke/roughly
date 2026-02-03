defmodule Roughly.Voting.Commands do
  @moduledoc """
  Command structs for the Voting aggregate.
  """

  defmodule CastVote do
    @moduledoc "Command to cast a vote on a question."
    defstruct [:vote_uuid, :question_uuid, :user_uuid, :option_id]
  end

  defmodule RetractVote do
    @moduledoc "Command to retract a previously cast vote."
    defstruct [:vote_uuid, :reason]
  end

  defmodule ChangeVote do
    @moduledoc "Command to change a vote to a different option."
    defstruct [:vote_uuid, :new_option_id]
  end
end
