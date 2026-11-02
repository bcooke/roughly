defmodule Roughly.Identity.Projections.Principal do
  @moduledoc "Derived principal standing. Authentication storage belongs to its own adapter."
  use Ecto.Schema
  @primary_key {:uuid, :binary_id, autogenerate: false}
  schema "principals" do
    field :status, Ecto.Enum, values: [:active, :deactivated], default: :active
    timestamps(type: :utc_datetime)
  end
end
