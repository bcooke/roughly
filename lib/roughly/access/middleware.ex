defmodule Roughly.Access.Middleware do
  @moduledoc "Authorize every command beneath transport adapters; replay does not rerun admission."
  @behaviour Commanded.Middleware
  alias Commanded.Middleware.Pipeline
  alias Roughly.Access.{Actor, Policy}
  @impl true
  def before_dispatch(pipeline) do
    case Policy.authorize(pipeline.command, Actor.from_metadata(pipeline.metadata)) do
      {:ok, command} -> %{pipeline | command: command}
      {:error, reason} -> pipeline |> Pipeline.respond({:error, reason}) |> Pipeline.halt()
    end
  end

  @impl true
  def after_dispatch(pipeline), do: pipeline
  @impl true
  def after_failure(pipeline), do: pipeline
end
