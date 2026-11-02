defmodule Roughly.Users.Commands.DeactivateUser do
  @moduledoc "Command to deactivate a user account."
  defstruct [:user_uuid, :reason]
end
