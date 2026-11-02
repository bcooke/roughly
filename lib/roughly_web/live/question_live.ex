defmodule RoughlyWeb.QuestionLive do
  use RoughlyWeb, :live_view
  import RoughlyWeb.Format, only: [number: 1]
  alias Roughly.Questions

  @colors ["#326959", "#d6a758", "#7b8eaf", "#ba7c75", "#8b9b62", "#a28bb5"]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:related, dom_id: &"related-#{&1.slug}")
     |> stream_configure(:answers, dom_id: &"answer-#{&1.index}")
     |> stream_configure(:segments, dom_id: &"segment-#{&1.index}")
     |> stream_configure(:columns, dom_id: &"scale-column-#{&1.index}")
     |> stream_configure(:table, dom_id: &"table-answer-#{&1.index}")
     |> stream(:segments, [])
     |> stream(:columns, [])
     |> stream(:table, [])
     |> stream(:related, [])
     |> stream(:answers, [])}
  end

  @impl true
  def handle_params(%{"slug" => slug} = params, _uri, socket) do
    question = Questions.get_question(slug)
    related = if question, do: Questions.related_questions(question), else: []
    view = if params["view"] == "table", do: "table", else: "chart"
    metric = if params["metric"] == "count", do: "count", else: "percentage"
    answers = if question, do: chart_answers(question), else: []

    {:noreply,
     socket
     |> assign(
       question: question,
       page_title: if(question, do: question.text, else: "Question not found"),
       view: view,
       metric: metric,
       chart: chart_type(question)
     )
     |> stream(:segments, answers, reset: true)
     |> stream(:columns, answers, reset: true)
     |> stream(:table, answers, reset: true)
     |> stream(:answers, answers, reset: true)
     |> stream(:related, related, reset: true)}
  end

  defp chart_type(nil), do: "bars"
  defp chart_type(%{question_type: :ordered_scale}), do: "columns"
  defp chart_type(%{question_type: :multiple_select}), do: "bars"
  defp chart_type(%{answers: answers}) when length(answers) <= 6, do: "donut"
  defp chart_type(_), do: "bars"

  defp chart_answers(question) do
    {answers, _} =
      question.answers
      |> Enum.with_index()
      |> Enum.map_reduce(0, fn {answer, index}, offset ->
        share = if question.total > 0, do: answer.count / question.total * 100, else: 0

        {Map.merge(answer, %{
           index: index,
           color: Enum.at(@colors, rem(index, length(@colors))),
           share: share,
           offset: -offset
         }), offset + share}
      end)

    answers
  end

  defp result_path(question, view, metric) do
    params =
      %{"view" => view, "metric" => metric}
      |> Enum.reject(fn pair -> pair in [{"view", "chart"}, {"metric", "percentage"}] end)
      |> Map.new()

    if params == %{},
      do: ~p"/questions/#{question.slug}",
      else: ~p"/questions/#{question.slug}?#{params}"
  end

  defp topic_path(nil), do: ~p"/"
  defp topic_path(topic), do: ~p"/?#{%{topic: topic}}"

  defp format_name(kind),
    do:
      %{
        binary: "Two options",
        single_choice: "Single choice",
        multiple_select: "Multiple selections",
        ordered_scale: "Ordered scale"
      }[kind]

  defp value(answer, "count"), do: number(answer.count)
  defp value(answer, _), do: "#{answer.percentage}%"
end
