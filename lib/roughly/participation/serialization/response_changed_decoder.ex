defimpl Commanded.Serialization.JsonDecoder, for: Roughly.Participation.Events.ResponseChanged do
  def decode(event), do: %{event | context: Roughly.Participation.Context.from_map(event.context)}
end
