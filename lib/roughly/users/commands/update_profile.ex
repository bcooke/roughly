defmodule Roughly.Users.Commands.UpdateProfile do
  @moduledoc "Command to update user profile information."
  defstruct [:user_uuid, :display_name, :birth_year, :country, :region, :gender]
end
