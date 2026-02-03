defmodule Roughly.Questions do
  @moduledoc """
  The Questions context.

  This is the core gateway module for question management in Roughly.
  Handles question creation, retrieval, search, and relationship management.

  Follows CQRS pattern:
  - Commands in `Roughly.Questions.Commands.*` for write operations
  - Queries in `Roughly.Questions.Queries.*` for read operations
  - Schemas in `Roughly.Questions.Schemas.*` for data structures

  ## Examples

      # Create a new question
      {:ok, question} = Questions.create_question(%{
        text: "Do you like coffee?",
        question_type: :binary,
        options: ["Yes", "No"]
      })

      # Get a question by ID
      {:ok, question} = Questions.get_question(question_id)

      # Search questions
      {:ok, questions} = Questions.search_questions(%{query: "coffee"})
  """

  import Ecto.Query, warn: false

  alias Roughly.Repo
  alias Roughly.Commands.Error
  alias Roughly.Questions.Schemas.Question

  # ============================================================================
  # Commands (Write Operations)
  # ============================================================================

  @doc """
  Creates a new question.

  ## Parameters
    - attrs: Map containing question attributes
      - text: The question text (required)
      - question_type: :binary, :multiple_choice, or :scaled (required)
      - options: List of answer options (required for binary/multiple_choice)
      - category: Optional category string
      - methodology: Optional methodology description

  ## Returns
    - {:ok, question} on success
    - {:error, Error.t()} on failure
  """
  @spec create_question(map()) :: {:ok, Question.t()} | {:error, Error.t()}
  def create_question(attrs) do
    # TODO: Implement via Roughly.Questions.Commands.CreateQuestion
    {:error, Error.new(:not_implemented, "CreateQuestion command not yet implemented")}
  end

  @doc """
  Updates an existing question.
  """
  @spec update_question(Question.t(), map()) :: {:ok, Question.t()} | {:error, Error.t()}
  def update_question(%Question{} = question, attrs) do
    # TODO: Implement via Roughly.Questions.Commands.UpdateQuestion
    {:error, Error.new(:not_implemented, "UpdateQuestion command not yet implemented")}
  end

  @doc """
  Closes a question, preventing further votes.
  """
  @spec close_question(Question.t()) :: {:ok, Question.t()} | {:error, Error.t()}
  def close_question(%Question{} = question) do
    # TODO: Implement via Roughly.Questions.Commands.CloseQuestion
    {:error, Error.new(:not_implemented, "CloseQuestion command not yet implemented")}
  end

  # ============================================================================
  # Queries (Read Operations)
  # ============================================================================

  @doc """
  Gets a question by ID.
  """
  @spec get_question(Ecto.UUID.t()) :: {:ok, Question.t()} | {:error, Error.t()}
  def get_question(id) do
    # TODO: Implement via Roughly.Questions.Queries.GetQuestion
    {:error, Error.new(:not_implemented, "GetQuestion query not yet implemented")}
  end

  @doc """
  Gets a question by slug.
  """
  @spec get_question_by_slug(String.t()) :: {:ok, Question.t()} | {:error, Error.t()}
  def get_question_by_slug(slug) do
    # TODO: Implement via Roughly.Questions.Queries.GetQuestionBySlug
    {:error, Error.new(:not_implemented, "GetQuestionBySlug query not yet implemented")}
  end

  @doc """
  Searches questions by text.
  """
  @spec search_questions(map()) :: {:ok, list(Question.t())} | {:error, Error.t()}
  def search_questions(params \\ %{}) do
    # TODO: Implement via Roughly.Questions.Queries.SearchQuestions
    {:error, Error.new(:not_implemented, "SearchQuestions query not yet implemented")}
  end

  @doc """
  Lists questions with optional filtering and pagination.
  """
  @spec list_questions(map()) :: {:ok, list(Question.t())} | {:error, Error.t()}
  def list_questions(params \\ %{}) do
    # TODO: Implement via Roughly.Questions.Queries.ListQuestions
    {:error, Error.new(:not_implemented, "ListQuestions query not yet implemented")}
  end

  @doc """
  Gets related questions for a given question.
  """
  @spec get_related_questions(Ecto.UUID.t(), map()) ::
          {:ok, list(Question.t())} | {:error, Error.t()}
  def get_related_questions(question_id, params \\ %{}) do
    # TODO: Implement via Roughly.Questions.Queries.GetRelatedQuestions
    {:error, Error.new(:not_implemented, "GetRelatedQuestions query not yet implemented")}
  end

  # ============================================================================
  # Changeset Functions (for forms)
  # ============================================================================

  @doc """
  Returns a changeset for tracking question changes.
  """
  @spec change_question(Question.t(), map()) :: Ecto.Changeset.t()
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end
end
