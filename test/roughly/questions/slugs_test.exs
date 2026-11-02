defmodule Roughly.Questions.SlugsTest do
  use ExUnit.Case, async: false
  alias Roughly.{Questions, History}
  alias Roughly.Access.Actor
  alias Roughly.Questions.Question

  test "readable routes are allocated without IDs and concurrent collisions get distinct names" do
    actor = Actor.system("test-maintenance")
    text = "A slug example #{Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)}?"
    base = Roughly.Questions.Instrument.slug_base(text)

    attrs = %{
      text: text,
      question_type: :binary,
      options: Enum.map(["Yes", "No"], &Roughly.Questions.Option.new(Ecto.UUID.generate(), &1))
    }

    results =
      1..4
      |> Task.async_stream(fn _ -> Questions.create(actor, attrs) end, timeout: :infinity)
      |> Enum.map(fn {:ok, {:ok, id}} -> History.load(Question, id) end)

    # Public routes are stored in creation events; aggregate identity stays private.
    slugs =
      Enum.map(results, fn q ->
        {:ok, [event]} = Roughly.EventStore.read_stream_forward(q.uuid)
        event.data.slug
      end)

    assert Enum.sort(slugs) == Enum.sort([base, base <> "-2", base <> "-3", base <> "-4"])

    assert {:ok, id} =
             Questions.create(actor, %{
               attrs
               | text: text |> String.trim_trailing("?") |> Kernel.<>(" 2?")
             })

    assert {:ok, [created]} = Roughly.EventStore.read_stream_forward(id)
    assert created.data.slug == base <> "-2-2"
  end

  test "creation cannot bypass the route claim or claim a route for an invalid definition" do
    actor = Actor.system("test-maintenance")
    id = Ecto.UUID.generate()
    slug = "reserved-#{Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)}"

    command = %Roughly.Questions.Commands.CreateQuestion{
      question_uuid: id,
      text: "A prompt?",
      slug: slug,
      question_type: :binary,
      options: Enum.map(["Yes", "No"], &Roughly.Questions.Option.new(Ecto.UUID.generate(), &1))
    }

    assert {:error, :slug_not_claimed} = Roughly.Dispatch.dispatch(command, actor)
    assert {:error, :stream_not_found} = Roughly.EventStore.read_stream_forward(id)
    assert {:error, {:invalid_command, _}} = Questions.publish(actor, %{command | options: []})

    assert {:error, :stream_not_found} =
             Roughly.EventStore.read_stream_forward("question-slug:" <> slug)
  end
end
