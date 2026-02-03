defmodule Roughly.Users.User do
  @moduledoc """
  Aggregate for the Users domain.

  Handles commands and emits events for user lifecycle management.
  Profile information (demographics) is stored directly on the user aggregate.
  """

  defstruct uuid: nil,
            email: nil,
            password_hash: nil,
            display_name: nil,
            birth_year: nil,
            country: nil,
            region: nil,
            gender: nil,
            status: nil

  alias Roughly.Users.Commands.{RegisterUser, UpdateProfile, DeactivateUser}
  alias Roughly.Users.Events.{UserRegistered, ProfileUpdated, UserDeactivated}

  # ============================================================================
  # Command Handlers
  # ============================================================================

  @doc """
  Execute commands on the User aggregate.

  Returns event(s) on success, or `{:error, reason}` on failure.
  """
  def execute(user, command)

  def execute(%__MODULE__{uuid: nil}, %RegisterUser{} = cmd) do
    %UserRegistered{
      user_uuid: cmd.user_uuid,
      email: cmd.email,
      password_hash: cmd.password_hash
    }
  end

  def execute(%__MODULE__{uuid: _existing}, %RegisterUser{}) do
    {:error, :user_already_exists}
  end

  def execute(%__MODULE__{status: :active}, %UpdateProfile{} = cmd) do
    %ProfileUpdated{
      user_uuid: cmd.user_uuid,
      display_name: cmd.display_name,
      birth_year: cmd.birth_year,
      country: cmd.country,
      region: cmd.region,
      gender: cmd.gender
    }
  end

  def execute(%__MODULE__{status: :deactivated}, %UpdateProfile{}) do
    {:error, :user_deactivated}
  end

  def execute(%__MODULE__{status: :active}, %DeactivateUser{} = cmd) do
    %UserDeactivated{
      user_uuid: cmd.user_uuid,
      reason: cmd.reason
    }
  end

  def execute(%__MODULE__{status: :deactivated}, %DeactivateUser{}) do
    {:error, :user_already_deactivated}
  end

  # ============================================================================
  # Event Applicators
  # ============================================================================

  @doc """
  Apply events to rebuild aggregate state.
  """
  def apply(state, event)

  def apply(%__MODULE__{} = state, %UserRegistered{} = event) do
    %__MODULE__{
      state
      | uuid: event.user_uuid,
        email: event.email,
        password_hash: event.password_hash,
        status: :active
    }
  end

  def apply(%__MODULE__{} = state, %ProfileUpdated{} = event) do
    %__MODULE__{
      state
      | display_name: event.display_name || state.display_name,
        birth_year: event.birth_year || state.birth_year,
        country: event.country || state.country,
        region: event.region || state.region,
        gender: event.gender || state.gender
    }
  end

  def apply(%__MODULE__{} = state, %UserDeactivated{}) do
    %__MODULE__{state | status: :deactivated}
  end
end
