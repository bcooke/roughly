defmodule Roughly.Preview.Queries.GetQuestion do
  @moduledoc "Finds a synthetic question by its stable slug."

  alias Roughly.Preview.Catalog

  def call(slug), do: Enum.find(Catalog.all(), &(&1.slug == slug))
end
