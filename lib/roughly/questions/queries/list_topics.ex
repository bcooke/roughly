defmodule Roughly.Questions.Queries.ListTopics do
  @moduledoc "Lists topics and their browsable question counts."
  import Ecto.Query
  alias Roughly.Repo
  alias Roughly.Questions.Queries.Base

  def call do
    from(q in Base.query(),
      where: not is_nil(q.category),
      group_by: q.category,
      order_by: q.category,
      select: %{name: q.category, count: count(q.uuid)}
    )
    |> Repo.all()
  end
end
