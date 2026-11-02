defmodule RoughlyWeb.ExploreLive do
  use RoughlyWeb, :live_view
  import RoughlyWeb.Format, only: [number: 1]
  alias Roughly.Questions

  @impl true
  def mount(_params, _session, socket) do
    topics = Questions.list_topics()
    {:ok, assign(socket, topics: topics, page_title: "Explore questions")}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    search = text_param(params, "q", "")
    category = text_param(params, "topic", "All topics")

    page =
      case Integer.parse(text_param(params, "page", "1")) do
        {value, ""} -> value
        _ -> 1
      end

    result = Questions.list_questions(search: search, category: category, page: page)

    {:noreply,
     socket
     |> assign(
       search: search,
       category: category,
       count: result.total,
       page: result.page,
       total_pages: result.total_pages
     )
     |> assign(:form, to_form(%{"q" => search}))
     |> stream(:questions, result.entries, reset: true, dom_id: &"question-#{&1.slug}")}
  end

  @impl true
  def handle_event("search", %{"q" => search}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?#{filters(search, socket.assigns.category)}")}
  end

  defp text_param(params, key, default) do
    case Map.get(params, key, default) do
      value when is_binary(value) -> value
      _ -> default
    end
  end

  defp filters(search, topic, page \\ 1) do
    %{"q" => search, "topic" => topic, "page" => page}
    |> Enum.reject(fn {key, value} ->
      value == "" or (key == "topic" and value == "All topics") or (key == "page" and value == 1)
    end)
    |> Map.new()
  end

  defp topic_id(topic),
    do: topic |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-")
end
