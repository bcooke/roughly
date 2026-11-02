defmodule Roughly.Analysis do
  @moduledoc "Aggregate exploration over exact instruments, declared clocks and answer-defined populations."
  alias Roughly.Analysis.Queries.History
  @minimum_group 10
  @type point :: %{
          key: String.t(),
          label: String.t(),
          x: number(),
          total: non_neg_integer() | nil,
          answers: [map()]
        }

  @spec snapshot(Roughly.Analysis.Result.t(), keyword()) :: Roughly.Analysis.Result.t()
  defdelegate snapshot(question, opts \\ []), to: History

  @spec public_result(Roughly.Analysis.Result.t(), keyword()) :: map()
  def public_result(question, opts \\ []) do
    result = snapshot(question, opts)
    protect(result, not is_nil(Keyword.get(opts, :population)))
  end

  @spec compare(Roughly.Analysis.Result.t(), Roughly.Analysis.Result.t(), keyword()) :: map()
  def compare(target, source, opts \\ []) do
    base = snapshot(target, opts)
    eligible = History.matched_count(target.uuid, source.uuid, opts)

    groups =
      Enum.map(source.answers, fn answer ->
        result = snapshot(target, Keyword.put(opts, :population, {source.uuid, answer.id}))

        protect(result, true)
        |> Map.take([:total, :answers, :suppressed])
        |> Map.merge(%{id: answer.id, label: answer.label})
      end)

    %{source: source, eligible: eligible, missing: base.total - eligible, groups: groups}
  end

  @spec trend(Roughly.Analysis.Result.t(), keyword()) :: [point()]
  def trend(question, opts \\ []) do
    if Keyword.get(opts, :axis) == :responses do
      response_points(question, opts)
    else
      date_points(question, opts)
    end
  end

  @spec featured_comparisons() :: [Roughly.Analysis.Result.t()]
  def featured_comparisons do
    [
      "which-age-group-are-you-in",
      "how-do-you-describe-your-gender",
      "which-region-do-you-currently-live-in"
    ]
    |> Enum.map(&Roughly.Questions.get_question/1)
    |> Enum.reject(&is_nil/1)
  end

  defp protect(result, scoped?) do
    if scoped? && result.total < @minimum_group,
      do: result |> Map.merge(%{total: nil, answers: [], suppressed: true}),
      else: Map.put(result, :suppressed, false)
  end

  defp date_points(question, opts) do
    cutoff = Keyword.get(opts, :cutoff, DateTime.utc_now())
    date = DateTime.to_date(cutoff)
    months = opts |> Keyword.get(:months, 12) |> max(2) |> min(24)

    Enum.map((months - 1)..0//-1, fn offset ->
      first = Date.beginning_of_month(date)
      shifted = Date.shift(first, month: -offset)
      last = min_date(Date.end_of_month(shifted), date)
      time = DateTime.new!(last, ~T[23:59:59.999999]) |> min_time(cutoff)
      result = public_result(question, Keyword.put(opts, :cutoff, time))
      point(result, Date.to_iso8601(last), Calendar.strftime(last, "%b %Y"), months - offset)
    end)
  end

  defp response_points(question, opts) do
    events = History.first_events(question.uuid, opts)
    size = length(events)
    step = max(1, ceil(size / 24))

    events
    |> Enum.with_index(1)
    |> Enum.filter(fn {_, index} -> rem(index, step) == 0 or index == size end)
    |> Enum.map(fn {number, index} ->
      options = if index == size, do: opts, else: Keyword.put(opts, :through, number)
      result = public_result(question, Keyword.put(options, :basis, :recorded))
      point(result, "response-#{index}", "#{index} question responses", index)
    end)
  end

  defp point(result, key, label, x) do
    answers =
      Enum.map(result.answers, fn a ->
        if result.total == 0, do: %{a | percentage: nil}, else: a
      end)

    %{key: key, label: label, x: x, total: result.total, answers: answers}
  end

  defp min_date(a, b), do: if(Date.compare(a, b) == :gt, do: b, else: a)
  defp min_time(a, b), do: if(DateTime.compare(a, b) == :gt, do: b, else: a)
end
