defmodule Roughly.QuestionFixtures do
  @moduledoc "Read-side fixtures for query and interface tests; runtime seeds use commands."
  alias Roughly.Repo
  alias Roughly.Questions.Projections.Question
  alias Roughly.Participation.Projections.Response

  def question(attrs \\ %{}) do
    id = Ecto.UUID.generate()

    defaults = %{
      uuid: id,
      text: "Do you like the taste of coffee?",
      slug: "coffee-#{id}",
      question_type: :single_choice,
      language: "en",
      options:
        Enum.map(
          ["Yes", "No", "It depends"],
          &Roughly.Questions.Option.new(Ecto.UUID.generate(), &1)
        ),
      category: "Food & drink",
      status: :active
    }

    values = Map.merge(defaults, attrs)

    values =
      Map.put(
        values,
        :search_document,
        Roughly.Search.Document.build(values.text, values.category, values.options)
      )

    Repo.insert!(struct!(Question, values))
  end

  def response_fixture(question, option, attrs \\ %{}) do
    defaults = %{
      uuid: Ecto.UUID.generate(),
      question_uuid: question.uuid,
      principal_uuid: Ecto.UUID.generate(),
      option_ids:
        Enum.map(List.wrap(option), fn label ->
          Enum.find(question.options, &(&1.label == label)).id
        end),
      context: %{},
      status: :active
    }

    Repo.insert!(struct!(Response, Map.merge(defaults, attrs)))
  end
end
