defmodule Roughly.Questions.Projections.Question do
  @moduledoc """
  Read model schema for questions.

  This is a projection from the event store, updated by the projector.
  Query this table for read operations - never query aggregates directly.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          uuid: Ecto.UUID.t(),
          text: String.t(),
          search_document: String.t(),
          language: String.t(),
          slug: String.t() | nil,
          options: [Roughly.Questions.Option.t()],
          category: String.t() | nil,
          question_type: :binary | :single_choice | :multiple_select | :ordered_scale,
          status: :active | :closed,
          created_by: Ecto.UUID.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "questions" do
    field :text, :string
    field :search_document, :string, default: ""
    field :language, :string
    field :slug, :string

    field :question_type, Ecto.Enum,
      values: [:binary, :single_choice, :multiple_select, :ordered_scale]

    field :status, Ecto.Enum, values: [:active, :closed], default: :active
    field :options, {:array, Roughly.Questions.Projections.OptionType}, default: []
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
      :language,
      :slug,
      :question_type,
      :status,
      :options,
      :category
    ])
    |> validate_required([:uuid, :text, :question_type, :slug])
    |> unique_constraint(:slug)
  end
end
