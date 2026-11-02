defmodule Roughly.Participation.Commands.ChangeResponse do
  @moduledoc "Revise selections while preserving the preceding evidence in history."
  @type t :: %__MODULE__{
          context: Roughly.Participation.Context.t() | nil,
          actor_uuid: Ecto.UUID.t() | nil,
          response_uuid: Ecto.UUID.t() | nil,
          new_option_ids: [Ecto.UUID.t()] | nil
        }
  defstruct [
    :actor_uuid,
    :response_uuid,
    :new_option_ids,
    context: %Roughly.Participation.Context{}
  ]

  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command),
    do: [
      context: :collection_context,
      response_uuid: :uuid,
      new_option_ids: :selection,
      actor_uuid: {:optional, :uuid}
    ]

  @doc false
  @spec normalize(t()) :: t()
  def normalize(command), do: %{command | new_option_ids: Enum.sort(command.new_option_ids)}
end
