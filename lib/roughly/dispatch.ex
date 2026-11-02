defmodule Roughly.Dispatch do
  @moduledoc "Trusted dispatch seam; adapters derive the actor from authenticated state, not input."
  alias Roughly.Access.Actor

  @spec dispatch(struct(), Actor.t(), keyword()) :: :ok | {:error, term()}
  def dispatch(command, %Actor{} = actor, opts \\ []) do
    metadata = opts |> Keyword.get(:metadata, %{}) |> Map.merge(Actor.metadata(actor))
    Roughly.App.dispatch(command, Keyword.put(opts, :metadata, metadata))
  end
end
