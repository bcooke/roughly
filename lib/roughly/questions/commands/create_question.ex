defmodule Roughly.Questions.Commands.CreateQuestion do
  @moduledoc "Command to create a new question."
  @type t :: %__MODULE__{
          question_uuid: Ecto.UUID.t() | nil,
          text: String.t() | nil,
          language: String.t() | nil,
          question_type: Roughly.Questions.Instrument.kind() | nil,
          options: [Roughly.Questions.Option.t()] | nil,
          created_by: Ecto.UUID.t() | nil,
          slug: String.t() | nil,
          category: String.t() | nil
        }
  defstruct [
    :language,
    :slug,
    :question_uuid,
    :text,
    :question_type,
    :options,
    :created_by,
    :category
  ]

  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(cmd),
    do: [
      question_uuid: :uuid,
      text: {:text, 500},
      language: {:optional, {:text, 35}},
      question_type: {:in, [:binary, :single_choice, :multiple_select, :ordered_scale]},
      options: {:options, cmd.question_type},
      created_by: {:optional, :uuid},
      category: {:optional, {:text, 80}},
      slug: {:optional, {:text, 150}}
    ]

  @doc false
  @spec normalize(t()) :: t()
  def normalize(command),
    do: %{
      command
      | language: command.language || "en",
        slug: Roughly.Questions.Instrument.slug(command.text, command.question_uuid)
    }
end
