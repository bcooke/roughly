defmodule RoughlyWeb.SearchLive do
  use RoughlyWeb, :live_view
  import RoughlyWeb.Format, only: [number: 1]
  alias Roughly.Search

  @formats [
    {"All formats", "all"},
    {"Two options", "binary"},
    {"Single choice", "single_choice"},
    {"Multiple selections", "multiple_select"},
    {"Ordered scale", "ordered_scale"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:results, dom_id: &"search-result-#{&1.uuid}")
     |> stream_configure(:topics, dom_id: &"search-topic-#{topic_id(&1.name)}")}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    query = params |> text("q", "") |> Search.normalize()
    category = text(params, "topic", "All topics")
    format = text(params, "format", "all")
    format = if format in Enum.map(@formats, &elem(&1, 1)), do: format, else: "all"

    page =
      case Integer.parse(text(params, "page", "1")) do
        {value, ""} -> value
        _ -> 1
      end

    result = Search.search(query, category: category, format: format, page: page)

    entries =
      result.entries
      |> Enum.with_index((result.page - 1) * 20 + 1)
      |> Enum.map(fn {entry, position} -> Map.put(entry, :position, position) end)

    {:noreply,
     socket
     |> assign(
       query: query,
       category: category,
       format: format,
       count: result.total,
       page: result.page,
       pages: result.total_pages,
       formats: @formats,
       page_title: if(query == "", do: "Search", else: "#{query} · Search"),
       form: to_form(%{"q" => query, "format" => format})
     )
     |> stream(:results, entries, reset: true)
     |> stream(:topics, Search.topics(query, format: format), reset: true)}
  end

  @impl true
  def handle_event(event, params, socket) when event in ["refine", "submit"] do
    query = text(params, "q", "")
    format = text(params, "format", "all")

    {:noreply,
     push_patch(socket,
       to: ~p"/search?#{filters(query, socket.assigns.category, format)}",
       replace: event == "refine"
     )}
  end

  defp filters(query, topic, format, page \\ 1) do
    %{"q" => query, "topic" => topic, "format" => format, "page" => page}
    |> Enum.reject(fn {key, value} ->
      value == "" or {key, value} in [{"topic", "All topics"}, {"format", "all"}, {"page", 1}]
    end)
    |> Map.new()
  end

  defp text(params, key, default) do
    case Map.get(params, key, default) do
      value when is_binary(value) -> value
      _ -> default
    end
  end

  defp topic_id(name), do: Roughly.Questions.Instrument.slug_base(name)
  defp leading(%{total: 0}), do: nil
  defp leading(question), do: Enum.max_by(question.answers, & &1.count, fn -> nil end)

  defp format_name(kind),
    do:
      %{
        binary: "Two options",
        single_choice: "Single choice",
        multiple_select: "Multiple selections",
        ordered_scale: "Ordered scale"
      }[kind]
end
