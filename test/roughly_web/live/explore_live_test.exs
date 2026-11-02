defmodule RoughlyWeb.ExploreLiveTest do
  use RoughlyWeb.ConnCase
  import Phoenix.LiveViewTest
  import Roughly.QuestionFixtures

  setup do
    coffee = question(%{slug: "do-you-like-the-taste-of-coffee"})

    question(%{
      text: "Do you prefer TypeScript or JavaScript?",
      slug: "do-you-prefer-typescript-or-javascript",
      category: "Technology"
    })

    response_fixture(coffee, "Yes")
    response_fixture(coffee, "No")
    :ok
  end

  test "search and topic filters can be combined and cleared", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#question-do-you-like-the-taste-of-coffee")
    refute has_element?(view, "#preview-notice")
    refute has_element?(view, ".sample-label")
    view |> form("#question-search", search: %{q: "coffee"}) |> render_submit()
    refute has_element?(view, "#question-do-you-prefer-typescript-or-javascript")
    view |> element("#topic-technology") |> render_click()
    assert has_element?(view, "#empty-results")
    view |> element("#clear-filters") |> render_click()
    assert has_element?(view, "#question-do-you-prefer-typescript-or-javascript")
  end

  test "results show persisted response counts and related questions", %{conn: conn} do
    question(%{text: "Do you drink tea?", slug: "tea"})
    {:ok, view, _html} = live(conn, ~p"/questions/do-you-like-the-taste-of-coffee")
    assert has_element?(view, "#question-title", "Do you like the taste of coffee?")
    assert has_element?(view, "#response-total", "2 responses")
    assert has_element?(view, "#answer-0", "50.0%")
    assert has_element?(view, "#related-tea")
    assert has_element?(view, "#results-permalink[href$='#results']")
    refute has_element?(view, "#preview-notice")
    refute has_element?(view, "#intuition-estimate")
  end

  test "pagination preserves a topic filter", %{conn: conn} do
    for index <- 1..25,
        do:
          question(%{
            text: "Question #{index}?",
            slug: "question-#{index}",
            category: "Technology"
          })

    {:ok, view, _html} = live(conn, ~p"/?topic=Technology")
    assert has_element?(view, "#next-page")
    view |> element("#next-page") |> render_click()
    assert_patch(view, ~p"/?page=2&topic=Technology")
    assert has_element?(view, "#previous-page")
  end

  test "unknown questions have a useful not-found state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/questions/unknown")
    assert has_element?(view, "#question-not-found")
  end

  test "about is reachable from the site navigation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#nav-about[href='/about']")
    {:ok, about, _html} = live(conn, ~p"/about")
    assert has_element?(about, "#about-title", "About Roughly")
    assert has_element?(about, "#about-source[href='https://github.com/bcooke/roughly']")
  end
end
