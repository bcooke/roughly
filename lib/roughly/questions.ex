defmodule Roughly.Questions do
  @moduledoc "Public entry point for browsing questions and aggregate results."
  alias Roughly.Questions.Queries

  defdelegate list_questions(filters \\ []), to: Queries.ListQuestions, as: :call
  defdelegate get_question(slug), to: Queries.GetQuestion, as: :call
  defdelegate list_topics(), to: Queries.ListTopics, as: :call

  def related_questions(question) do
    result = list_questions(category: question.category, exclude: question.uuid, page_size: 4)
    result.entries
  end
end
