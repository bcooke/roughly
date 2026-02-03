defmodule Roughly.Demographics do
  @moduledoc """
  The Demographics context.

  Handles demographic definitions, slicing logic, and population analysis.
  This context is primarily read-heavy, providing the building blocks
  for filtering and analyzing voting data.

  ## Key Concepts

  - **Demographic Attributes**: Individual data points (age, gender, country)
  - **Demographic Slice**: A filter combination ("women aged 25-34 in the US")
  - **Population Overlap**: Cross-question analysis ("coffee drinkers who exercise")
  - **k-Anonymity**: Minimum threshold to display a slice (privacy protection)

  ## Examples

      # Get available demographic dimensions
      {:ok, dimensions} = Demographics.list_dimensions()

      # Get valid values for a dimension
      {:ok, values} = Demographics.get_dimension_values("age_range")

      # Build a demographic slice
      {:ok, slice} = Demographics.build_slice(%{
        gender: "female",
        age_range: "25-34",
        country: "US"
      })
  """

  alias Roughly.Commands.Error

  # Minimum number of respondents required to display a demographic slice
  @k_anonymity_threshold 10

  # ============================================================================
  # Dimension Definitions
  # ============================================================================

  @doc """
  Returns the k-anonymity threshold.

  Demographic slices with fewer respondents than this threshold
  will not be displayed to protect individual privacy.
  """
  @spec k_anonymity_threshold() :: pos_integer()
  def k_anonymity_threshold, do: @k_anonymity_threshold

  @doc """
  Lists all available demographic dimensions.
  """
  @spec list_dimensions() :: {:ok, list(map())}
  def list_dimensions do
    {:ok,
     [
       %{
         key: :gender,
         label: "Gender",
         type: :enum,
         values: [:male, :female, :other, :prefer_not_to_say]
       },
       %{
         key: :age_range,
         label: "Age Range",
         type: :enum,
         values: [:"18-24", :"25-34", :"35-44", :"45-54", :"55-64", :"65+"]
       },
       %{
         key: :country,
         label: "Country",
         type: :string,
         values: :dynamic
       },
       %{
         key: :region,
         label: "Region/State",
         type: :string,
         values: :dynamic
       },
       %{
         key: :education_level,
         label: "Education Level",
         type: :enum,
         values: [
           :high_school,
           :some_college,
           :bachelors,
           :masters,
           :doctorate,
           :prefer_not_to_say
         ]
       },
       %{
         key: :income_bracket,
         label: "Income Bracket",
         type: :enum,
         values: [
           :under_25k,
           :"25k-50k",
           :"50k-75k",
           :"75k-100k",
           :"100k-150k",
           :over_150k,
           :prefer_not_to_say
         ]
       }
     ]}
  end

  @doc """
  Gets the valid values for a specific dimension.
  """
  @spec get_dimension_values(atom() | String.t()) :: {:ok, list()} | {:error, Error.t()}
  def get_dimension_values(dimension) when is_binary(dimension) do
    get_dimension_values(String.to_existing_atom(dimension))
  rescue
    ArgumentError -> {:error, Error.new(:invalid_dimension, "Unknown dimension: #{dimension}")}
  end

  def get_dimension_values(dimension) when is_atom(dimension) do
    {:ok, dimensions} = list_dimensions()

    case Enum.find(dimensions, &(&1.key == dimension)) do
      nil -> {:error, Error.new(:invalid_dimension, "Unknown dimension: #{dimension}")}
      %{values: :dynamic} -> {:ok, :dynamic}
      %{values: values} -> {:ok, values}
    end
  end

  # ============================================================================
  # Slice Building
  # ============================================================================

  @doc """
  Builds a demographic slice from filter parameters.

  Validates that all dimension keys and values are valid.
  """
  @spec build_slice(map()) :: {:ok, map()} | {:error, Error.t()}
  def build_slice(filters) when is_map(filters) do
    {:ok, dimensions} = list_dimensions()
    valid_keys = Enum.map(dimensions, & &1.key)

    # Validate all keys are known dimensions
    invalid_keys =
      filters
      |> Map.keys()
      |> Enum.map(&normalize_key/1)
      |> Enum.reject(&(&1 in valid_keys))

    if Enum.empty?(invalid_keys) do
      normalized =
        filters
        |> Enum.map(fn {k, v} -> {normalize_key(k), normalize_value(v)} end)
        |> Map.new()

      {:ok, normalized}
    else
      {:error, Error.new(:invalid_dimensions, %{invalid_keys: invalid_keys})}
    end
  end

  # ============================================================================
  # Snapshot Creation
  # ============================================================================

  @doc """
  Creates a demographic snapshot from a user's profile.

  This is called when a vote is cast to capture the user's
  demographics at that point in time.
  """
  @spec create_snapshot(map()) :: map()
  def create_snapshot(profile) when is_map(profile) do
    {:ok, dimensions} = list_dimensions()
    dimension_keys = Enum.map(dimensions, & &1.key)

    profile
    |> Map.take(dimension_keys)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  # ============================================================================
  # Age Calculation
  # ============================================================================

  @doc """
  Calculates age range from birth year.
  """
  @spec age_range_from_birth_year(integer()) :: atom()
  def age_range_from_birth_year(birth_year) when is_integer(birth_year) do
    current_year = Date.utc_today().year
    age = current_year - birth_year

    cond do
      age < 18 -> :under_18
      age <= 24 -> :"18-24"
      age <= 34 -> :"25-34"
      age <= 44 -> :"35-44"
      age <= 54 -> :"45-54"
      age <= 64 -> :"55-64"
      true -> :"65+"
    end
  end

  # ============================================================================
  # Private Helpers
  # ============================================================================

  defp normalize_key(key) when is_binary(key), do: String.to_existing_atom(key)
  defp normalize_key(key) when is_atom(key), do: key

  defp normalize_value(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> String.to_existing_atom(value)
    end
  rescue
    ArgumentError -> value
  end

  defp normalize_value(value), do: value
end
