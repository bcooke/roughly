defmodule Roughly.Questions.Queries.Results do
  @moduledoc "Batched aggregate counts; never returns participant identities."
  import Ecto.Query
  alias Roughly.Repo
  alias Roughly.Voting.Projections.Vote

  def attach([]), do: []

  def attach(questions) do
    ids = Enum.map(questions, & &1.uuid)

    counts =
      from(v in Vote,
        where: v.question_uuid in ^ids and v.status == :active,
        group_by: [v.question_uuid, v.option_id],
        select: {{v.question_uuid, v.option_id}, count(v.uuid)}
      )
      |> Repo.all()
      |> Map.new()

    Enum.map(questions, fn question ->
      total = Enum.sum(Enum.map(question.options, &Map.get(counts, {question.uuid, &1}, 0)))

      answers =
        Enum.map(question.options, fn option ->
          count = Map.get(counts, {question.uuid, option}, 0)

          %{
            label: option,
            count: count,
            percentage: if(total == 0, do: 0.0, else: Float.round(count / total * 100, 1))
          }
        end)

      %{
        uuid: question.uuid,
        slug: question.slug,
        text: question.text,
        category: question.category,
        total: total,
        answers: answers
      }
    end)
  end
end
