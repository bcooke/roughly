defmodule Roughly.Preview.Queries.ListQuestions do
  @moduledoc "Searches synthetic questions by text and topic."

  alias Roughly.Preview.Catalog

  def call(filters \\ []) do
    search = filters |> Keyword.get(:search, "") |> String.trim() |> String.downcase()
    category = Keyword.get(filters, :category, "All topics")

    Enum.filter(Catalog.all(), fn question ->
      String.contains?(String.downcase(question.text), search) and
        category in ["All topics", question.category]
    end)
  end
end
