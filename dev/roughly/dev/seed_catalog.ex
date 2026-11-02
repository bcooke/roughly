defmodule Roughly.Dev.SeedCatalog do
  @moduledoc "Curated question scenarios and invented answer weights for local development."

  alias Roughly.Dev.Identity
  alias Roughly.Questions.Instrument

  @external_resource "dev/roughly/dev/questions.json"
  @questions "dev/roughly/dev/questions.json" |> File.read!() |> Jason.decode!(keys: :atoms)

  def questions do
    Enum.map(@questions, fn question ->
      slug = Instrument.slug_base(question.text)

      question
      |> Map.put(:question_type, kind(question))
      |> Map.put(:slug, slug)
      |> Map.put(:uuid, Identity.uuid("question:#{slug}"))
    end)
  end

  defp kind(%{question_type: "ordered_scale"}), do: :ordered_scale
  defp kind(%{question_type: "multiple_select"}), do: :multiple_select
  defp kind(%{options: [_, _]}), do: :binary
  defp kind(_), do: :single_choice
end
