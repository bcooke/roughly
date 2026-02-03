defmodule Roughly.Repo.Migrations.CreateVotesTable do
  use Ecto.Migration

  def change do
    create table(:votes, primary_key: false) do
      add :uuid, :binary_id, primary_key: true
      add :question_uuid, :binary_id, null: false
      add :user_uuid, :binary_id, null: false
      add :option_id, :string, null: false
      add :status, :string, default: "active"

      timestamps(type: :utc_datetime)
    end

    # One vote per user per question
    create unique_index(:votes, [:question_uuid, :user_uuid], name: :votes_question_user_unique)
    create index(:votes, [:question_uuid])
    create index(:votes, [:user_uuid])
    create index(:votes, [:status])
  end
end
