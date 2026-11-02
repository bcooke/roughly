defmodule Roughly.Questions.Queries.GetQuestion do
  @moduledoc "Finds a question and aggregate answer counts by its stable slug."
  import Ecto.Query
  alias Roughly.Repo
  alias Roughly.Questions.Queries.Base
  alias Roughly.Analysis.Queries.Results

  @spec call(String.t()) :: Roughly.Analysis.Result.t() | nil
  def call(slug) do
    case Repo.one(from(q in Base.published(), where: q.slug == ^slug)) do
      nil -> nil
      question -> question |> List.wrap() |> Results.attach() |> hd()
    end
  end
end
