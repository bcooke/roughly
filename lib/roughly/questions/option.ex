defmodule Roughly.Questions.Option do
  @moduledoc "An immutable instrument option. Identity is independent of its displayed label."
  @type t :: %__MODULE__{id: Ecto.UUID.t(), label: String.t()}
  @enforce_keys [:id, :label]
  @derive Jason.Encoder
  defstruct [:id, :label]
  @spec new(Ecto.UUID.t(), String.t()) :: t()
  def new(id, label) do
    option = %__MODULE__{id: id, label: label}
    if valid?(option), do: option, else: raise(ArgumentError, "invalid instrument option")
  end

  @spec valid?(term()) :: boolean()
  def valid?(%__MODULE__{id: id, label: label}) do
    is_binary(id) and match?({:ok, ^id}, Ecto.UUID.cast(id)) and is_binary(label) and
      String.valid?(label) and String.trim(label) != "" and String.length(label) <= 120
  end

  def valid?(_), do: false
  @spec from_map(map()) :: t()
  def from_map(%{id: id, label: label}), do: new(id, label)
  def from_map(%{"id" => id, "label" => label}), do: new(id, label)
end
