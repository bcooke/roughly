defmodule RoughlyWeb.GuideLiveTest do
  use RoughlyWeb.ConnCase
  import Phoenix.LiveViewTest

  test "guide routes serve their own explanations and metadata without question records" do
    for path <- ~w(/guide /guide/percentages /guide/knowledge /guide/reading) do
      page = RoughlyWeb.GuidePages.for_path(path)
      doc = build_conn() |> get(path) |> html_response(200) |> LazyHTML.from_document()
      assert doc |> LazyHTML.query("#guide-title") |> LazyHTML.text() == page.title

      assert doc |> LazyHTML.query("#page-canonical") |> LazyHTML.attribute("href") == [
               RoughlyWeb.Endpoint.url() <> path
             ]

      assert doc |> LazyHTML.query("#page-description") |> LazyHTML.attribute("content") == [
               page.description
             ]

      assert doc |> LazyHTML.query("#page-robots") |> LazyHTML.attribute("content") == [
               "noindex,follow"
             ]
    end
  end

  test "readers can move from the guide into definitions and their sources", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/guide")

    {:ok, definitions, _} =
      view
      |> element("#guide-start a[href='/guide/percentages']")
      |> render_click()
      |> follow_redirect(conn)

    assert has_element?(definitions, "#percentage-definition", "Population")
    assert has_element?(definitions, "#percentage-evidence")

    assert has_element?(
             definitions,
             "#guide-navigation a[aria-current='page'][href='/guide/percentages']"
           )

    {:ok, reading, _} =
      definitions
      |> element("#guide-navigation a[href='/guide/reading']")
      |> render_click()
      |> follow_redirect(conn)

    assert has_element?(reading, "#reading-crowds")
    assert has_element?(reading, "#reading-language")

    assert has_element?(
             reading,
             "#guide-article a[href='https://www.fooledbyrandomness.com/glossary.pdf']"
           )
  end

  test "unpublished guide addresses do not become empty articles", %{conn: conn} do
    assert conn |> get("/guide/not-an-article") |> response(404)
  end
end
