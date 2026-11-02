defmodule Roughly.Repo.Migrations.AddResponseHistory do
  use Ecto.Migration

  def change do
    create table(:response_history, primary_key: false) do
      add :event_number, :bigint, primary_key: true
      add :response_uuid, :uuid, null: false
      add :question_uuid, :uuid, null: false
      add :principal_uuid, :uuid, null: false
      add :option_ids, {:array, :uuid}, null: false
      add :status, :string, null: false
      add :recorded_at, :utc_datetime_usec, null: false
      add :answered_at, :utc_datetime_usec, null: false
      add :date_source, :string, null: false
    end

    create index(:response_history, [:question_uuid, :recorded_at, :event_number])
    create index(:response_history, [:question_uuid, :answered_at, :event_number])
    create index(:response_history, [:response_uuid, :event_number])
  end
end
