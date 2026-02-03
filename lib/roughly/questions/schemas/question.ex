defmodule Roughly.Questions.Schemas.Question do
  @moduledoc """
  Schema for questions in Roughly.

  Questions are the core domain object - they represent polling questions
  that users can vote on.

  ## Fields

  - `text` - The question text
  - `slug` - URL-friendly identifier
  - `question_type` - Type of question (:binary, :multiple_choice, :scaled)
  - `status` - Current status (:draft, :active, :closed, :moderated)
  - `category` - Optional category string
  - `methodology` - Optional methodology description
  - `answer_options` - Embedded list of answer options
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Roughly.Questions.Schemas.AnswerOption

  @type t :: %__MODULE__{}

  @question_types [:binary, :multiple_choice, :scaled]
  @statuses [:draft, :active, :closed, :moderated]

  def question_types, do: @question_types
  def statuses, do: @statuses
  def active_statuses, do: [:active]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "questions" do
    field :text, :string
    field :slug, :string
    field :question_type, Ecto.Enum, values: @question_types
    field :status, Ecto.Enum, values: @statuses, default: :draft
    field :category, :string
    field :methodology, :string

    embeds_many :answer_options, AnswerOption, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a question.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:text, :slug, :question_type, :status, :category, :methodology])
    |> validate_required([:text, :question_type])
    |> validate_length(:text, min: 10, max: 500)
    |> validate_inclusion(:question_type, @question_types)
    |> validate_inclusion(:status, @statuses)
    |> cast_embed(:answer_options, required: true)
    |> generate_slug()
    |> unique_constraint(:slug)
  end

  defp generate_slug(changeset) do
    case get_field(changeset, :slug) do
      nil ->
        text = get_field(changeset, :text)

        if text do
          slug =
            text
            |> String.downcase()
            |> String.replace(~r/[^a-z0-9\s-]/, "")
            |> String.replace(~r/\s+/, "-")
            |> String.slice(0, 100)

          put_change(changeset, :slug, slug)
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
