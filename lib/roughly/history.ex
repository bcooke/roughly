defmodule Roughly.History do
  @moduledoc "Internal event-store adapter for authoritative admission reads, independent of projector lag."
  @spec load(module(), String.t()) :: struct()
  def load(module, stream) do
    case Roughly.EventStore.stream_forward(stream) do
      {:error, :stream_not_found} ->
        struct(module)

      events ->
        Enum.reduce(events, struct(module), fn event, state -> module.apply(state, event.data) end)
    end
  end
end
