---
name: event-sourcing
description: Commanded CQRS/ES patterns for Elixir. Aggregates, commands, events, and projections.
---

# Event Sourcing Skill

Best practices for building event-sourced systems with Commanded in Elixir.

## Core Concepts

1. **Aggregates** - Domain entities that handle commands and emit events
2. **Commands** - Intentions to change state
3. **Events** - Immutable facts about what happened
4. **Projections** - Read models built from events

## Aggregate Design

### Basic Structure

```elixir
defmodule Roughly.Questions.Aggregates.Question do
  defstruct [:uuid, :text, :question_type, :responses, :status]

  # Commands
  alias Roughly.Questions.Commands.{CreateQuestion, AddResponse}

  # Events
  alias Roughly.Questions.Events.{QuestionCreated, ResponseAdded}

  # Command handlers
  def execute(%__MODULE__{uuid: nil}, %CreateQuestion{} = cmd) do
    %QuestionCreated{
      uuid: cmd.uuid,
      text: cmd.text,
      question_type: cmd.question_type
    }
  end

  def execute(%__MODULE__{uuid: nil}, _cmd) do
    {:error, :question_not_found}
  end

  def execute(%__MODULE__{}, %AddResponse{} = cmd) do
    %ResponseAdded{
      question_uuid: cmd.question_uuid,
      response_uuid: cmd.response_uuid,
      text: cmd.text
    }
  end

  # Event handlers
  def apply(%__MODULE__{} = question, %QuestionCreated{} = event) do
    %__MODULE__{question |
      uuid: event.uuid,
      text: event.text,
      question_type: event.question_type,
      status: :draft,
      responses: []
    }
  end

  def apply(%__MODULE__{} = question, %ResponseAdded{} = event) do
    %__MODULE__{question |
      responses: question.responses ++ [event.response_uuid]
    }
  end
end
```

### Command Design

```elixir
defmodule Roughly.Questions.Commands.CreateQuestion do
  @enforce_keys [:uuid, :text, :question_type]
  defstruct [:uuid, :text, :question_type, :user_uuid]

  use ExConstructor
end
```

**Best Practices**:
- Use `@enforce_keys` for required fields
- Include correlation/causation IDs for tracing
- Keep commands small and focused
- Validate early in command middleware

### Event Design

```elixir
defmodule Roughly.Questions.Events.QuestionCreated do
  @derive Jason.Encoder
  defstruct [:uuid, :text, :question_type, :created_at]
end
```

**Best Practices**:
- Events are immutable facts
- Include timestamp
- Use `@derive Jason.Encoder` for serialization
- Never change event structure (add new events instead)

## Command Routing

```elixir
defmodule Roughly.Router do
  use Commanded.Commands.Router

  alias Roughly.Questions.Aggregates.Question
  alias Roughly.Questions.Commands.{CreateQuestion, AddResponse}

  dispatch CreateQuestion, to: Question, identity: :uuid
  dispatch AddResponse, to: Question, identity: :question_uuid
end
```

## Projections (Read Models)

### Ecto Projection

```elixir
defmodule Roughly.Questions.Projections.QuestionSummary do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}
  schema "question_summaries" do
    field :text, :string
    field :question_type, :string
    field :response_count, :integer, default: 0
    field :vote_count, :integer, default: 0

    timestamps()
  end
end
```

### Event Handler for Projection

```elixir
defmodule Roughly.Questions.Projectors.QuestionSummary do
  use Commanded.Projections.Ecto,
    application: Roughly.App,
    repo: Roughly.Repo,
    name: "question_summary"

  alias Roughly.Questions.Events.{QuestionCreated, ResponseAdded}
  alias Roughly.Questions.Projections.QuestionSummary

  project(%QuestionCreated{} = event, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :question_summary, %QuestionSummary{
      uuid: event.uuid,
      text: event.text,
      question_type: event.question_type
    })
  end)

  project(%ResponseAdded{} = event, _metadata, fn multi ->
    Ecto.Multi.update_all(multi, :increment_responses,
      from(q in QuestionSummary, where: q.uuid == ^event.question_uuid),
      inc: [response_count: 1]
    )
  end)
end
```

## Testing Aggregates

```elixir
defmodule Roughly.Questions.Aggregates.QuestionTest do
  use Roughly.AggregateCase, aggregate: Roughly.Questions.Aggregates.Question

  alias Roughly.Questions.Commands.CreateQuestion
  alias Roughly.Questions.Events.QuestionCreated

  describe "CreateQuestion command" do
    test "creates a new question" do
      uuid = UUID.uuid4()

      assert_events(
        CreateQuestion.new(
          uuid: uuid,
          text: "What is your favorite color?",
          question_type: :multiple_choice
        ),
        [
          %QuestionCreated{
            uuid: uuid,
            text: "What is your favorite color?",
            question_type: :multiple_choice
          }
        ]
      )
    end
  end
end
```

### Aggregate Test Helper

```elixir
defmodule Roughly.AggregateCase do
  defmacro __using__(opts) do
    aggregate = Keyword.fetch!(opts, :aggregate)

    quote do
      use ExUnit.Case, async: true

      def assert_events(command, expected_events) do
        assert {:ok, events} = unquote(aggregate).execute(%unquote(aggregate){}, command)
        assert events == expected_events
      end

      def assert_error(command, expected_error) do
        assert {:error, ^expected_error} = unquote(aggregate).execute(%unquote(aggregate){}, command)
      end
    end
  end
end
```

## Event Versioning

### Upcasting Old Events

```elixir
defmodule Roughly.Questions.Events.QuestionCreated do
  @derive Jason.Encoder
  defstruct [:uuid, :text, :question_type, :created_at]

  # Handle v1 events (no created_at)
  defimpl Commanded.Event.Upcaster do
    def upcast(%{created_at: nil} = event, _metadata) do
      %{event | created_at: DateTime.utc_now()}
    end

    def upcast(event, _metadata), do: event
  end
end
```

## Process Managers (Sagas)

```elixir
defmodule Roughly.Questions.ProcessManagers.QuestionLifecycle do
  use Commanded.ProcessManagers.ProcessManager,
    application: Roughly.App,
    name: "QuestionLifecycle"

  alias Roughly.Questions.Events.{QuestionCreated, QuestionActivated}
  alias Roughly.Questions.Commands.NotifyQuestionCreated

  @derive Jason.Encoder
  defstruct [:question_uuid]

  def interested?(%QuestionCreated{uuid: uuid}), do: {:start, uuid}
  def interested?(%QuestionActivated{question_uuid: uuid}), do: {:continue, uuid}
  def interested?(_event), do: false

  def handle(%__MODULE__{}, %QuestionCreated{} = event) do
    %NotifyQuestionCreated{question_uuid: event.uuid}
  end

  def apply(%__MODULE__{} = pm, %QuestionCreated{uuid: uuid}) do
    %__MODULE__{pm | question_uuid: uuid}
  end
end
```

## Best Practices

### Do
- Keep aggregates small and focused
- Use domain language in commands and events
- Test at the aggregate level
- Version events from day one
- Use metadata for correlation IDs

### Don't
- Put business logic in projections
- Query the event store directly for reads
- Modify past events
- Use aggregates for queries
- Couple aggregates together

## Debugging

### Event Store Queries

```elixir
# List all events for a stream
Roughly.EventStore.read_stream_forward(stream_uuid)

# Get aggregate version
Roughly.EventStore.stream_info(stream_uuid)
```

### Commanded Inspection

```elixir
# Get current aggregate state
Commanded.Aggregates.Aggregate.aggregate_state(
  Roughly.App,
  Roughly.Questions.Aggregates.Question,
  question_uuid
)
```

## Remember

- Events are the source of truth
- Aggregates enforce business rules
- Projections are disposable (can rebuild)
- Commands express intent
- Think in terms of domain events
