defmodule Roughly.Search.Queries.Matches do
  @moduledoc "Ranked lexical, stemmed and typo-tolerant retrieval over public instrument projections."
  import Ecto.Query
  alias Roughly.{Repo, Questions.Queries.Base, Analysis.Queries.Results}

  @formats %{
    "binary" => :binary,
    "single_choice" => :single_choice,
    "multiple_select" => :multiple_select,
    "ordered_scale" => :ordered_scale
  }

  @spec page(String.t(), keyword()) :: Roughly.Analysis.Result.page()
  def page(query, opts) do
    matching = base(query, opts)
    topic = Keyword.get(opts, :category, "All topics")

    matching =
      if topic == "All topics", do: matching, else: where(matching, [q], q.category == ^topic)

    total = Repo.aggregate(matching, :count)
    size = opts |> Keyword.get(:page_size, 20) |> max(1) |> min(48)
    pages = max(1, ceil(total / size))
    page = opts |> Keyword.get(:page, 1) |> max(1) |> min(pages)
    pattern = pattern(query)

    entries =
      from(q in matching,
        order_by: [
          desc:
            fragment(
              "CASE WHEN lower(?) = lower(?) THEN 12 ELSE 0 END + CASE WHEN ? ILIKE ? THEN 5 ELSE 0 END + ts_rank_cd(to_tsvector('english', ?), websearch_to_tsquery('english', ?)) * 8 + word_similarity(?, ?)",
              q.text,
              ^query,
              q.text,
              ^pattern,
              q.search_document,
              ^query,
              ^query,
              q.search_document
            ),
          asc: q.uuid
        ],
        limit: ^size,
        offset: ^((page - 1) * size)
      )
      |> Repo.all()
      |> Results.attach()

    %{entries: entries, total: total, page: page, total_pages: pages}
  end

  @spec topics(String.t(), keyword()) :: [%{name: String.t(), count: non_neg_integer()}]
  def topics(query, opts \\ []) do
    from(q in base(query, opts),
      where: not is_nil(q.category),
      group_by: q.category,
      order_by: [desc: count(q.uuid), asc: q.category],
      select: %{name: q.category, count: count(q.uuid)}
    )
    |> Repo.all()
  end

  @spec base(String.t(), keyword()) :: Ecto.Query.t()
  def base(query, opts) do
    text = intent(query)

    matching =
      Enum.reduce(String.split(text, ~r/\s+/u, trim: true), Base.query(), fn term, result ->
        pattern = pattern(term)

        where(
          result,
          [q],
          fragment("numnode(plainto_tsquery('english', ?)) = 0", ^term) or
            fragment(
              "to_tsvector('english', ?) @@ plainto_tsquery('english', ?)",
              q.search_document,
              ^term
            ) or
            ilike(q.search_document, ^pattern) or fragment("? <<% ?", ^term, q.search_document)
        )
      end)

    pattern = pattern(text)

    matching =
      where(
        matching,
        [q],
        fragment("numnode(websearch_to_tsquery('english', ?)) > 0", ^text) or
          ilike(q.search_document, ^pattern)
      )

    case Map.get(@formats, Keyword.get(opts, :format, "all")) do
      nil -> matching
      kind -> where(matching, [q], q.question_type == ^kind)
    end
  end

  defp pattern(value),
    do: "%" <> String.replace(value, ["\\", "%", "_"], fn char -> "\\" <> char end) <> "%"

  defp intent(query),
    do:
      Regex.replace(
        ~r/^(?:what (?:percentage|percent) of|how many) (?:people|respondents)\s+/iu,
        query,
        ""
      )
end
