defmodule RoughlyWeb.QuestionLive do
  use RoughlyWeb, :live_view
  import RoughlyWeb.Format, only: [number: 1]
  alias Roughly.Questions

  @impl true
  def mount(_params, _session, socket),
    do:
      {:ok,
       socket |> stream_configure(:related, dom_id: &"related-#{&1.slug}") |> stream(:related, [])}

  @impl true
  def handle_params(%{"slug" => slug}, _uri, socket) do
    question = Questions.get_question(slug)
    related = if question, do: Questions.related_questions(question), else: []
    page_title = if question, do: question.text, else: "Question not found"

    {:noreply,
     socket
     |> assign(question: question, page_title: page_title)
     |> stream(:related, related, reset: true, dom_id: &"related-#{&1.slug}")}
  end
end
