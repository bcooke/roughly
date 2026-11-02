defmodule Roughly.Participation.Commands.RecordResponse do
  @moduledoc "Record selections and collection context for an exact instrument."
  @type t :: %__MODULE__{
          context: Roughly.Participation.Context.t() | nil,
          response_uuid: Ecto.UUID.t() | nil,
          question_uuid: Ecto.UUID.t() | nil,
          principal_uuid: Ecto.UUID.t() | nil,
          option_ids: [Ecto.UUID.t()] | nil
        }
  defstruct [
    :response_uuid,
    :question_uuid,
    :principal_uuid,
    :option_ids,
    context: %Roughly.Participation.Context{}
  ]

  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command),
    do: [
      context: :collection_context,
      response_uuid: :uuid,
      question_uuid: :uuid,
      principal_uuid: :uuid,
      option_ids: :selection
    ]

  @doc false
  @spec normalize(t()) :: t()
  def normalize(command), do: %{command | option_ids: Enum.sort(command.option_ids)}
end
