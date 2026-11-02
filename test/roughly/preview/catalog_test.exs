defmodule Roughly.Preview.CatalogTest do
  use ExUnit.Case, async: true

  alias Roughly.Preview

  test "search combines topic and case-insensitive text filters" do
    questions = Preview.list_questions(search: "COFFEE", category: "Everyday life")
    assert [%{slug: "do-you-like-the-taste-of-coffee"}] = questions
    assert Preview.list_questions(search: "coffee", category: "Technology") == []
    assert Preview.list_questions(search: "no-such-question") == []
  end

  test "sample result percentages use the answer counts and expose their provenance" do
    question = Preview.get_question("do-you-like-the-taste-of-coffee")
    assert question.sample?
    assert question.total == Enum.sum(Enum.map(question.answers, & &1.count))

    assert Enum.all?(
             question.answers,
             &(&1.percentage == Float.round(&1.count / question.total * 100, 1))
           )

    assert Preview.get_question("missing") == nil
  end
end
