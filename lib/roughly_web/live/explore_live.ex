defmodule RoughlyWeb.ExploreLive do
  use RoughlyWeb, :live_view

  alias Roughly.Preview

  @topics ["All topics", "Everyday life", "Technology", "Places", "Work & learning", "Culture"]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, topics: @topics, page_title: "Explore the world's percentages")}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    search = Map.get(params, "q", "")
    category = Map.get(params, "topic", "All topics")
    questions = Preview.list_questions(search: search, category: category)

    {:noreply,
     socket
     |> assign(search: search, category: category, count: length(questions))
     |> assign(:form, to_form(%{"q" => search}, as: :search))
     |> stream(:questions, questions, reset: true, dom_id: &"question-#{&1.slug}")}
  end

  @impl true
  def handle_event("search", %{"search" => %{"q" => search}}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?#{filters(search, socket.assigns.category)}")}
  end

  defp filters(search, topic) do
    %{"q" => search, "topic" => topic}
    |> Enum.reject(fn {key, value} ->
      value == "" or (key == "topic" and value == "All topics")
    end)
    |> Map.new()
  end

  defp topic_id(topic) do
    topic |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-")
  end

  defp number(value),
    do:
      value
      |> Integer.to_charlist()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.reverse()
      |> Enum.join(",")
end
