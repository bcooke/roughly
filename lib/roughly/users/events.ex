defmodule Roughly.Users.Events do
  @moduledoc """
  Event structs for the Users aggregate.
  """

  defmodule UserRegistered do
    @moduledoc "Event emitted when a user registers."
    @derive Jason.Encoder
    defstruct [:user_uuid, :email, :password_hash]
  end

  defmodule ProfileUpdated do
    @moduledoc "Event emitted when a user updates their profile."
    @derive Jason.Encoder
    defstruct [:user_uuid, :display_name, :birth_year, :country, :region, :gender]
  end

  defmodule UserDeactivated do
    @moduledoc "Event emitted when a user deactivates their account."
    @derive Jason.Encoder
    defstruct [:user_uuid, :reason]
  end
end
