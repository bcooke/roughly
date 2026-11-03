defmodule RoughlyWeb.QuestionLiveTest do
  use RoughlyWeb.ConnCase
  import Phoenix.LiveViewTest
  import Roughly.QuestionFixtures

  test "questions without a topic remain explorable", %{conn: conn} do
    question(%{slug: "uncategorized", category: nil})
    {:ok, view, _} = live(conn, "/questions/uncategorized")
    assert has_element?(view, "#question-title")
    assert has_element?(view, ".question-breadcrumb a[href='/']", "All topics")
  end

  test "single choice has a distribution and a shareable exact-count table", %{conn: conn} do
    q = question(%{slug: "coffee"})
    response_fixture(q, "Yes")
    response_fixture(q, "No")
    {:ok, view, _} = live(conn, "/questions/coffee")
    assert has_element?(view, "#distribution-chart[data-chart='bars']")
    assert has_element?(view, "#answer-0", "50.0%")
    view |> element("#view-table") |> render_click()
    assert_patch(view, "/questions/coffee?view=table")
    assert has_element?(view, "#answer-table tbody tr", "Yes")
    assert has_element?(view, "#answer-table tbody tr", "1")
    refute has_element?(view, "#distribution-chart")
    view |> element("#view-chart") |> render_click()
    assert has_element?(view, "#distribution-chart")
  end

  test "multiple selections use independent shares, never a part-to-whole chart", %{conn: conn} do
    q = question(%{slug: "activities", question_type: :multiple_select})
    response_fixture(q, ["Yes", "No"])
    response_fixture(q, ["Yes", "It depends"])
    {:ok, view, _} = live(conn, "/questions/activities")
    assert has_element?(view, "#distribution-chart[data-chart='bars']")
    assert has_element?(view, "#answer-0", "100.0%")
    assert has_element?(view, "#multiple-selection-method", "more than 100%")
    assert has_element?(view, "#response-total", "2 responses")
  end

  test "ordered scales retain instrument order and empty results have no invented leader", %{
    conn: conn
  } do
    q = question(%{slug: "scale", question_type: :ordered_scale})
    {:ok, view, _} = live(conn, "/questions/scale")
    assert has_element?(view, "#no-responses")
    refute has_element?(view, "#leading-answer")
    response_fixture(q, "No")
    {:ok, view, _} = live(conn, "/questions/scale")
    assert has_element?(view, "#distribution-chart[data-chart='columns']")
    assert has_element?(view, "#scale-column-0", "Yes")
    assert has_element?(view, "#scale-column-1", "No")
    assert has_element?(view, "#scale-column-2", "It depends")
  end
end
