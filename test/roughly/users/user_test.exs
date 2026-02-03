defmodule Roughly.Users.UserTest do
  @moduledoc """
  Tests for the User aggregate.

  Following TDD: These tests were written FIRST before implementation.
  """
  use ExUnit.Case

  alias Roughly.Users.User
  alias Roughly.Users.Commands.{RegisterUser, UpdateProfile, DeactivateUser}
  alias Roughly.Users.Events.{UserRegistered, ProfileUpdated, UserDeactivated}

  @user_uuid "user-123"

  describe "RegisterUser command" do
    test "registers a new user" do
      cmd = %RegisterUser{
        user_uuid: @user_uuid,
        email: "test@example.com",
        password_hash: "hashed_password"
      }

      expected_event = %UserRegistered{
        user_uuid: @user_uuid,
        email: "test@example.com",
        password_hash: "hashed_password"
      }

      assert User.execute(%User{}, cmd) == expected_event
    end

    test "rejects duplicate registration" do
      existing_user = %User{uuid: @user_uuid}

      cmd = %RegisterUser{
        user_uuid: @user_uuid,
        email: "test@example.com",
        password_hash: "hashed_password"
      }

      assert {:error, :user_already_exists} = User.execute(existing_user, cmd)
    end
  end

  describe "UpdateProfile command" do
    test "updates user profile" do
      user = %User{uuid: @user_uuid, status: :active}

      cmd = %UpdateProfile{
        user_uuid: @user_uuid,
        display_name: "Test User",
        birth_year: 1990,
        country: "US"
      }

      expected_event = %ProfileUpdated{
        user_uuid: @user_uuid,
        display_name: "Test User",
        birth_year: 1990,
        country: "US"
      }

      assert User.execute(user, cmd) == expected_event
    end

    test "rejects update for deactivated user" do
      user = %User{uuid: @user_uuid, status: :deactivated}

      cmd = %UpdateProfile{
        user_uuid: @user_uuid,
        display_name: "Test User"
      }

      assert {:error, :user_deactivated} = User.execute(user, cmd)
    end
  end

  describe "DeactivateUser command" do
    test "deactivates an active user" do
      user = %User{uuid: @user_uuid, status: :active}

      cmd = %DeactivateUser{
        user_uuid: @user_uuid,
        reason: "User requested deletion"
      }

      expected_event = %UserDeactivated{
        user_uuid: @user_uuid,
        reason: "User requested deletion"
      }

      assert User.execute(user, cmd) == expected_event
    end

    test "rejects deactivating already deactivated user" do
      user = %User{uuid: @user_uuid, status: :deactivated}

      cmd = %DeactivateUser{
        user_uuid: @user_uuid,
        reason: "Double deactivation"
      }

      assert {:error, :user_already_deactivated} = User.execute(user, cmd)
    end
  end

  describe "apply events" do
    test "applies UserRegistered event" do
      event = %UserRegistered{
        user_uuid: @user_uuid,
        email: "test@example.com",
        password_hash: "hashed_password"
      }

      state = User.apply(%User{}, event)

      assert state.uuid == @user_uuid
      assert state.email == "test@example.com"
      assert state.password_hash == "hashed_password"
      assert state.status == :active
    end

    test "applies ProfileUpdated event" do
      initial = %User{uuid: @user_uuid}

      event = %ProfileUpdated{
        user_uuid: @user_uuid,
        display_name: "Test User",
        birth_year: 1990,
        country: "US"
      }

      state = User.apply(initial, event)

      assert state.display_name == "Test User"
      assert state.birth_year == 1990
      assert state.country == "US"
    end

    test "applies UserDeactivated event" do
      initial = %User{uuid: @user_uuid, status: :active}

      event = %UserDeactivated{
        user_uuid: @user_uuid,
        reason: "User requested deletion"
      }

      state = User.apply(initial, event)

      assert state.status == :deactivated
    end
  end
end
