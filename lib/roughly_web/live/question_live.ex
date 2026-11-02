defmodule RoughlyWeb.QuestionLive do
  use RoughlyWeb, :live_view

  alias Roughly.Preview

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    question = Preview.get_question(slug)
    page_title = if question, do: question.text, else: "Question not found"
    {:ok, assign(socket, question: question, page_title: page_title)}
  end
end
