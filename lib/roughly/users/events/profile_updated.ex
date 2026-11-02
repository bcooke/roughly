defmodule Roughly.Users.Events.ProfileUpdated do
  @moduledoc "Event emitted when a user updates their profile."
  @derive Jason.Encoder
  defstruct [:user_uuid, :display_name, :birth_year, :country, :region, :gender]
end
