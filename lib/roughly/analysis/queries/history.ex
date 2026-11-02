defmodule Roughly.Analysis.Queries.History do
  @moduledoc "Private revision selection. Public history is recomputed after withdrawals."
  import Ecto.Query
  alias Roughly.{Repo, Analysis.Projections.ResponseVersion}
  alias Roughly.Participation.Projections.Response

  @spec selected(Ecto.UUID.t(), keyword()) :: Ecto.Query.t()
  def selected(question, opts) do
    cutoff = Keyword.get(opts, :cutoff, DateTime.utc_now())

    clock =
      if Keyword.get(opts, :basis, :answered) == :recorded, do: :recorded_at, else: :answered_at

    revisions =
      from(v in ResponseVersion,
        join: current in Response,
        on: current.uuid == v.response_uuid,
        where:
          v.question_uuid == ^question and current.status == :active and
            field(v, ^clock) <= ^cutoff,
        distinct: v.response_uuid,
        order_by: [asc: v.response_uuid, desc: v.event_number]
      )

    revisions =
      case Keyword.get(opts, :through) do
        nil -> revisions
        number -> where(revisions, [v], v.event_number <= ^number)
      end

    active = from(v in subquery(revisions), where: v.status == :active)

    case Keyword.get(opts, :population) do
      nil ->
        active

      {source, option} ->
        members = selected(source, Keyword.delete(opts, :population))
        members = from(m in members, where: ^option in m.option_ids, select: m.principal_uuid)
        where(active, [v], v.principal_uuid in subquery(members))
    end
  end

  @spec snapshot(Roughly.Analysis.Result.t(), keyword()) :: Roughly.Analysis.Result.t()
  def snapshot(question, opts) do
    rows = selected(question.uuid, opts)
    total = Repo.aggregate(rows, :count)

    counts =
      from(v in rows,
        group_by: fragment("unnest(?)", v.option_ids),
        select: {type(fragment("unnest(?)", v.option_ids), :binary_id), count(v.response_uuid)}
      )
      |> Repo.all()
      |> Map.new()

    answers =
      Enum.map(question.answers, fn answer ->
        count = Map.get(counts, answer.id, 0)

        %{
          answer
          | count: count,
            percentage: if(total == 0, do: 0.0, else: Float.round(count / total * 100, 1))
        }
      end)

    %{question | total: total, answers: answers}
  end

  @spec first_events(Ecto.UUID.t(), keyword()) :: [integer()]
  def first_events(question, opts) do
    cutoff = Keyword.get(opts, :cutoff, DateTime.utc_now())

    from(v in ResponseVersion,
      join: r in Response,
      on: r.uuid == v.response_uuid,
      where: v.question_uuid == ^question and r.status == :active and v.recorded_at <= ^cutoff,
      group_by: v.response_uuid,
      select: min(v.event_number),
      order_by: min(v.event_number)
    )
    |> Repo.all()
  end

  @spec matched_count(Ecto.UUID.t(), Ecto.UUID.t(), keyword()) :: non_neg_integer()
  def matched_count(target, source, opts) do
    members =
      from(m in selected(source, Keyword.delete(opts, :population)), select: m.principal_uuid)

    from(t in selected(target, opts), where: t.principal_uuid in subquery(members))
    |> Repo.aggregate(:count)
  end
end
