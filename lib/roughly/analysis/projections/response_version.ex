defmodule Roughly.Analysis.Projections.ResponseVersion do
  @moduledoc "Private analysis projection of response revisions, with receipt and answer clocks."
  use Ecto.Schema
  @primary_key {:event_number, :integer, autogenerate: false}
  schema "response_history" do
    field :response_uuid, :binary_id
    field :question_uuid, :binary_id
    field :principal_uuid, :binary_id
    field :option_ids, {:array, :binary_id}
    field :status, Ecto.Enum, values: [:active, :withdrawn]
    field :recorded_at, :utc_datetime_usec
    field :answered_at, :utc_datetime_usec
    field :date_source, :string
  end
end
