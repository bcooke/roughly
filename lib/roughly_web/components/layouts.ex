defmodule RoughlyWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use RoughlyWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  attr :socket, :any, required: true
  attr :page_metadata, :map, default: nil

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <a href="#main-content" class="skip-link">Skip to content</a>
    <div
      id="live-page-metadata"
      phx-hook="PageMetadata"
      phx-update="ignore"
      hidden
      data-description={(@page_metadata || RoughlyWeb.PageMetadata.default()).description}
      data-canonical={(@page_metadata || RoughlyWeb.PageMetadata.default()).canonical}
      data-robots={(@page_metadata || RoughlyWeb.PageMetadata.default()).robots}
      data-title={(@page_metadata || RoughlyWeb.PageMetadata.default()).title}
    >
    </div>
    <header id="site-header" class="site-header">
      <.link navigate={~p"/"} class="wordmark" aria-label="Roughly home"><span aria-hidden="true">≈</span>
      roughly<span class="wordmark-period">.</span></.link>
      <nav aria-label="Main navigation">
        <.link id="nav-guide" navigate={~p"/guide"}>Guide</.link>
        <.link navigate={~p"/"} class="nav-explore">Questions</.link><.link
          id="nav-about"
          navigate={~p"/about"}
        >About</.link>
        <div class="site-search-control">
          <.link id="nav-search-fallback" navigate={~p"/search"} class="search-nav-fallback"><.icon
            name="hero-magnifying-glass"
            class="size-4"
          /> Search</.link><RoughlyWeb.SearchComponents.box
            id="site-search"
            mode="header"
            socket={@socket}
          />
        </div>
      </nav>
    </header>
    <main id="main-content">{render_slot(@inner_block)}</main>
    <footer class="site-footer">
      <.link navigate={~p"/"} class="footer-brand">roughly</.link><nav aria-label="Footer">
        <.link navigate={~p"/guide"}>Guide</.link><.link navigate={~p"/about"}>About</.link><a href="https://github.com/bcooke/roughly">GitHub</a>
      </nav>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
