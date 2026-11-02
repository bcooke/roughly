# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :live_vue, ssr: false, shared_props: []

config :phoenix_vite, PhoenixVite.Npm,
  assets: [args: [], cd: Path.expand("..", __DIR__)],
  vite: [
    args: ~w(run dev --),
    cd: Path.expand("..", __DIR__),
    env: %{"MIX_BUILD_PATH" => Mix.Project.build_path()}
  ]

config :roughly,
  ecto_repos: [Roughly.Repo],
  event_stores: [Roughly.EventStore],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :roughly, RoughlyWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RoughlyWeb.ErrorHTML, json: RoughlyWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Roughly.PubSub,
  live_view: [signing_salt: "vG59uIk5"]

# Configure LiveView
config :phoenix_live_view,
  # the attribute set on all root tags. Used for Phoenix.LiveView.ColocatedCSS.
  root_tag_attribute: "phx-r"

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
