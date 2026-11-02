defmodule Roughly.Analysis.Queries.CrawlPages do
  @moduledoc "Bounded canonical discovery paths for public instruments and their answer views."
  import Ecto.Query
  alias Roughly.{Repo, Questions.Queries.Base}
  @spec call(pos_integer()) :: [String.t()]
  def call(page \\ 1) do
    from(q in Base.published(), order_by: q.slug, limit: 1_000, offset: ^((page - 1) * 1_000))
    |> Repo.all()
    |> Roughly.Analysis.Queries.Results.attach()
    |> Enum.flat_map(fn question ->
      [
        Roughly.Analysis.AnswerLinks.path(question, nil)
        | Enum.map(
            Roughly.Analysis.AnswerLinks.entries(question),
            &Roughly.Analysis.AnswerLinks.path(question, &1.slug)
          )
      ]
    end)
  end

  @spec count() :: non_neg_integer()
  def count, do: Repo.aggregate(Base.published(), :count)
end
