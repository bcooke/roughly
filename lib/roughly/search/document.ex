defmodule Roughly.Search.Document do
  @moduledoc "A rebuildable public search document, never participant data."
  @spec build(String.t(), String.t() | nil, [Roughly.Questions.Option.t()]) :: String.t()
  def build(text, topic, options),
    do: Enum.join([text, topic || "" | Enum.map(options, & &1.label)], " ")
end
