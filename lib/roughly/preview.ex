defmodule Roughly.Preview do
  @moduledoc """
  Read-only entry point for synthetic interface examples. No responses are collected.
  """

  alias Roughly.Preview.Queries

  defdelegate list_questions(filters \\ []), to: Queries.ListQuestions, as: :call
  defdelegate get_question(slug), to: Queries.GetQuestion, as: :call
end
