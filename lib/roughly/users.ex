defmodule Roughly.Users do
  @moduledoc """
  The Users context.

  Handles user authentication, profile management, and demographic data.
  This is the gateway for all user-related operations.

  ## Privacy Model

  User accounts are required to vote (no anonymous voting), but individual
  votes remain private. Users can:
  - View their own profile and voting history
  - Update their demographic information
  - Delete their account (GDPR compliance)

  Demographic data is used for aggregate slicing but never exposed
  at the individual level.

  ## Examples

      # Register a new user
      {:ok, user} = Users.register_user(%{
        email: "user@example.com",
        password: "secure_password"
      })

      # Update user profile/demographics
      {:ok, user} = Users.update_profile(user, %{
        birth_year: 1990,
        country: "US",
        gender: "female"
      })

      # Get user by ID
      {:ok, user} = Users.get_user(user_id)
  """

  import Ecto.Query, warn: false

  alias Roughly.Repo
  alias Roughly.Commands.Error
  alias Roughly.Users.Schemas.User
  alias Roughly.Users.Schemas.UserProfile

  # ============================================================================
  # Commands (Write Operations)
  # ============================================================================

  @doc """
  Registers a new user.

  ## Parameters
    - attrs: Map containing:
      - email: User's email address (required)
      - password: User's password (required)

  ## Returns
    - {:ok, user} on success
    - {:error, :email_taken} if email already exists
    - {:error, Error.t()} on validation failure
  """
  @spec register_user(map()) :: {:ok, User.t()} | {:error, Error.t()}
  def register_user(attrs) do
    # TODO: Implement via Roughly.Users.Commands.RegisterUser
    {:error, Error.new(:not_implemented, "RegisterUser command not yet implemented")}
  end

  @doc """
  Updates a user's profile with demographic information.

  ## Parameters
    - user: The user struct
    - attrs: Map containing profile fields:
      - birth_year: Integer year of birth
      - country: ISO country code
      - region: State/province
      - gender: "male", "female", "other", "prefer_not_to_say"
      - education_level: Education level enum
      - income_bracket: Income bracket enum
  """
  @spec update_profile(User.t(), map()) :: {:ok, User.t()} | {:error, Error.t()}
  def update_profile(%User{} = user, attrs) do
    # TODO: Implement via Roughly.Users.Commands.UpdateProfile
    {:error, Error.new(:not_implemented, "UpdateProfile command not yet implemented")}
  end

  @doc """
  Deactivates a user account.

  Soft-deletes the user, preserving data for audit purposes
  but preventing login.
  """
  @spec deactivate_user(User.t()) :: {:ok, User.t()} | {:error, Error.t()}
  def deactivate_user(%User{} = user) do
    # TODO: Implement via Roughly.Users.Commands.DeactivateUser
    {:error, Error.new(:not_implemented, "DeactivateUser command not yet implemented")}
  end

  # ============================================================================
  # Queries (Read Operations)
  # ============================================================================

  @doc """
  Gets a user by ID.
  """
  @spec get_user(Ecto.UUID.t()) :: {:ok, User.t()} | {:error, Error.t()}
  def get_user(id) do
    # TODO: Implement via Roughly.Users.Queries.GetUser
    {:error, Error.new(:not_implemented, "GetUser query not yet implemented")}
  end

  @doc """
  Gets a user by email.
  """
  @spec get_user_by_email(String.t()) :: {:ok, User.t() | nil} | {:error, Error.t()}
  def get_user_by_email(email) do
    # TODO: Implement via Roughly.Users.Queries.GetUserByEmail
    {:error, Error.new(:not_implemented, "GetUserByEmail query not yet implemented")}
  end

  @doc """
  Gets a user's profile.
  """
  @spec get_profile(Ecto.UUID.t()) :: {:ok, UserProfile.t() | nil} | {:error, Error.t()}
  def get_profile(user_id) do
    # TODO: Implement via Roughly.Users.Queries.GetProfile
    {:error, Error.new(:not_implemented, "GetProfile query not yet implemented")}
  end

  # ============================================================================
  # Authentication Helpers
  # ============================================================================

  @doc """
  Authenticates a user by email and password.
  """
  @spec authenticate(String.t(), String.t()) :: {:ok, User.t()} | {:error, Error.t()}
  def authenticate(email, password) do
    # TODO: Implement authentication
    {:error, Error.new(:not_implemented, "Authentication not yet implemented")}
  end

  # ============================================================================
  # Changeset Functions (for forms)
  # ============================================================================

  @doc """
  Returns a changeset for tracking user changes.
  """
  @spec change_user(User.t(), map()) :: Ecto.Changeset.t()
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns a changeset for tracking profile changes.
  """
  @spec change_profile(UserProfile.t(), map()) :: Ecto.Changeset.t()
  def change_profile(%UserProfile{} = profile, attrs \\ %{}) do
    UserProfile.changeset(profile, attrs)
  end
end
