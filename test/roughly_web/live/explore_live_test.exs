defmodule RoughlyWeb.ExploreLiveTest do
  use RoughlyWeb.ConnCase
  import Phoenix.LiveViewTest

  test "search and topic filters can be combined and cleared", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#preview-notice")
    assert has_element?(view, "#question-do-you-like-the-taste-of-coffee")

    view |> form("#question-search", search: %{q: "coffee"}) |> render_submit()
    assert has_element?(view, "#question-do-you-like-the-taste-of-coffee")
    refute has_element?(view, "#question-do-you-prefer-typescript-or-javascript")

    view |> element("#topic-technology") |> render_click()
    assert has_element?(view, "#empty-results")
    view |> element("#clear-filters") |> render_click()
    assert has_element?(view, "#question-do-you-prefer-typescript-or-javascript")
  end

  test "question links have readable results and stable citation anchors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/questions/do-you-like-the-taste-of-coffee")
    assert has_element?(view, "#question-title", "Do you like the taste of coffee?")
    assert has_element?(view, "#results")
    assert has_element?(view, "#methodology", "synthetic")
    assert has_element?(view, "#answer-0", "62.0%")
    assert has_element?(view, "#results-permalink[href$='#results']")
    refute has_element?(view, "form[phx-submit='vote']")
    refute has_element?(view, "#intuition-estimate")
  end

  test "unknown questions have a useful not-found state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/questions/unknown")
    assert has_element?(view, "#question-not-found")
  end
end
