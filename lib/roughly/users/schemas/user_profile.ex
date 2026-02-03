defmodule Roughly.Users.Schemas.UserProfile do
  @moduledoc """
  Schema for user profiles (demographic data) in Roughly.

  Profiles contain demographic information used for slicing voting data.
  This data is:
  - Used to create demographic snapshots when votes are cast
  - Never exposed at the individual level
  - Only shown in aggregate (with k-anonymity thresholds)

  ## Fields

  - `birth_year` - Year of birth (used to calculate age range)
  - `country` - ISO country code
  - `region` - State/province
  - `gender` - Gender identity
  - `education_level` - Highest education level
  - `income_bracket` - Household income bracket
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Roughly.Users.Schemas.User

  @type t :: %__MODULE__{}

  @genders [:male, :female, :other, :prefer_not_to_say]
  @education_levels [:high_school, :some_college, :bachelors, :masters, :doctorate, :prefer_not_to_say]
  @income_brackets [:under_25k, :"25k-50k", :"50k-75k", :"75k-100k", :"100k-150k", :over_150k, :prefer_not_to_say]

  def genders, do: @genders
  def education_levels, do: @education_levels
  def income_brackets, do: @income_brackets

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user_profiles" do
    field :birth_year, :integer
    field :country, :string
    field :region, :string
    field :gender, Ecto.Enum, values: @genders
    field :education_level, Ecto.Enum, values: @education_levels
    field :income_bracket, Ecto.Enum, values: @income_brackets

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a user profile.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:birth_year, :country, :region, :gender, :education_level, :income_bracket, :user_id])
    |> validate_birth_year()
    |> validate_country()
    |> validate_inclusion(:gender, @genders)
    |> validate_inclusion(:education_level, @education_levels)
    |> validate_inclusion(:income_bracket, @income_brackets)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id)
  end

  defp validate_birth_year(changeset) do
    current_year = Date.utc_today().year

    changeset
    |> validate_number(:birth_year,
      greater_than_or_equal_to: current_year - 120,
      less_than_or_equal_to: current_year - 13,
      message: "must be a valid birth year (minimum age 13)"
    )
  end

  defp validate_country(changeset) do
    changeset
    |> validate_length(:country, is: 2, message: "must be a 2-letter ISO country code")
    |> validate_format(:country, ~r/^[A-Z]{2}$/, message: "must be uppercase ISO country code")
  end

  @doc """
  Converts profile to a demographic snapshot map.

  This is used when casting votes to capture demographics at vote time.
  """
  @spec to_snapshot(t()) :: map()
  def to_snapshot(%__MODULE__{} = profile) do
    %{
      birth_year: profile.birth_year,
      age_range: age_range(profile.birth_year),
      country: profile.country,
      region: profile.region,
      gender: profile.gender,
      education_level: profile.education_level,
      income_bracket: profile.income_bracket
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp age_range(nil), do: nil

  defp age_range(birth_year) do
    Roughly.Demographics.age_range_from_birth_year(birth_year)
  end
end
