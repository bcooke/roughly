defmodule Roughly.Questions.Queries.ListQuestions do
  @moduledoc "Bounded search and topic browsing over persisted read models."
  import Ecto.Query
  alias Roughly.Repo
  alias Roughly.Questions.Queries.Base
  alias Roughly.Analysis.Queries.Results

  @spec call(keyword()) :: %{
          entries: [Roughly.Analysis.Result.t()],
          total: non_neg_integer(),
          page: pos_integer(),
          total_pages: pos_integer()
        }
  def call(filters \\ []) do
    query = Base.query() |> filter(filters)
    total = Repo.aggregate(query, :count)
    page_size = filters |> Keyword.get(:page_size, 24) |> max(1) |> min(48)
    total_pages = max(1, ceil(total / page_size))
    page = filters |> Keyword.get(:page, 1) |> max(1) |> min(total_pages)

    questions =
      query
      |> order_by([q], asc: q.inserted_at, asc: q.uuid)
      |> limit(^page_size)
      |> offset(^((page - 1) * page_size))
      |> Repo.all()

    %{entries: Results.attach(questions), total: total, page: page, total_pages: total_pages}
  end

  defp filter(query, filters) do
    search = filters |> Keyword.get(:search, "") |> String.trim()
    category = Keyword.get(filters, :category, "All topics")
    exclude = Keyword.get(filters, :exclude)

    query =
      if category == "All topics", do: query, else: where(query, [q], q.category == ^category)

    query = if exclude, do: where(query, [q], q.uuid != ^exclude), else: query

    if search == "" do
      query
    else
      escaped = String.replace(search, ["\\", "%", "_"], fn char -> "\\" <> char end)
      where(query, [q], ilike(q.text, ^("%" <> escaped <> "%")))
    end
  end
end
