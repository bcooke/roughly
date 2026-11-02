defmodule Roughly.Questions.Commands.ClaimSlug do
  @moduledoc "Reserve a readable public route for an instrument."
  @type t :: %__MODULE__{question_uuid: Ecto.UUID.t() | nil, slug: String.t() | nil}
  defstruct [:question_uuid, :slug]
  @doc false
  @spec validation_rules(t()) :: keyword()
  def validation_rules(_command), do: [question_uuid: :uuid, slug: :slug]
end
