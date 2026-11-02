defmodule Roughly.Repo.Migrations.CreateQuestionsTable do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :uuid, :binary_id, primary_key: true
      add :text, :text, null: false
      add :language, :string, null: false
      add :slug, :string
      add :question_type, :string, null: false
      add :status, :string, default: "active"
      add :options, {:array, :map}, default: []
      add :category, :string
      add :created_by, :binary_id

      timestamps(type: :utc_datetime)
    end

    create unique_index(:questions, [:slug])
    create index(:questions, [:status])
    create index(:questions, [:category])
  end
end
