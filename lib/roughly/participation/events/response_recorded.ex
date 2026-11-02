defmodule Roughly.Participation.Events.ResponseRecorded do
  @moduledoc "Selections were recorded with their collection context."
  @type t :: %__MODULE__{
          context: Roughly.Participation.Context.t() | nil,
          response_uuid: Ecto.UUID.t() | nil,
          question_uuid: Ecto.UUID.t() | nil,
          principal_uuid: Ecto.UUID.t() | nil,
          option_ids: [Ecto.UUID.t()] | nil
        }
  @derive Jason.Encoder
  defstruct [:context, :response_uuid, :question_uuid, :principal_uuid, :option_ids]
end
