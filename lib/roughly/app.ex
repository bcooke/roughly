defmodule Roughly.App do
  @moduledoc """
  Commanded application for the Roughly domain.

  This module configures the CQRS/ES infrastructure, connecting
  aggregates, command handlers, and event handlers.
  """

  use Commanded.Application,
    otp_app: :roughly,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Roughly.EventStore
    ]
end
