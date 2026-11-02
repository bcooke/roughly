defmodule Roughly.Analysis.Queries.Results do
  @moduledoc "Counts selections against eligible respondents, including multiple-selection instruments."
  import Ecto.Query
  alias Roughly.Repo
  alias Roughly.Participation.Projections.Response
  @spec attach([Roughly.Questions.Projections.Question.t()]) :: [Roughly.Analysis.Result.t()]
  def attach([]), do: []

  def attach(questions) do
    ids = Enum.map(questions, & &1.uuid)
    base = from(r in Response, where: r.question_uuid in ^ids and r.status == :active)

    totals =
      from(r in base, group_by: r.question_uuid, select: {r.question_uuid, count(r.uuid)})
      |> Repo.all()
      |> Map.new()

    counts =
      from(r in base,
        group_by: [r.question_uuid, fragment("unnest(?)", r.option_ids)],
        select:
          {{r.question_uuid, type(fragment("unnest(?)", r.option_ids), :binary_id)},
           count(r.uuid)}
      )
      |> Repo.all()
      |> Map.new()

    Enum.map(questions, fn question ->
      total = Map.get(totals, question.uuid, 0)

      answers =
        Enum.map(question.options, fn option ->
          count = Map.get(counts, {question.uuid, option.id}, 0)

          %{
            id: option.id,
            label: option.label,
            count: count,
            percentage: if(total == 0, do: 0.0, else: Float.round(count / total * 100, 1))
          }
        end)

      %{
        uuid: question.uuid,
        slug: question.slug,
        text: question.text,
        language: question.language,
        question_type: question.question_type,
        category: question.category,
        total: total,
        answers: answers
      }
    end)
  end
end
