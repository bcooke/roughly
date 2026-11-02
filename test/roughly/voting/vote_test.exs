defmodule Roughly.Voting.VoteTest do
  @moduledoc """
  Tests for the Vote aggregate.

  Following TDD: These tests were written FIRST before implementation.
  """
  use ExUnit.Case

  alias Roughly.Voting.Vote
  alias Roughly.Voting.Commands.{CastVote, RetractVote, ChangeVote}
  alias Roughly.Voting.Events.{VoteCast, VoteRetracted, VoteChanged}

  @vote_uuid "vote-123"
  @question_uuid "question-456"
  @user_uuid "user-789"
  @option_id "option-1"

  describe "CastVote command" do
    test "casts a vote for a question option" do
      cmd = %CastVote{
        vote_uuid: @vote_uuid,
        question_uuid: @question_uuid,
        user_uuid: @user_uuid,
        option_id: @option_id
      }

      expected_event = %VoteCast{
        vote_uuid: @vote_uuid,
        question_uuid: @question_uuid,
        user_uuid: @user_uuid,
        option_id: @option_id
      }

      assert Vote.execute(%Vote{}, cmd) == expected_event
    end

    test "rejects duplicate vote cast" do
      existing_vote = %Vote{uuid: @vote_uuid, question_uuid: @question_uuid}

      cmd = %CastVote{
        vote_uuid: @vote_uuid,
        question_uuid: @question_uuid,
        user_uuid: @user_uuid,
        option_id: @option_id
      }

      assert {:error, :vote_already_exists} = Vote.execute(existing_vote, cmd)
    end
  end

  describe "RetractVote command" do
    test "retracts an existing vote" do
      vote = %Vote{
        uuid: @vote_uuid,
        question_uuid: @question_uuid,
        user_uuid: @user_uuid,
        option_id: @option_id,
        status: :active
      }

      cmd = %RetractVote{
        vote_uuid: @vote_uuid,
        reason: "Changed my mind"
      }

      expected_event = %VoteRetracted{
        vote_uuid: @vote_uuid,
        reason: "Changed my mind"
      }

      assert Vote.execute(vote, cmd) == expected_event
    end

    test "rejects retracting an already retracted vote" do
      vote = %Vote{uuid: @vote_uuid, status: :retracted}

      cmd = %RetractVote{
        vote_uuid: @vote_uuid,
        reason: "Double retract"
      }

      assert {:error, :vote_already_retracted} = Vote.execute(vote, cmd)
    end
  end

  describe "ChangeVote command" do
    test "changes an existing vote to a different option" do
      vote = %Vote{
        uuid: @vote_uuid,
        question_uuid: @question_uuid,
        user_uuid: @user_uuid,
        option_id: @option_id,
        status: :active
      }

      new_option = "option-2"

      cmd = %ChangeVote{
        vote_uuid: @vote_uuid,
        new_option_id: new_option
      }

      expected_event = %VoteChanged{
        vote_uuid: @vote_uuid,
        old_option_id: @option_id,
        new_option_id: new_option
      }

      assert Vote.execute(vote, cmd) == expected_event
    end

    test "rejects changing to the same option" do
      vote = %Vote{
        uuid: @vote_uuid,
        option_id: @option_id,
        status: :active
      }

      cmd = %ChangeVote{
        vote_uuid: @vote_uuid,
        new_option_id: @option_id
      }

      assert {:error, :same_option} = Vote.execute(vote, cmd)
    end
  end

  describe "apply events" do
    test "applies VoteCast event" do
      event = %VoteCast{
        vote_uuid: @vote_uuid,
        question_uuid: @question_uuid,
        user_uuid: @user_uuid,
        option_id: @option_id
      }

      state = Vote.apply(%Vote{}, event)

      assert state.uuid == @vote_uuid
      assert state.question_uuid == @question_uuid
      assert state.user_uuid == @user_uuid
      assert state.option_id == @option_id
      assert state.status == :active
    end

    test "applies VoteRetracted event" do
      initial = %Vote{uuid: @vote_uuid, status: :active}

      event = %VoteRetracted{
        vote_uuid: @vote_uuid,
        reason: "Changed my mind"
      }

      state = Vote.apply(initial, event)

      assert state.status == :retracted
    end

    test "applies VoteChanged event" do
      initial = %Vote{uuid: @vote_uuid, option_id: @option_id, status: :active}
      new_option = "option-2"

      event = %VoteChanged{
        vote_uuid: @vote_uuid,
        old_option_id: @option_id,
        new_option_id: new_option
      }

      state = Vote.apply(initial, event)

      assert state.option_id == new_option
    end
  end
end
