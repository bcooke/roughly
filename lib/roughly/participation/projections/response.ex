defmodule Roughly.Participation.Projections.Response do
  @moduledoc """
  Read model for current responses.

  This is a projection from the event store, updated by the projector.
  """

  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "responses" do
    field :question_uuid, :binary_id
    field :principal_uuid, :binary_id
    field :option_ids, {:array, :binary_id}
    field :context, :map
    field :status, Ecto.Enum, values: [:active, :withdrawn], default: :active

    timestamps(type: :utc_datetime)
  end
end
