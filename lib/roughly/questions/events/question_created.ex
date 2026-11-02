defmodule Roughly.Questions.Events.QuestionCreated do
  @moduledoc "Event emitted when a question is created."
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
  @derive Jason.Encoder
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
end
