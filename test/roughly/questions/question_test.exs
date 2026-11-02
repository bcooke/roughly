defmodule Roughly.Questions.QuestionTest do
  @moduledoc """
  Tests for the Question aggregate.

  Aggregate lifecycle examples; new admission behavior has separate red/green evidence.
  """
  use ExUnit.Case

  alias Roughly.Questions.Question
  alias Roughly.Questions.Commands.{CreateQuestion, CloseQuestion}
  alias Roughly.Questions.Events.{QuestionCreated, QuestionClosed}

  @question_uuid "question-123"

  describe "CreateQuestion command" do
    test "creates a question with binary options" do
      cmd = %CreateQuestion{
        question_uuid: @question_uuid,
        text: "Do you like coffee?",
        question_type: :binary,
        options: choices(["Yes", "No"]),
        created_by: "user-1"
      }

      expected_event = %QuestionCreated{
        question_uuid: @question_uuid,
        text: "Do you like coffee?",
        question_type: :binary,
        options: choices(["Yes", "No"]),
        created_by: "user-1"
      }

      assert Question.execute(%Question{}, cmd) == expected_event
    end

    test "creates a question with multiple choice options" do
      cmd = %CreateQuestion{
        question_uuid: @question_uuid,
        text: "What's your favorite season?",
        question_type: :single_choice,
        options: choices(["Spring", "Summer", "Fall", "Winter"]),
        created_by: "user-1"
      }

      expected_event = %QuestionCreated{
        question_uuid: @question_uuid,
        text: "What's your favorite season?",
        question_type: :single_choice,
        options: choices(["Spring", "Summer", "Fall", "Winter"]),
        created_by: "user-1"
      }

      assert Question.execute(%Question{}, cmd) == expected_event
    end

    test "creates a question with scaled options" do
      cmd = %CreateQuestion{
        question_uuid: @question_uuid,
        text: "How satisfied are you?",
        question_type: :ordered_scale,
        options: choices(["1", "2", "3", "4", "5"]),
        created_by: "user-1"
      }

      expected_event = %QuestionCreated{
        question_uuid: @question_uuid,
        text: "How satisfied are you?",
        question_type: :ordered_scale,
        options: choices(["1", "2", "3", "4", "5"]),
        created_by: "user-1"
      }

      assert Question.execute(%Question{}, cmd) == expected_event
    end

    test "rejects duplicate question creation" do
      # If question already exists (has uuid set), reject creation
      existing_question = %Question{uuid: @question_uuid, text: "Existing question"}

      cmd = %CreateQuestion{
        question_uuid: @question_uuid,
        text: "Do you like coffee?",
        question_type: :binary,
        options: choices(["Yes", "No"]),
        created_by: "user-1"
      }

      assert {:error, :question_already_exists} = Question.execute(existing_question, cmd)
    end
  end

  describe "CloseQuestion command" do
    test "closes an active question" do
      question = %Question{uuid: @question_uuid, status: :active}

      cmd = %CloseQuestion{
        question_uuid: @question_uuid,
        closed_by: "admin-1",
        reason: "Survey complete"
      }

      expected_event = %QuestionClosed{
        question_uuid: @question_uuid,
        closed_by: "admin-1",
        reason: "Survey complete"
      }

      assert Question.execute(question, cmd) == expected_event
    end

    test "rejects closing an already closed question" do
      question = %Question{uuid: @question_uuid, status: :closed}

      cmd = %CloseQuestion{
        question_uuid: @question_uuid,
        closed_by: "admin-1",
        reason: "Duplicate close"
      }

      assert {:error, :question_already_closed} = Question.execute(question, cmd)
    end
  end

  describe "apply events" do
    test "applies QuestionCreated event" do
      event = %QuestionCreated{
        question_uuid: @question_uuid,
        text: "Do you like coffee?",
        question_type: :binary,
        options: choices(["Yes", "No"]),
        created_by: "user-1"
      }

      state = Question.apply(%Question{}, event)

      assert state.uuid == @question_uuid
      assert state.text == "Do you like coffee?"
      assert state.question_type == :binary
      assert Enum.map(state.options, & &1.label) == ["Yes", "No"]
      assert state.status == :active
      assert state.created_by == "user-1"
    end

    test "applies QuestionClosed event" do
      initial = %Question{uuid: @question_uuid, status: :active}

      event = %QuestionClosed{
        question_uuid: @question_uuid,
        closed_by: "admin-1",
        reason: "Survey complete"
      }

      state = Question.apply(initial, event)

      assert state.status == :closed
    end
  end

  defp choices(labels),
    do:
      Enum.map(labels, fn label ->
        Roughly.Questions.Option.new(Roughly.Dev.Identity.uuid("test-option:#{label}"), label)
      end)
end
