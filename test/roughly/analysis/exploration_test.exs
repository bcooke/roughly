defmodule Roughly.Analysis.ExplorationTest do
  use Roughly.DataCase, async: true
  import Roughly.QuestionFixtures
  alias Roughly.Analysis
  alias Roughly.Participation.Projections.Projector
  alias Roughly.Participation.Events.{ResponseRecorded, ResponseChanged, ResponseWithdrawn}

  test "snapshots preserve revisions, distinguish clocks and remove withdrawals from public history" do
    q = question()
    id = Ecto.UUID.generate()
    principal = Ecto.UUID.generate()
    [yes, no | _] = q.options

    event = %ResponseRecorded{
      response_uuid: id,
      question_uuid: q.uuid,
      principal_uuid: principal,
      option_ids: [yes.id],
      context: context(~U[2026-01-10 00:00:00Z])
    }

    metadata = %{
      handler_name: "history-#{id}",
      event_number: 1,
      created_at: ~U[2026-02-01 00:00:00Z]
    }

    assert :ok = Projector.handle(event, metadata)
    assert :ok = Projector.handle(event, metadata)
    question = Roughly.Questions.get_question(q.slug)

    assert %{total: 0} =
             Analysis.snapshot(question, cutoff: ~U[2026-01-31 23:59:59Z], basis: :recorded)

    assert %{total: 1, answers: [%{count: 1} | _]} =
             Analysis.snapshot(question, cutoff: ~U[2026-01-31 23:59:59Z], basis: :answered)

    changed = %ResponseChanged{
      response_uuid: id,
      old_option_ids: [yes.id],
      new_option_ids: [no.id],
      context: context(~U[2026-02-10 00:00:00Z])
    }

    assert :ok =
             Projector.handle(changed, %{
               metadata
               | event_number: 2,
                 created_at: ~U[2026-02-10 00:00:00Z]
             })

    assert %{answers: [%{count: 1}, %{count: 0} | _]} =
             Analysis.snapshot(question, cutoff: ~U[2026-01-31 23:59:59Z])

    assert %{answers: [%{count: 0}, %{count: 1} | _]} =
             Analysis.snapshot(question, cutoff: ~U[2026-02-28 23:59:59Z])

    assert :ok =
             Projector.handle(%ResponseWithdrawn{response_uuid: id}, %{
               metadata
               | event_number: 3,
                 created_at: ~U[2026-03-01 00:00:00Z]
             })

    assert %{total: 0} = Analysis.snapshot(question, cutoff: ~U[2026-01-31 23:59:59Z])
  end

  test "population intersections use eligible answers, preserve missingness and suppress small groups" do
    target = question()
    source = question(%{text: "Which group?"})
    [yes, no | _] = target.options
    [a, b | _] = source.options

    for {index, group, answer} <- [{1, a, yes}, {2, a, no}, {3, b, yes}, {4, nil, no}] do
      principal = Ecto.UUID.generate()
      record(target, principal, [answer.id], index * 2)
      if group, do: record(source, principal, [group.id], index * 2 + 1)
    end

    t = Roughly.Questions.get_question(target.slug)
    s = Roughly.Questions.get_question(source.slug)

    assert %{total: 2, answers: [%{count: 1, percentage: 50.0} | _]} =
             Analysis.snapshot(t, population: {s.uuid, a.id})

    comparison = Analysis.compare(t, s)
    assert comparison.eligible == 3
    assert comparison.missing == 1
    assert Enum.all?(comparison.groups, &(&1.suppressed && is_nil(&1.total) && &1.answers == []))
    assert %{total: 0} = Analysis.snapshot(t, population: {s.uuid, Ecto.UUID.generate()})
  end

  test "trends have zero-denominator gaps and bounded date and response checkpoints" do
    q = question()
    [yes | _] = q.options
    record(q, Ecto.UUID.generate(), [yes.id], 1)
    result = Roughly.Questions.get_question(q.slug)
    trend = Analysis.trend(result, cutoff: ~U[2026-04-01 00:00:00Z], months: 4)
    assert Enum.any?(trend, &(&1.total == 0 && hd(&1.answers).percentage == nil))
    assert List.last(trend).total == 1
    votes = Analysis.trend(result, axis: :responses, cutoff: ~U[2026-04-01 00:00:00Z])
    assert length(votes) <= 24
    assert List.last(votes).total == 1
    refute Map.has_key?(List.last(votes), :principal_uuid)
  end

  test "serialized answer-date provenance survives replay" do
    context = context(~U[2026-02-01 00:00:00Z])

    restored =
      context |> Jason.encode!() |> Jason.decode!() |> Roughly.Participation.Context.from_map()

    assert restored.field_sources == %{answered_at: :reported}
    assert Roughly.Participation.Context.valid?(restored)
  end

  test "public population snapshots withhold small groups and publish eligible denominators" do
    q = question()
    source = question()
    [yes | _] = q.options
    [member | _] = source.options

    for index <- 1..10 do
      principal = Ecto.UUID.generate()
      record(q, principal, [yes.id], index * 2)
      record(source, principal, [member.id], index * 2 + 1)
    end

    result = Roughly.Questions.get_question(q.slug)
    cohort = {source.uuid, member.id}

    assert %{total: 10, suppressed: false, answers: [%{percentage: 100.0} | _]} =
             Analysis.public_result(result, population: cohort)

    assert %{total: nil, suppressed: true, answers: []} =
             Analysis.public_result(result, population: {source.uuid, Ecto.UUID.generate()})
  end

  defp context(time),
    do: %Roughly.Participation.Context{
      answered_at: time,
      field_sources: %{answered_at: :reported}
    }

  defp record(q, principal, ids, number) do
    id = Roughly.Participation.identity(q.uuid, principal)

    Projector.handle(
      %ResponseRecorded{
        response_uuid: id,
        question_uuid: q.uuid,
        principal_uuid: principal,
        option_ids: ids,
        context: context(~U[2026-02-01 00:00:00Z])
      },
      %{
        handler_name: "case-#{q.uuid}",
        event_number: number,
        created_at: ~U[2026-02-01 00:00:00Z]
      }
    )
  end
end
