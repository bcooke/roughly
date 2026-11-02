defmodule Roughly.Questions.Events.SlugClaimed do
  @moduledoc "A public route was reserved for an exact instrument."
  @type t :: %__MODULE__{question_uuid: Ecto.UUID.t() | nil, slug: String.t() | nil}
  @derive Jason.Encoder
  defstruct [:question_uuid, :slug]
end
