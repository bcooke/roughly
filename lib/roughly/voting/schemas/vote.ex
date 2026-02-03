defmodule Roughly.Voting.Schemas.Vote do
  @moduledoc """
  Schema for votes in Roughly.

  Votes represent a user's response to a question. Each vote captures:
  - The answer selected
  - A snapshot of the user's demographics at vote time
  - Timestamp of when the vote was cast

  ## Privacy Model

  Votes are associated with users for:
  - Preventing duplicate votes
  - Showing users their own voting history
  - Quality signals (account age, patterns)

  Individual votes are NEVER exposed publicly. Only aggregate counts
  by demographic slice are visible.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Roughly.Questions.Schemas.Question
  alias Roughly.Users.Schemas.User

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "votes" do
    field :answer_id, :binary_id
    field :demographic_snapshot, :map, default: %{}
    field :voted_at, :utc_datetime

    belongs_to :question, Question
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating a vote.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:answer_id, :demographic_snapshot, :voted_at, :question_id, :user_id])
    |> validate_required([:answer_id, :question_id, :user_id])
    |> set_voted_at()
    |> foreign_key_constraint(:question_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:question_id, :user_id], message: "has already voted on this question")
  end

  defp set_voted_at(changeset) do
    case get_field(changeset, :voted_at) do
      nil -> put_change(changeset, :voted_at, DateTime.utc_now())
      _ -> changeset
    end
  end
end
