defmodule Roughly.Questions.Slugs do
  @moduledoc "Readable route allocation, independent of internal instrument UUIDs."
  alias Roughly.Access.Actor
  alias Roughly.Questions.{Commands.ClaimSlug, Slug}

  @spec claim(Actor.t(), Ecto.UUID.t(), String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def claim(actor, id, base, opts \\ []), do: claim(actor, id, base, opts, 1)
  defp claim(_actor, _id, _base, _opts, 1001), do: {:error, :slug_space_exhausted}

  defp claim(actor, id, base, opts, number) do
    suffix = if number == 1, do: "", else: "-#{number}"

    slug =
      String.slice(base, 0, 100 - String.length(suffix))
      |> String.trim_trailing("-")
      |> Kernel.<>(suffix)

    case Roughly.Dispatch.dispatch(%ClaimSlug{question_uuid: id, slug: slug}, actor, opts) do
      :ok -> {:ok, slug}
      {:error, :slug_taken} -> claim(actor, id, base, opts, number + 1)
      error -> error
    end
  end

  @spec owned?(String.t(), Ecto.UUID.t()) :: boolean()
  def owned?(slug, id),
    do: Roughly.History.load(Slug, "question-slug:" <> slug).question_uuid == id
end
