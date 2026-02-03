defmodule Roughly.Users.Projections.User do
  @moduledoc """
  Read model schema for users.

  This is a projection from the event store, updated by the projector.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :display_name, :string
    field :birth_year, :integer
    field :country, :string
    field :region, :string
    field :gender, Ecto.Enum, values: [:male, :female, :other, :prefer_not_to_say]
    field :status, Ecto.Enum, values: [:active, :deactivated], default: :active

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for inserting/updating a user projection.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :uuid,
      :email,
      :password_hash,
      :display_name,
      :birth_year,
      :country,
      :region,
      :gender,
      :status
    ])
    |> validate_required([:uuid, :email])
    |> unique_constraint(:email)
  end
end
