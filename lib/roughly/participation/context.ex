defmodule Roughly.Participation.Context do
  @moduledoc "Collection conditions with per-field provenance. Unknown is distinct from a negative observation."
  @type t :: %__MODULE__{
          mode: :internal | :development_fixture | :web | :api | :survey | :import,
          results_exposure: :unknown | :shown | :not_shown,
          option_order: [Ecto.UUID.t()] | nil,
          image_assets: [String.t()] | nil,
          identity_assurance: :unspecified | :account | :verified_person,
          presentation_variant: String.t() | nil,
          answered_at: DateTime.t() | nil,
          field_sources: %{optional(atom()) => :observed | :reported | :inferred | :unspecified},
          collection_run_uuid: Ecto.UUID.t() | nil
        }
  @derive Jason.Encoder
  defstruct mode: :internal,
            results_exposure: :unknown,
            option_order: nil,
            image_assets: nil,
            identity_assurance: :unspecified,
            presentation_variant: nil,
            answered_at: nil,
            field_sources: %{},
            collection_run_uuid: nil

  @modes [:internal, :development_fixture, :web, :api, :survey, :import]
  @exposure [:unknown, :shown, :not_shown]
  @sources [:observed, :reported, :inferred, :unspecified]
  @source_fields [
    :mode,
    :results_exposure,
    :option_order,
    :image_assets,
    :identity_assurance,
    :presentation_variant,
    :collection_run_uuid,
    :answered_at
  ]
  @assurance [:unspecified, :account, :verified_person]

  @spec new(map()) :: t()
  def new(attrs \\ %{}), do: struct!(__MODULE__, attrs)
  @spec valid?(term()) :: boolean()
  def valid?(%__MODULE__{} = context) do
    Enum.all?([
      context.mode in @modes,
      context.results_exposure in @exposure,
      context.identity_assurance in @assurance,
      optional_ids?(context.option_order),
      assets?(context.image_assets),
      optional_text?(context.presentation_variant),
      optional_uuid?(context.collection_run_uuid),
      optional_time?(context.answered_at),
      sources?(context.field_sources)
    ])
  end

  def valid?(_), do: false

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      mode: enum!(get(map, :mode), @modes),
      results_exposure: enum!(get(map, :results_exposure), @exposure),
      identity_assurance: enum!(get(map, :identity_assurance), @assurance),
      option_order: get(map, :option_order),
      image_assets: get(map, :image_assets),
      presentation_variant: get(map, :presentation_variant),
      collection_run_uuid: get(map, :collection_run_uuid),
      answered_at: decode_time!(get(map, :answered_at)),
      field_sources:
        Map.new(get(map, :field_sources), fn {key, value} -> {key, enum!(value, @sources)} end)
    }
  end

  defp optional_time?(nil), do: true
  defp optional_time?(%DateTime{utc_offset: 0, std_offset: 0}), do: true
  defp optional_time?(_), do: false
  defp decode_time!(nil), do: nil

  defp decode_time!(value) do
    {:ok, time, _offset} = DateTime.from_iso8601(value)
    time
  end

  defp sources?(values) when is_map(values),
    do: Enum.all?(values, fn {key, value} -> key in @source_fields and value in @sources end)

  defp sources?(_), do: false

  defp get(map, key), do: Map.get(map, key, Map.get(map, Atom.to_string(key)))

  defp enum!(value, values) when is_atom(value) do
    if value in values, do: value, else: raise(ArgumentError, "invalid collection context enum")
  end

  defp enum!(value, values),
    do:
      Enum.find(values, &(Atom.to_string(&1) == value)) ||
        raise(ArgumentError, "invalid collection context enum")

  defp optional_ids?(nil), do: true

  defp optional_ids?(values) when is_list(values),
    do: length(values) <= 20 and Enum.all?(values, &uuid?/1) and Enum.uniq(values) == values

  defp optional_ids?(_), do: false
  defp assets?(nil), do: true

  defp assets?(values) when is_list(values),
    do:
      length(values) <= 20 and
        Enum.all?(values, &(is_binary(&1) and Regex.match?(~r/^sha256:[0-9a-f]{64}$/, &1)))

  defp assets?(_), do: false
  defp optional_text?(nil), do: true

  defp optional_text?(value),
    do: is_binary(value) and String.valid?(value) and String.length(value) in 1..120

  defp optional_uuid?(nil), do: true
  defp optional_uuid?(value), do: uuid?(value)
  defp uuid?(value), do: is_binary(value) and match?({:ok, ^value}, Ecto.UUID.cast(value))
end
