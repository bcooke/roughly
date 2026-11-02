defmodule Roughly.QuestionFixtures do
  @moduledoc "Read-side fixtures for query and interface tests; runtime seeds use commands."
  alias Roughly.Repo
  alias Roughly.Questions.Projections.Question
  alias Roughly.Voting.Projections.Vote

  def question(attrs \\ %{}) do
    id = Ecto.UUID.generate()

    defaults = %{
      uuid: id,
      text: "Do you like the taste of coffee?",
      slug: "coffee-#{id}",
      question_type: :multiple_choice,
      options: ["Yes", "No", "It depends"],
      category: "Food & drink",
      status: :active
    }

    Repo.insert!(struct!(Question, Map.merge(defaults, attrs)))
  end

  def response_fixture(question, option, attrs \\ %{}) do
    defaults = %{
      uuid: Ecto.UUID.generate(),
      question_uuid: question.uuid,
      user_uuid: Ecto.UUID.generate(),
      option_id: option,
      status: :active
    }

    Repo.insert!(struct!(Vote, Map.merge(defaults, attrs)))
  end
end
