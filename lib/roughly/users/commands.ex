defmodule Roughly.Users.Commands do
  @moduledoc """
  Command structs for the Users aggregate.
  """

  defmodule RegisterUser do
    @moduledoc "Command to register a new user."
    defstruct [:user_uuid, :email, :password_hash]
  end

  defmodule UpdateProfile do
    @moduledoc "Command to update user profile information."
    defstruct [:user_uuid, :display_name, :birth_year, :country, :region, :gender]
  end

  defmodule DeactivateUser do
    @moduledoc "Command to deactivate a user account."
    defstruct [:user_uuid, :reason]
  end
end
