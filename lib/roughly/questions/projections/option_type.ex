defmodule Roughly.Questions.Projections.OptionType do
  @moduledoc "Ecto adapter for domain option values."
  use Ecto.Type
  alias Roughly.Questions.Option
  @impl true
  def type, do: :map
  @impl true
  def cast(%Option{} = option), do: if(Option.valid?(option), do: {:ok, option}, else: :error)
  def cast(_), do: :error
  @impl true
  def load(%{"id" => id, "label" => label}), do: {:ok, Option.new(id, label)}
  def load(_), do: :error
  @impl true
  def dump(%Option{} = option), do: {:ok, %{"id" => option.id, "label" => option.label}}
  def dump(_), do: :error
end
