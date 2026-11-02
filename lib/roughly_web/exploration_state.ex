defmodule RoughlyWeb.ExplorationState do
  @moduledoc "Bounded URL state for evidence exploration, shared across view transitions."
  @spec parse(map()) :: map()
  def parse(params) do
    date = date(text(params, "as_of", ""))
    cutoff = cutoff(date)

    source = source(text(params, "population", ""))
    option = option(source, text(params, "option", ""))
    comparison = source(text(params, "compare", ""))
    axis = if text(params, "axis", "date") == "responses", do: :responses, else: :date

    basis =
      if axis == :responses || text(params, "basis", "answered") == "recorded",
        do: :recorded,
        else: :answered

    months = months(text(params, "months", "12"))

    %{
      cutoff: cutoff,
      as_of: date,
      source: source,
      option: option,
      comparison: comparison,
      population: if(source && option, do: {source.uuid, option.id}),
      basis: basis,
      axis: axis,
      months: months
    }
  end

  @spec parameters(map()) :: map()
  def parameters(state) do
    %{
      "as_of" => if(state.as_of, do: Date.to_iso8601(state.as_of)),
      "population" => if(state.population, do: state.source.slug),
      "option" => if(state.population, do: state.option.id),
      "compare" => if(state.comparison, do: state.comparison.slug),
      "basis" => if(state.basis == :recorded, do: "recorded"),
      "axis" => if(state.axis == :responses, do: "responses"),
      "months" => if(state.months != 12, do: to_string(state.months))
    }
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp date(value) do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        if Date.compare(date, Date.utc_today()) == :gt, do: Date.utc_today(), else: date

      _ ->
        nil
    end
  end

  defp cutoff(nil), do: DateTime.utc_now()

  defp cutoff(date) do
    time = DateTime.new!(date, ~T[23:59:59.999999])
    now = DateTime.utc_now()
    if DateTime.compare(time, now) == :gt, do: now, else: time
  end

  defp option(nil, _), do: nil
  defp option(source, id), do: Enum.find(source.answers, &(&1.id == id))
  defp months("3"), do: 3
  defp months("6"), do: 6
  defp months("24"), do: 24
  defp months(_), do: 12
  defp source(""), do: nil
  defp source(slug), do: Roughly.Questions.get_question(slug)

  defp text(params, key, default) do
    case Map.get(params, key, default) do
      value when is_binary(value) -> String.slice(value, 0, 160)
      _ -> default
    end
  end
end
