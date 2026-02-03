defmodule Roughly.Router do
  @moduledoc """
  Command router for Roughly.

  Routes commands to their respective aggregates.
  """

  use Commanded.Commands.Router

  alias Roughly.Questions.Question
  alias Roughly.Questions.Commands.{CreateQuestion, CloseQuestion}

  alias Roughly.Voting.Vote
  alias Roughly.Voting.Commands.{CastVote, RetractVote, ChangeVote}

  alias Roughly.Users.User
  alias Roughly.Users.Commands.{RegisterUser, UpdateProfile, DeactivateUser}

  # Middlewares
  middleware(Commanded.Middleware.Logger)

  # Questions
  dispatch([CreateQuestion, CloseQuestion], to: Question, identity: :question_uuid)

  # Voting
  dispatch([CastVote, RetractVote, ChangeVote], to: Vote, identity: :vote_uuid)

  # Users
  dispatch([RegisterUser, UpdateProfile, DeactivateUser], to: User, identity: :user_uuid)
end
