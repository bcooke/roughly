defmodule Roughly.Questions do
  @moduledoc "Public entry point for browsing questions and aggregate results."
  alias Roughly.Access.Actor
  alias Roughly.Questions.Commands.{CreateQuestion, CloseQuestion}
  alias Roughly.Questions.Queries

  @doc false
  @spec admit_answer(Ecto.UUID.t(), [Ecto.UUID.t()], Roughly.Participation.Context.t()) ::
          :ok | {:error, atom()}
  def admit_answer(id, selection, context),
    do:
      Roughly.Questions.Instrument.admit(
        Roughly.History.load(Roughly.Questions.Question, id),
        selection,
        context
      )

  @spec create(Actor.t(), map()) :: {:ok, Ecto.UUID.t()} | {:error, term()}
  def create(actor, attrs) do
    id = Ecto.UUID.generate()

    command =
      struct(
        CreateQuestion,
        Map.merge(
          Map.take(attrs, [:text, :language, :question_type, :options, :category, :slug]),
          %{
            question_uuid: id,
            created_by: actor.id
          }
        )
      )

    case publish(actor, command) do
      :ok -> {:ok, id}
      error -> error
    end
  end

  @doc false
  @spec publish(Actor.t(), CreateQuestion.t(), keyword()) :: :ok | {:error, term()}
  def publish(actor, command, opts \\ []) do
    with {:ok, parsed} <- Roughly.Validation.parse(command),
         {:ok, slug} <-
           Roughly.Questions.Slugs.claim(actor, parsed.question_uuid, parsed.slug, opts) do
      Roughly.Dispatch.dispatch(%{parsed | slug: slug}, actor, opts)
    end
  end

  @spec close(Actor.t(), Ecto.UUID.t()) :: :ok | {:error, term()}
  def close(actor, id),
    do: Roughly.Dispatch.dispatch(%CloseQuestion{question_uuid: id, closed_by: actor.id}, actor)

  @spec list_questions(keyword()) :: Roughly.Analysis.Result.page()
  defdelegate list_questions(filters \\ []), to: Queries.ListQuestions, as: :call
  @spec get_question(String.t()) :: Roughly.Analysis.Result.t() | nil
  defdelegate get_question(slug), to: Queries.GetQuestion, as: :call
  @spec list_topics() :: [%{name: String.t(), count: non_neg_integer()}]
  defdelegate list_topics(), to: Queries.ListTopics, as: :call

  @spec related_questions(Roughly.Analysis.Result.t()) :: [Roughly.Analysis.Result.t()]
  def related_questions(question) do
    result = list_questions(category: question.category, exclude: question.uuid, page_size: 4)
    result.entries
  end
end
