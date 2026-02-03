defmodule Roughly.EventStore do
  @moduledoc """
  EventStore configuration for Commanded event sourcing.

  This module configures the PostgreSQL-based event store that persists
  all domain events. Events are immutable and form the source of truth
  for the system state.
  """

  use EventStore, otp_app: :roughly
end
