defmodule Roughly.Voting.Projections.Projector do
  @moduledoc """
  Projector for the Voting domain.

  Listens to voting events and updates the read model.
  """

  use Commanded.Projections.Ecto,
    application: Roughly.App,
    repo: Roughly.Repo,
    name: "VotingProjector"

  alias Roughly.Voting.Events.{VoteCast, VoteRetracted, VoteChanged}
  alias Roughly.Voting.Projections.Vote

  project(%VoteCast{} = event, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :vote, %Vote{
      uuid: event.vote_uuid,
      question_uuid: event.question_uuid,
      user_uuid: event.user_uuid,
      option_id: event.option_id,
      status: :active
    })
  end)

  project(%VoteRetracted{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :vote, fn repo, _changes ->
      case repo.get(Vote, event.vote_uuid) do
        nil ->
          {:error, :not_found}

        vote ->
          vote
          |> Ecto.Changeset.change(status: :retracted)
          |> repo.update()
      end
    end)
  end)

  project(%VoteChanged{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :vote, fn repo, _changes ->
      case repo.get(Vote, event.vote_uuid) do
        nil ->
          {:error, :not_found}

        vote ->
          vote
          |> Ecto.Changeset.change(option_id: event.new_option_id)
          |> repo.update()
      end
    end)
  end)
end
