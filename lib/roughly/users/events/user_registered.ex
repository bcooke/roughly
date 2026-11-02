defmodule Roughly.Users.Events.UserRegistered do
  @moduledoc "Event emitted when a user registers."
  @derive Jason.Encoder
  defstruct [:user_uuid, :email, :password_hash]
end
