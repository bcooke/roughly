defmodule Roughly.Repo.Migrations.CreatePrincipalsTable do
  use Ecto.Migration

  def change do
    create table(:principals, primary_key: false) do
      add :uuid, :binary_id, primary_key: true
      add :status, :string, null: false, default: "active"
      timestamps(type: :utc_datetime)
    end
  end
end
