defmodule Roughly.Analysis.AnswerLinks do
  @moduledoc "Readable addresses for the immutable options of an exact instrument."
  @spec entries(Roughly.Analysis.Result.t()) :: [map()]
  def entries(question) do
    {answers, _} =
      Enum.map_reduce(question.answers, MapSet.new(), fn answer, used ->
        base = Roughly.Questions.Instrument.slug_base(answer.label)
        slug = available(base, used, 1)
        {Map.put(answer, :slug, slug), MapSet.put(used, slug)}
      end)

    answers
  end

  @spec find(Roughly.Analysis.Result.t(), String.t() | nil) :: map() | nil
  def find(_, nil), do: nil
  def find(question, slug), do: Enum.find(entries(question), &(&1.slug == slug))
  @spec path(Roughly.Analysis.Result.t(), String.t() | nil) :: String.t()
  def path(question, nil), do: "/questions/#{question.slug}"
  def path(question, answer), do: "/questions/#{question.slug}/answers/#{answer}"

  defp available(base, used, index) do
    slug = if index == 1, do: base, else: "#{base}-#{index}"
    if MapSet.member?(used, slug), do: available(base, used, index + 1), else: slug
  end
end
