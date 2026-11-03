defmodule RoughlyWeb.GuideLive do
  use RoughlyWeb, :live_view
  alias RoughlyWeb.{GuidePages, PageMetadata}

  embed_templates "guide_live/*"

  @impl true
  def handle_params(_params, _uri, socket) do
    key = Atom.to_string(socket.assigns.live_action)
    page = GuidePages.get(key)
    {:noreply, assign(socket, page: page, article: key, page_title: page.title)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} socket={@socket} page_metadata={PageMetadata.for_guide(@page)}>
      <div id="guide-layout" class="guide-layout">
        <aside class="guide-sidebar">
          <.link navigate={~p"/guide"} class="guide-label">Guide</.link>
          <nav id="guide-navigation" aria-label="Guide">
            <.link navigate={~p"/guide"} aria-current={@article == "index" && "page"}>Start here</.link>
            <.link
              navigate={~p"/guide/percentages"}
              aria-current={@article == "percentages" && "page"}
            >What a percentage describes</.link>
            <.link navigate={~p"/guide/knowledge"} aria-current={@article == "knowledge" && "page"}>What can we know?</.link>
            <.link navigate={~p"/guide/reading"} aria-current={@article == "reading" && "page"}>Ideas and sources</.link>
          </nav>
          <a
            class="guide-contribute"
            href="https://github.com/bcooke/roughly/blob/main/CONTRIBUTING.md"
          >Contribute to Roughly <.icon name="hero-arrow-up-right" class="size-3" /></a>
        </aside>
        <article id="guide-article" class="guide-article" aria-labelledby="guide-title">
          <h1 id="guide-title">{@page.title}</h1>
          <%= case @article do %>
            <% "index" -> %>
              <.overview />
            <% "percentages" -> %>
              <.percentages />
            <% "knowledge" -> %>
              <.knowledge />
            <% "reading" -> %>
              <.reading />
          <% end %>
        </article>
      </div>
    </Layouts.app>
    """
  end
end
