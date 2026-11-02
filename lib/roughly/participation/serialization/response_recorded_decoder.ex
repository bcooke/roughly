defimpl Commanded.Serialization.JsonDecoder, for: Roughly.Participation.Events.ResponseRecorded do
  def decode(event), do: %{event | context: Roughly.Participation.Context.from_map(event.context)}
end
