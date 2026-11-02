defimpl Commanded.Serialization.JsonDecoder, for: Roughly.Questions.Events.QuestionCreated do
  def decode(event) do
    %{
      event
      | question_type: Roughly.Questions.Instrument.decode_kind!(event.question_type),
        options: Enum.map(event.options, &Roughly.Questions.Option.from_map/1)
    }
  end
end
