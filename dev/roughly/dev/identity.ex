defmodule Roughly.Dev.Identity do
  @moduledoc "Stable identifiers for the versioned development dataset."

  def uuid(key) do
    <<a::48, _::4, b::12, _::2, c::62, _::binary>> =
      :crypto.hash(:sha256, "roughly-development-v1:#{key}")

    Ecto.UUID.load!(<<a::48, 5::4, b::12, 2::2, c::62>>)
  end
end
