defmodule Roughly.Search do
  @moduledoc "Public discovery contracts, shared by suggestions and full search results."
  alias Roughly.Search.Queries.Matches
  @type topic :: %{name: String.t(), count: non_neg_integer()}
  @type suggestions :: %{
          query: String.t(),
          questions: [Roughly.Analysis.Result.t()],
          topics: [topic()],
          total: non_neg_integer()
        }

  @spec normalize(String.t()) :: String.t()
  def normalize(query), do: query |> String.trim() |> String.slice(0, 200)
  @spec search(String.t(), keyword()) :: Roughly.Analysis.Result.page()
  def search(query, opts \\ []) do
    case normalize(query) do
      "" -> %{entries: [], total: 0, page: 1, total_pages: 1}
      text -> Matches.page(text, opts)
    end
  end

  @spec topics(String.t(), keyword()) :: [topic()]
  def topics(query, opts \\ []), do: Matches.topics(normalize(query), opts)
  @spec suggest(String.t()) :: suggestions()
  def suggest(query) do
    text = normalize(query)

    if text == "" do
      %{
        query: "",
        questions: [],
        topics: Roughly.Questions.list_topics() |> Enum.take(6),
        total: 0
      }
    else
      page = search(text, page_size: 6)

      %{
        query: text,
        questions: page.entries,
        topics: topics(text) |> Enum.take(4),
        total: page.total
      }
    end
  end
end
