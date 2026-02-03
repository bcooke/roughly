defmodule Roughly.Voting.Projections.Vote do
  @moduledoc """
  Read model schema for votes.

  This is a projection from the event store, updated by the projector.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "votes" do
    field :question_uuid, :binary_id
    field :user_uuid, :binary_id
    field :option_id, :string
    field :status, Ecto.Enum, values: [:active, :retracted], default: :active

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for inserting/updating a vote projection.
  """
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:uuid, :question_uuid, :user_uuid, :option_id, :status])
    |> validate_required([:uuid, :question_uuid, :user_uuid, :option_id])
    |> unique_constraint([:question_uuid, :user_uuid], name: :votes_question_user_unique)
  end
end
