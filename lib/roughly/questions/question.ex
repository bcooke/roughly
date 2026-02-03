defmodule Roughly.Questions.Question do
  @moduledoc """
  Question aggregate - the core polling unit.

  A Question represents a single pollable question with its responses.
  All state changes are driven by events.
  """

  defstruct [:uuid, :text, :question_type, :responses, :status]

  # Commands (to be implemented)
  # - CreateQuestion
  # - AddResponse
  # - ActivateQuestion
  # - DeactivateQuestion

  # Events (to be implemented)
  # - QuestionCreated
  # - ResponseAdded
  # - QuestionActivated
  # - QuestionDeactivated
end
