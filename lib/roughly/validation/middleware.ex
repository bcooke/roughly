defmodule Roughly.Validation.Middleware do
  @moduledoc "Apply domain parsing to every routed command, including direct bus callers."
  @behaviour Commanded.Middleware
  alias Commanded.Middleware.Pipeline
  @impl true
  def before_dispatch(pipeline) do
    case Roughly.Validation.parse(pipeline.command) do
      {:ok, command} -> %{pipeline | command: command}
      {:error, reason} -> pipeline |> Pipeline.respond({:error, reason}) |> Pipeline.halt()
    end
  end

  @impl true
  def after_dispatch(pipeline), do: pipeline
  @impl true
  def after_failure(pipeline), do: pipeline
end
