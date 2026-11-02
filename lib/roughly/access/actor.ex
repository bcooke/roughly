defmodule Roughly.Access.Actor do
  @moduledoc """
  Identity asserted by trusted application code, never decoded from request fields.
  Capabilities are resolved at dispatch, not carried in this envelope.
  """
  @type t :: %__MODULE__{
          kind: :principal | :system | :unattributed,
          id: Ecto.UUID.t() | nil,
          source: String.t() | nil
        }
  defstruct kind: :unattributed, id: nil, source: nil

  @spec principal(Ecto.UUID.t()) :: t()
  def principal(id), do: %__MODULE__{kind: :principal, id: id}
  @spec system(String.t()) :: t()
  def system(source), do: %__MODULE__{kind: :system, source: source}

  @spec metadata(t()) :: map()
  def metadata(%__MODULE__{kind: kind, id: id, source: source}),
    do: %{"actor_kind" => Atom.to_string(kind), "actor_id" => id, "actor_source" => source}

  @spec from_metadata(map()) :: t()
  def from_metadata(%{"actor_kind" => "principal", "actor_id" => id}) when is_binary(id),
    do: principal(id)

  def from_metadata(%{"actor_kind" => "system", "actor_source" => source}) when is_binary(source),
    do: system(source)

  def from_metadata(_), do: %__MODULE__{}
end
