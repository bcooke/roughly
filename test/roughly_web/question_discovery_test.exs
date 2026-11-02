defmodule RoughlyWeb.QuestionDiscoveryTest do
  use RoughlyWeb.ConnCase
  import Roughly.QuestionFixtures
  import Phoenix.LiveViewTest

  test "answers are visible in initial HTML with canonical metadata and preview indexing protection",
       %{conn: conn} do
    q = question(%{slug: "coffee"})
    response_fixture(q, "Yes")
    conn = get(conn, "/questions/coffee")
    doc = conn |> html_response(200) |> LazyHTML.from_document()

    assert doc |> LazyHTML.query("#page-canonical") |> LazyHTML.attribute("href") == [
             RoughlyWeb.Endpoint.url() <> "/questions/coffee"
           ]

    assert doc |> LazyHTML.query("#page-robots") |> LazyHTML.attribute("content") == [
             "noindex,follow"
           ]

    assert doc |> LazyHTML.query("#answer-summary") |> LazyHTML.text() =~ "1 of 1 responses"
    assert doc |> LazyHTML.query("[itemtype='https://schema.org/Dataset']") |> Enum.count() == 1
    {:ok, view, _} = live(build_conn(), "/questions/coffee/answers/yes")
    assert has_element?(view, "#answer-summary", "100.0%")
    assert has_element?(view, "#answer-detail-title", "Yes")
    assert has_element?(view, "#trends")
    assert has_element?(view, "#population-comparison")
  end

  test "unknown option pages return 404 and fixture sitemaps expose no URLs", %{conn: conn} do
    question(%{slug: "coffee"})
    assert conn |> get("/questions/coffee/answers/unknown") |> response(404)
    assert conn |> get("/sitemaps/questions/1.xml") |> response(404)
    assert conn |> get("/sitemap.xml") |> response(404)
  end

  test "answer paths remain readable and unique when labels normalize to the same slug" do
    q =
      question(%{
        slug: "duplicates",
        options:
          Enum.map(
            ["Yes", "Yes!", "Yes 2"],
            &Roughly.Questions.Option.new(Ecto.UUID.generate(), &1)
          )
      })

    result = Roughly.Questions.get_question(q.slug)
    answers = Roughly.Analysis.AnswerLinks.entries(result)
    assert Enum.map(answers, & &1.slug) == ["yes", "yes-2", "yes-2-2"]
    assert Roughly.Analysis.Queries.CrawlPages.call() |> Enum.count() == 4
    assert Roughly.Analysis.AnswerLinks.find(result, "yes-2").id == Enum.at(q.options, 1).id
  end

  test "population drill-down, date cutoffs and focused answers preserve the evidence scope", %{
    conn: conn
  } do
    target = question(%{slug: "coffee"})
    source = question(%{slug: "groups", text: "Which group?"})
    [qualifying | _] = source.options

    for index <- 1..12 do
      principal = Ecto.UUID.generate()
      project(target, principal, if(index <= 10, do: "Yes", else: "No"), index * 2)
      if index <= 10, do: project(source, principal, "Yes", index * 2 + 1)
    end

    {:ok, view, _} = live(conn, "/questions/coffee?compare=groups")

    assert has_element?(
             view,
             "#comparison-denominator",
             "10 respondents answered both questions; 2 have no qualifying answer"
           )

    view |> element("#comparison-group-#{qualifying.id} a") |> render_click()
    assert has_element?(view, "#response-total", "10 responses")
    assert has_element?(view, "#answer-summary", "100.0%")
    assert has_element?(view, "#live-page-metadata[data-robots='noindex,follow']")

    assert has_element?(
             view,
             "#answer-0 a[href*='population=groups'][href^='/questions/coffee/answers/yes?']"
           )

    view
    |> form("#exploration-controls",
      as_of: "2026-01-31",
      basis: "answered",
      axis: "date",
      months: "12"
    )
    |> render_change()

    assert has_element?(view, "#insufficient-responses")
    refute has_element?(view, "#response-total", "0 responses")

    view
    |> form("#exploration-controls", as_of: "", basis: "answered", axis: "date", months: "12")
    |> render_change()

    redirect = view |> element("#answer-0 a") |> render_click()
    {:ok, focused, _} = follow_redirect(redirect, conn)
    assert has_element?(focused, "#answer-summary", "10 of 10 responses")
  end

  test "published discovery has bounded sitemap shards and filtered views stay noindex", %{
    conn: conn
  } do
    previous = Application.get_env(:roughly, :public_indexing)
    Application.put_env(:roughly, :public_indexing, true)
    on_exit(fn -> Application.put_env(:roughly, :public_indexing, previous) end)
    question(%{slug: "coffee"})
    sitemap = conn |> get("/sitemap.xml") |> response(200) |> LazyHTML.from_document()

    assert sitemap |> LazyHTML.query("loc") |> LazyHTML.text() ==
             RoughlyWeb.Endpoint.url() <> "/sitemaps/questions/1.xml"

    shard = conn |> get("/sitemaps/questions/1.xml") |> response(200) |> LazyHTML.from_document()
    assert shard |> LazyHTML.query("loc") |> Enum.count() == 4
    assert shard |> LazyHTML.query("loc") |> LazyHTML.text() =~ "/questions/coffee/answers/yes"

    doc =
      conn
      |> get("/questions/coffee?as_of=2026-01-01")
      |> html_response(200)
      |> LazyHTML.from_document()

    assert doc |> LazyHTML.query("#page-robots") |> LazyHTML.attribute("content") == [
             "noindex,follow"
           ]
  end

  test "response-count charts use receipt time and malformed URL state is bounded" do
    assert RoughlyWeb.ExplorationState.parse(%{"axis" => "responses", "basis" => "answered"}).basis ==
             :recorded

    state =
      RoughlyWeb.ExplorationState.parse(%{
        "population" => ["bad"],
        "months" => "999999",
        "as_of" => ["bad"]
      })

    assert state.population == nil
    assert state.months == 12
    assert state.as_of == nil
  end

  defp project(question, principal, label, number) do
    option = Enum.find(question.options, &(&1.label == label))

    Roughly.Participation.Projections.Projector.handle(
      %Roughly.Participation.Events.ResponseRecorded{
        response_uuid: Roughly.Participation.identity(question.uuid, principal),
        question_uuid: question.uuid,
        principal_uuid: principal,
        option_ids: [option.id],
        context: %Roughly.Participation.Context{
          answered_at: ~U[2026-02-01 00:00:00Z],
          field_sources: %{answered_at: :reported}
        }
      },
      %{
        handler_name: "web-#{question.uuid}",
        event_number: number,
        created_at: ~U[2026-02-01 00:00:00Z]
      }
    )
  end
end
