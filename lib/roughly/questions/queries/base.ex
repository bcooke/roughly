defmodule Roughly.Questions.Queries.Base do
  @moduledoc "Shared visibility rules for browsable question projections."
  import Ecto.Query
  alias Roughly.Questions.Projections.Question

  def query, do: from(q in Question, where: q.status == :active and not is_nil(q.slug))
end
