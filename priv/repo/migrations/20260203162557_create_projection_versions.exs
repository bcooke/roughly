defmodule Roughly.Repo.Migrations.CreateProjectionVersions do
  @moduledoc """
  Creates the projection_versions table required by commanded_ecto_projections.
  This table tracks which events each projector has processed.
  """
  use Ecto.Migration

  def change do
    create table(:projection_versions, primary_key: false) do
      add :projection_name, :string, primary_key: true
      add :last_seen_event_number, :bigint

      timestamps(type: :utc_datetime)
    end
  end
end
