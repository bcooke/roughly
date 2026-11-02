defmodule Roughly.Questions.QueriesTest do
  use Roughly.DataCase, async: true
  import Roughly.QuestionFixtures
  alias Roughly.Questions

  test "search and topics filter persisted questions with bounded pages" do
    coffee = question(%{slug: "coffee"})
    question(%{text: "Do you prefer tea?", slug: "tea"})
    question(%{text: "Do you prefer TypeScript?", slug: "typescript", category: "Technology"})
    question(%{slug: "closed", status: :closed})
    question(%{slug: nil})
    assert %{entries: [%{uuid: id}], total: 1} = Questions.list_questions(search: "COFFEE")
    assert id == coffee.uuid

    assert %{entries: [], total: 0} =
             Questions.list_questions(search: "coffee", category: "Technology")

    assert %{entries: entries, total: 3, page: 2, total_pages: 2} =
             Questions.list_questions(page: 2, page_size: 2)

    assert length(entries) == 1

    assert [%{name: "Food & drink", count: 2}, %{name: "Technology", count: 1}] =
             Questions.list_topics()
  end

  test "results count active responses and include zero-count answers without exposing identities" do
    q = question(%{slug: "coffee"})
    response_fixture(q, "Yes")
    response_fixture(q, "Yes")
    response_fixture(q, "No")
    response_fixture(q, "No", %{status: :withdrawn})
    result = Questions.get_question("coffee")
    assert result.total == 3

    assert [
             %{label: "Yes", count: 2, percentage: 66.7},
             %{label: "No", count: 1, percentage: 33.3},
             %{label: "It depends", count: 0, percentage: +0.0}
           ] = result.answers

    refute Map.has_key?(result, :principal_uuid)
    assert Questions.get_question("missing") == nil
  end

  test "unanswered questions produce zero percentages and related questions exclude the current one" do
    q = question(%{slug: "coffee"})
    question(%{slug: "tea", text: "Do you like tea?"})
    result = Questions.get_question(q.slug)
    assert result.total == 0
    assert Enum.all?(result.answers, &(&1.percentage == 0.0))
    assert [%{slug: "tea"}] = Questions.related_questions(result)
    assert %{entries: [], total: 0} = Questions.list_questions(search: "%")
  end

  test "multiple selections use respondent denominators rather than selection totals" do
    q = question(%{question_type: :multiple_select})
    response_fixture(q, ["Yes", "No"])
    response_fixture(q, ["No"])
    result = Questions.get_question(q.slug)
    assert result.total == 2
    assert Enum.find(result.answers, &(&1.label == "Yes")).percentage == 50.0
    assert Enum.find(result.answers, &(&1.label == "No")).percentage == 100.0
    assert Enum.sum(Enum.map(result.answers, & &1.percentage)) == 150.0
  end
end
