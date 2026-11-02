defmodule Roughly.Dev.SeedsTest do
  use ExUnit.Case, async: true
  alias Roughly.Dev.Seeds

  test "the catalog has diverse unique questions and deterministic valid responses" do
    catalog = Roughly.Dev.SeedCatalog.questions()
    assert length(catalog) >= 180
    assert catalog |> Enum.map(& &1.category) |> Enum.uniq() |> length() >= 16
    assert length(Enum.uniq_by(catalog, & &1.text)) == length(catalog)
    assert length(Enum.uniq_by(catalog, & &1.slug)) == length(catalog)
    first = hd(catalog)
    assert Seeds.responses(first) == Seeds.responses(first)

    assert Enum.all?(Seeds.responses(first), fn response ->
             length(response.option_ids) == 1 and response.context.mode == :development_fixture
           end)

    ids = Enum.map(Seeds.responses(first), & &1.principal_uuid)
    assert length(ids) == length(Enum.uniq(ids))
  end

  test "seeding is disabled unless explicitly enabled by development config" do
    assert_raise RuntimeError, ~r/development/, fn -> Seeds.run() end
  end
end
