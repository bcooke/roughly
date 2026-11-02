defmodule Roughly.Dev.SeedCatalog do
  @moduledoc "Curated question scenarios and invented answer weights for local development."

  alias Roughly.Dev.Identity
  alias Roughly.Questions.Instrument

  @external_resource "dev/roughly/dev/questions.json"
  @questions "dev/roughly/dev/questions.json" |> File.read!() |> Jason.decode!(keys: :atoms)

  def questions do
    Enum.map(@questions, fn question ->
      slug = Instrument.slug_base(question.text)
      question |> Map.put(:slug, slug) |> Map.put(:uuid, Identity.uuid("question:#{slug}"))
    end)
  end
end
