defmodule Roughly.Repo.Migrations.CreateResponsesTable do
  use Ecto.Migration

  def change do
    create table(:responses, primary_key: false) do
      add :uuid, :binary_id, primary_key: true
      add :question_uuid, :binary_id, null: false
      add :principal_uuid, :binary_id, null: false
      add :option_ids, {:array, :binary_id}, null: false
      add :context, :map, null: false
      add :status, :string, default: "active"

      timestamps(type: :utc_datetime)
    end

    # One vote per user per question
    create unique_index(:responses, [:question_uuid, :principal_uuid],
             name: :responses_question_principal_unique
           )

    create index(:responses, [:question_uuid])
    create index(:responses, [:principal_uuid])
    create index(:responses, [:status])
  end
end
