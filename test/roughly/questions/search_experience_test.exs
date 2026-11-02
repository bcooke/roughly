defmodule Roughly.SearchExperienceTest do
  use Roughly.DataCase, async: true
  import Roughly.QuestionFixtures

  test "ranked search finds typos, word variants and question-style queries" do
    coffee = question(%{text: "Do you like the taste of coffee?", slug: "coffee"})
    question(%{text: "Do you like the taste of tea?", slug: "tea"})
    assert %{entries: [%{uuid: id}]} = Roughly.Search.search("cofee")
    assert id == coffee.uuid
    assert %{entries: [%{uuid: ^id}]} = Roughly.Search.search("liking coffee")

    assert %{entries: [%{uuid: ^id}]} =
             Roughly.Search.search("What percentage of people like coffee?")

    assert %{entries: []} = Roughly.Search.search("%")
    assert %{entries: []} = Roughly.Search.search("coffee tea")
  end

  test "suggestions separate public questions and topics and respect format filters" do
    q = question(%{text: "Do you like coffee?", slug: "coffee"})
    response_fixture(q, "Yes")
    suggestions = Roughly.Search.suggest("coffee")

    assert %{
             query: "coffee",
             questions: [%{slug: "coffee", total: 1}],
             topics: [%{name: "Food & drink"}],
             total: 1
           } = suggestions

    refute Map.has_key?(hd(suggestions.questions), :principal_uuid)
    assert %{entries: []} = Roughly.Search.search("coffee", format: "multiple_select")
  end
end
