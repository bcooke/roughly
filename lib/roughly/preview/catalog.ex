defmodule Roughly.Preview.Catalog do
  @moduledoc "Synthetic aggregates for interface development, separate from event history."

  @external_resource "priv/preview/questions.json"
  @questions "priv/preview/questions.json" |> File.read!() |> Jason.decode!(keys: :atoms)

  def all do
    Enum.map(@questions, fn question ->
      total = Enum.sum(Enum.map(question.answers, & &1.count))

      answers =
        Enum.map(question.answers, fn answer ->
          Map.put(answer, :percentage, Float.round(answer.count / total * 100, 1))
        end)

      question
      |> Map.put(:answers, answers)
      |> Map.put(:total, total)
      |> Map.put(:sample?, true)
    end)
  end
end
