defmodule Roughly.Repo do
  use Ecto.Repo,
    otp_app: :roughly,
    adapter: Ecto.Adapters.Postgres
end
