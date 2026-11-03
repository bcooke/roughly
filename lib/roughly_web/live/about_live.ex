defmodule RoughlyWeb.AboutLive do
  use RoughlyWeb, :live_view

  @impl true
  def mount(_params, _session, socket), do: {:ok, assign(socket, :page_title, "About")}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      socket={@socket}
      page_metadata={RoughlyWeb.PageMetadata.default("/about", "About Roughly")}
    >
      <article class="about-page">
        <h1 id="about-title">About Roughly</h1>
        <p>
          Roughly is a project to build an open collection of the world’s percentages: answers to questions about people’s preferences, habits, and experiences.
        </p>
        <p>
          Each question has a page with answer choices, response counts, and a breakdown of the responses. You can <.link navigate={
            ~p"/"
          }>search for a question or browse by topic</.link>.
        </p>
        <h2>What the numbers describe</h2>
        <p>
          Some questions concern preferences. Others ask about something a person has done or experienced, such as whether they have swum in the ocean. Roughly is interested in both.
        </p>
        <p>
          The answers depend on who takes part, how a question is asked, and how the data is collected. A percentage of respondents does not automatically describe the wider population.
        </p>
        <p>
          The <.link id="about-guide" navigate={~p"/guide"}>Guide to Roughly</.link>
          explains the definitions, evidence, and ideas behind the project.
        </p>
        <h2>An open project</h2>
        <p>
          Roughly is free and open source. The aim is to build a shared resource without a commercial incentive shaping the data.
        </p>
        <p>
          The
          <a id="about-source" href="https://github.com/bcooke/roughly">source code and project documentation</a>
          are public. Contributions to the software, questions, and research methods are welcome.
        </p>
      </article>
    </Layouts.app>
    """
  end
end
