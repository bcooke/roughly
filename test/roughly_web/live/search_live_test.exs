defmodule RoughlyWeb.SearchLiveTest do
  use RoughlyWeb.ConnCase
  import Phoenix.LiveViewTest
  import Roughly.QuestionFixtures

  setup do
    q = question(%{text: "Do you like the taste of coffee?", slug: "coffee"})
    response_fixture(q, "Yes")
    question(%{text: "Do you like tea?", slug: "tea", category: "Technology"})
    :ok
  end

  test "full results show evidence previews, matching topics and a global search entry", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, "/search?q=coffee")
    assert has_element?(view, "#search-results a[href='/questions/coffee']")
    assert has_element?(view, "#search-results", "100.0%")
    assert has_element?(view, "#search-results", "1 response")
    assert has_element?(view, "#search-topic-food-drink")
    assert has_element?(view, "#nav-search-fallback[href='/search']")
    assert has_element?(view, "#site-search[data-name='SearchBox']")
  end

  test "query refinement and format filters update shareable URLs", %{conn: conn} do
    {:ok, view, _} = live(conn, "/search?q=cofee")
    assert has_element?(view, "#search-results a[href='/questions/coffee']")
    view |> form("#full-search-form", q: "coffee", format: "multiple_select") |> render_change()
    assert_patch(view, "/search?format=multiple_select&q=coffee")
    assert has_element?(view, "#search-no-results")
    view |> element("#search-reset-filters") |> render_click()
    assert has_element?(view, "#search-results a[href='/questions/coffee']")
  end
end
