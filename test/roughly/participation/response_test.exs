defmodule Roughly.Participation.ResponseTest do
  @moduledoc """
  Tests for the Response aggregate.

  Aggregate lifecycle examples. Test-first evidence for new admission behavior is recorded with its implementation work.
  """
  use ExUnit.Case

  alias Roughly.Participation.Response
  alias Roughly.Participation.Commands.{RecordResponse, WithdrawResponse, ChangeResponse}
  alias Roughly.Participation.Events.{ResponseRecorded, ResponseWithdrawn, ResponseChanged}

  @response_uuid Ecto.UUID.generate()
  @question_uuid Ecto.UUID.generate()
  @principal_uuid Ecto.UUID.generate()
  @option_ids [Ecto.UUID.generate()]

  describe "RecordResponse command" do
    test "casts a vote for a question option" do
      cmd = %RecordResponse{
        response_uuid: @response_uuid,
        question_uuid: @question_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids
      }

      expected_event = %ResponseRecorded{
        context: %Roughly.Participation.Context{},
        response_uuid: @response_uuid,
        question_uuid: @question_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids
      }

      assert Response.execute(%Response{}, cmd) == expected_event
    end

    test "rejects duplicate vote cast" do
      existing_vote = %Response{uuid: @response_uuid, question_uuid: @question_uuid}

      cmd = %RecordResponse{
        response_uuid: @response_uuid,
        question_uuid: @question_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids
      }

      assert {:error, :response_already_exists} = Response.execute(existing_vote, cmd)
    end
  end

  describe "WithdrawResponse command" do
    test "retracts an existing vote" do
      vote = %Response{
        uuid: @response_uuid,
        question_uuid: @question_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids,
        status: :active
      }

      cmd = %WithdrawResponse{
        actor_uuid: @principal_uuid,
        response_uuid: @response_uuid,
        reason: "Changed my mind"
      }

      expected_event = %ResponseWithdrawn{
        response_uuid: @response_uuid,
        reason: "Changed my mind"
      }

      assert Response.execute(vote, cmd) == expected_event
    end

    test "rejects retracting an already retracted vote" do
      vote = %Response{uuid: @response_uuid, principal_uuid: @principal_uuid, status: :withdrawn}

      cmd = %WithdrawResponse{
        actor_uuid: @principal_uuid,
        response_uuid: @response_uuid,
        reason: "Double retract"
      }

      assert {:error, :response_already_withdrawn} = Response.execute(vote, cmd)
    end
  end

  describe "ChangeResponse command" do
    test "changes an existing vote to a different option" do
      vote = %Response{
        uuid: @response_uuid,
        question_uuid: @question_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids,
        status: :active
      }

      new_option = [Ecto.UUID.generate()]

      cmd = %ChangeResponse{
        actor_uuid: @principal_uuid,
        response_uuid: @response_uuid,
        new_option_ids: new_option
      }

      expected_event = %ResponseChanged{
        context: %Roughly.Participation.Context{},
        response_uuid: @response_uuid,
        old_option_ids: @option_ids,
        new_option_ids: new_option
      }

      assert Response.execute(vote, cmd) == expected_event
    end

    test "rejects changing to the same option" do
      vote = %Response{
        uuid: @response_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids,
        status: :active
      }

      cmd = %ChangeResponse{
        actor_uuid: @principal_uuid,
        response_uuid: @response_uuid,
        new_option_ids: @option_ids
      }

      assert {:error, :same_answer} = Response.execute(vote, cmd)
    end
  end

  describe "apply events" do
    test "applies ResponseRecorded event" do
      event = %ResponseRecorded{
        context: %Roughly.Participation.Context{},
        response_uuid: @response_uuid,
        question_uuid: @question_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids
      }

      state = Response.apply(%Response{}, event)

      assert state.uuid == @response_uuid
      assert state.question_uuid == @question_uuid
      assert state.principal_uuid == @principal_uuid
      assert state.option_ids == @option_ids
      assert state.status == :active
    end

    test "applies ResponseWithdrawn event" do
      initial = %Response{uuid: @response_uuid, status: :active}

      event = %ResponseWithdrawn{
        response_uuid: @response_uuid,
        reason: "Changed my mind"
      }

      state = Response.apply(initial, event)

      assert state.status == :withdrawn
    end

    test "applies ResponseChanged event" do
      initial = %Response{
        uuid: @response_uuid,
        principal_uuid: @principal_uuid,
        option_ids: @option_ids,
        status: :active
      }

      new_option = [Ecto.UUID.generate()]

      event = %ResponseChanged{
        context: %Roughly.Participation.Context{},
        response_uuid: @response_uuid,
        old_option_ids: @option_ids,
        new_option_ids: new_option
      }

      state = Response.apply(initial, event)

      assert state.option_ids == new_option
    end
  end
end
