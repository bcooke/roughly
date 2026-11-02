defmodule Roughly.Questions.Projections.Question do
  @moduledoc """
  Read model schema for questions.

  This is a projection from the event store, updated by the projector.
  Query this table for read operations - never query aggregates directly.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "questions" do
    field :text, :string
    field :slug, :string
    field :question_type, Ecto.Enum, values: [:binary, :multiple_choice, :scaled]
    field :status, Ecto.Enum, values: [:active, :closed], default: :active
    field :options, {:array, :string}, default: []
    field :category, :string
    field :created_by, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for inserting/updating a question projection.
  """
  def changeset(question, attrs) do
    question
    |> cast(attrs, [
      :text,
      :slug,
      :question_type,
      :status,
      :options,
      :category
    ])
    |> validate_required([:uuid, :text, :question_type])
    |> generate_slug()
    |> unique_constraint(:slug)
  end

  defp generate_slug(changeset) do
    case get_field(changeset, :slug) do
      nil ->
        text = get_field(changeset, :text)

        if text do
          slug = slug_for(text)

          put_change(changeset, :slug, slug)
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  def slug_for(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
    |> String.slice(0, 100)
  end
end
