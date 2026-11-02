defmodule Roughly.Users.Events.UserDeactivated do
  @moduledoc "Event emitted when a user deactivates their account."
  @derive Jason.Encoder
  defstruct [:user_uuid, :reason]
end
