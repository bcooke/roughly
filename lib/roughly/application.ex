defmodule Roughly.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RoughlyWeb.Telemetry,
      Roughly.Repo,
      {DNSCluster, query: Application.get_env(:roughly, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Roughly.PubSub},
      Roughly.App,
      # Start to serve requests, typically the last entry
      RoughlyWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Roughly.Supervisor]

    projectors =
      if Application.get_env(:roughly, :start_projectors, true) do
        [
          Roughly.Questions.Projections.Projector,
          Roughly.Users.Projections.Projector,
          Roughly.Voting.Projections.Projector
        ]
      else
        []
      end

    {infrastructure, [endpoint]} = Enum.split(children, -1)
    Supervisor.start_link(infrastructure ++ projectors ++ [endpoint], opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RoughlyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
