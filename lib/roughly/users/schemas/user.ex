defmodule Roughly.Users.Schemas.User do
  @moduledoc """
  Schema for users in Roughly.

  Users are required to vote (no anonymous voting) but their individual
  responses are never publicly visible.

  ## Fields

  - `email` - User's email address (unique)
  - `hashed_password` - Bcrypt hashed password
  - `confirmed_at` - When the email was confirmed
  - `status` - Account status (:active, :inactive, :suspended)
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Roughly.Users.Schemas.UserProfile

  @type t :: %__MODULE__{}

  @statuses [:active, :inactive, :suspended]

  def statuses, do: @statuses
  def active_statuses, do: [:active]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :confirmed_at, :utc_datetime
    field :status, Ecto.Enum, values: @statuses, default: :active

    # Virtual fields for registration
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true, redact: true

    has_one :profile, UserProfile
    has_many :votes, Roughly.Voting.Schemas.Vote

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for user registration.
  """
  @spec registration_changeset(t(), map()) :: Ecto.Changeset.t()
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_email()
    |> validate_password()
  end

  @doc """
  Changeset for updating user email.
  """
  @spec email_changeset(t(), map()) :: Ecto.Changeset.t()
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
  end

  @doc """
  Basic changeset for user updates.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :status])
    |> validate_email()
    |> validate_inclusion(:status, @statuses)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Roughly.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "must have at least one lowercase letter")
    |> validate_format(:password, ~r/[A-Z]/, message: "must have at least one uppercase letter")
    |> validate_format(:password, ~r/[0-9]/, message: "must have at least one digit")
    |> prepare_changes(&hash_password/1)
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  Verifies a password against the hashed password.
  """
  @spec valid_password?(t(), String.t()) :: boolean()
  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _), do: Bcrypt.no_user_verify()
end
