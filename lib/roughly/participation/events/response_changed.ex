defmodule Roughly.Participation.Events.ResponseChanged do
  @moduledoc "Selections were revised under the recorded collection context."
  @type t :: %__MODULE__{
          context: Roughly.Participation.Context.t() | nil,
          response_uuid: Ecto.UUID.t() | nil,
          old_option_ids: [Ecto.UUID.t()] | nil,
          new_option_ids: [Ecto.UUID.t()] | nil
        }
  @derive Jason.Encoder
  defstruct [:context, :response_uuid, :old_option_ids, :new_option_ids]
end
