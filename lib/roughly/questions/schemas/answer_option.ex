defmodule Roughly.Questions.Schemas.AnswerOption do
  @moduledoc """
  Embedded schema for answer options within a question.

  Answer options are the possible responses a user can select
  when voting on a question.

  ## Fields

  - `id` - Unique identifier for this option
  - `text` - Display text for the option
  - `position` - Display order (0-indexed)
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field :text, :string
    field :position, :integer, default: 0
  end

  @doc """
  Changeset for answer options.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:text, :position])
    |> validate_required([:text])
    |> validate_length(:text, min: 1, max: 200)
  end
end
