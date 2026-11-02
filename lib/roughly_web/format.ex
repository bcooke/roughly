defmodule RoughlyWeb.Format do
  @moduledoc "Display formatting shared by the web interface."

  def number(value) do
    value
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse()
    |> Enum.join(",")
  end
end
