defmodule RoughlyWeb.SearchComponents do
  @moduledoc "Shared search entry points and safe query highlighting."
  use RoughlyWeb, :html

  attr :id, :string, required: true
  attr :mode, :string, values: ["hero", "header"], required: true
  attr :socket, :any, required: true

  def box(assigns) do
    ~H"""
    <.vue id={@id} v-component="SearchBox" v-socket={@socket} v-ssr={false} mode={@mode}>
      <:search_icon><.icon name="hero-magnifying-glass" class="size-5" /></:search_icon>
      <:close_icon><.icon name="hero-x-mark" class="size-4" /></:close_icon>
      <:arrow_icon><.icon name="hero-arrow-right" class="size-4" /></:arrow_icon>
      <:question_icon><.icon name="hero-chart-bar" class="size-5" /></:question_icon>
      <:topic_icon><.icon name="hero-hashtag" class="size-5" /></:topic_icon>
      <:history_icon><.icon name="hero-clock" class="size-5" /></:history_icon>
    </.vue>
    """
  end

  attr :text, :string, required: true
  attr :query, :string, required: true

  def highlight(assigns) do
    terms = assigns.query |> String.split(~r/\s+/u, trim: true) |> Enum.map(&Regex.escape/1)

    parts =
      if terms == [],
        do: [{assigns.text, false}],
        else:
          Regex.split(Regex.compile!("(" <> Enum.join(terms, "|") <> ")", "iu"), assigns.text,
            include_captures: true
          )
          |> Enum.with_index()
          |> Enum.map(fn {text, index} -> {text, rem(index, 2) == 1} end)

    assigns = assign(assigns, :parts, parts)

    ~H"""
    <span :for={{text, match?} <- @parts} class={match? && "search-mark"}>{text}</span>
    """
  end
end
