defmodule RoughlyWeb.GuidePages do
  @moduledoc "Public editorial routes and descriptions for the maintained Roughly guide."
  @pages %{
    "index" => %{
      title: "Guide to Roughly",
      path: "/guide",
      description:
        "Understand Roughly's questions, population proportions, evidence, and the ideas behind the project."
    },
    "percentages" => %{
      title: "What a percentage describes",
      path: "/guide/percentages",
      description:
        "A plain-language guide to conditions, populations, time, and the evidence behind a percentage."
    },
    "knowledge" => %{
      title: "What can we know?",
      path: "/guide/knowledge",
      description:
        "How Roughly distinguishes a meaningful question, a target quantity, recorded evidence, and an estimate."
    },
    "reading" => %{
      title: "Ideas and sources",
      path: "/guide/reading",
      description:
        "A reading map across knowledge, language, measurement, survey statistics, and collective intelligence."
    }
  }

  @spec get(String.t()) :: map() | nil
  def get(key), do: Map.get(@pages, key)

  @spec for_path(String.t()) :: map() | nil
  def for_path(path),
    do: Enum.find_value(@pages, fn {_, page} -> if page.path == path, do: page end)
end
