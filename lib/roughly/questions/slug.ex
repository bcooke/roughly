defmodule Roughly.Questions.Slug do
  @moduledoc "One stream per public route serializes claims without waiting for a projection."
  alias Roughly.Questions.Commands.ClaimSlug
  alias Roughly.Questions.Events.SlugClaimed
  @type t :: %__MODULE__{question_uuid: Ecto.UUID.t() | nil}
  defstruct [:question_uuid]
  @spec execute(t(), ClaimSlug.t()) :: SlugClaimed.t() | [] | {:error, :slug_taken}
  def execute(%__MODULE__{question_uuid: nil}, command),
    do: %SlugClaimed{question_uuid: command.question_uuid, slug: command.slug}

  def execute(%__MODULE__{question_uuid: id}, %ClaimSlug{question_uuid: id}), do: []
  def execute(_state, _command), do: {:error, :slug_taken}
  @spec apply(t(), SlugClaimed.t()) :: t()
  def apply(state, event), do: %{state | question_uuid: event.question_uuid}
end
