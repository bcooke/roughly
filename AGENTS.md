# AGENTS.md

This file provides guidance to AI coding assistants when working with code in this repository.

## Project Overview

Roughly is a Phoenix LiveView application that implements CQRS (Command Query Responsibility Segregation) with event sourcing via Commanded. It's building "Wikipedia for quantifiable human data" - a free, open, searchable database of polling data.

**Technology Stack:**
- Phoenix 1.7+ with LiveView
- Elixir with Commanded for event sourcing
- PostgreSQL with EventStore
- Tailwind CSS
- TDD from day one with ExUnit

## Project Values

1. **Free and open**: Wikipedia model, not VC-backed or paywalled like Gallup
2. **Epistemological humility**: All data is approximate (hence "Roughly" and the ≈ symbol)
3. **Transparency**: Show methodology, confidence levels, sample sizes
4. **Privacy-first**: Accounts required, but individual responses are never public
5. **Event-sourced**: Complete audit trail for every vote

## Privacy Model: "Anonymous but Accountable"

This is a core architectural principle:

- **Accounts required to vote**: No anonymous voting - incentivizes quality responses
- **Individual answers are NEVER public**: Only aggregate data is visible
- **Demographic slicing**: Show "60% of women under 30 prefer X", never "user@email.com chose X"
- **k-anonymity**: Consider thresholds (e.g., only show slices with 10+ responses)
- **Potential encryption**: Consider encrypting individual vote records

See [[Product Vision#Privacy Model]] for detailed rationale.

## Git Workflow - CRITICAL RULES

**All changes to main require a PR:**
- Squash merge only (linear history)
- Delete branch after merge
- One task = one branch = one PR

**Branch naming**: `feat/T-YYYY-NNN-description` or `fix/T-YYYY-NNN-description`

**Commit messages**: Follow conventional commits
```
feat: add question search functionality
fix: correct vote count aggregation
chore: update dependencies
```

**NEVER commit directly to main**. Always create a feature branch first.

## Project Management (Balustrade)

This project uses the Balustrade PM system. Key files:

- **PROJECT_STATUS.md**: Single source of truth for project status
- **vault/pm/tasks/**: Task definitions with checklists
- **vault/pm/_context/**: Working context documents for active tasks

**Workflow:**
1. Check PROJECT_STATUS.md for current focus
2. Use `/s T-YYYY-NNN` to start a task
3. Create branch, implement, create PR
4. Use `/c T-YYYY-NNN` to close task after merge

## Development Commands

### Setup
```bash
# Full project setup
mix setup

# Install dependencies
mix deps.get

# Setup databases (Ecto + EventStore)
mix ecto.setup
mix event_store.setup
```

### Development Server
```bash
# Start Phoenix server
mix phx.server

# Start with interactive shell
iex -S mix phx.server
```

### Testing (TDD from Day One)
```bash
# Run all tests
MIX_ENV=test mix test

# Run specific test file
MIX_ENV=test mix test test/roughly/questions_test.exs

# Run tests in watch mode
MIX_ENV=test mix test.watch

# Run with coverage
MIX_ENV=test mix test --cover
```

**Important**: Always run tests with `MIX_ENV=test`.

### Code Quality
```bash
# Format code
mix format

# Run Credo linter
mix credo

# Pre-commit checks (format + credo + tests)
mix precommit
```

### Database
```bash
# Run migrations
mix ecto.migrate

# Reset database
mix ecto.reset

# EventStore operations
mix event_store.create
mix event_store.init
```

## Architecture Overview

### CQRS + Event Sourcing

Roughly uses strict CQRS with Commanded:

```
User Action → Command → Aggregate → Event → Projector → Read Model
```

**Commands**: Write operations that may produce events
**Queries**: Read operations against projected read models
**Events**: Immutable facts about what happened
**Projections**: Materialized views for fast reads

### Project Structure

```
lib/roughly/
├── questions/              # Questions domain
│   ├── commands/           # CreateQuestion, UpdateQuestion
│   ├── queries/            # GetQuestion, SearchQuestions
│   ├── schemas/            # Question, AnswerOption
│   ├── events/             # QuestionCreated, QuestionUpdated
│   └── projectors/         # QuestionSummary projector
├── voting/                 # Voting domain
│   ├── commands/           # CastVote, RetractVote
│   ├── queries/            # GetVoteCounts
│   ├── schemas/            # Vote
│   └── events/             # VoteCast, VoteRetracted
├── users/                  # Users domain
│   ├── commands/           # RegisterUser, UpdateProfile
│   ├── queries/            # GetUser
│   └── schemas/            # User, UserProfile
├── demographics/           # Demographics domain
└── questions.ex            # Context gateway

lib/roughly_web/
├── live/                   # LiveView modules
├── components/             # Phoenix components
└── controllers/            # REST controllers (if needed)
```

### Key Contexts

**Questions**: Question creation, editing, categorization, search. Core domain for the polling questions.

**Voting**: Vote casting, counting, demographic snapshot capture. Handles the core voting logic with privacy constraints.

**Users**: Authentication, profiles, demographic data. Accounts are required for voting.

**Demographics**: Demographic definitions, slicing logic, population overlap queries.

### Communication Patterns

**Command Execution**:
```elixir
# Commands mutate state via aggregates
{:ok, result} = Questions.execute(%CreateQuestion{text: "...", options: [...]})

# Queries fetch from read models
{:ok, question} = Questions.execute(%GetQuestion{id: question_id})
```

**LiveView Integration**:
```elixir
def handle_event("cast_vote", %{"answer" => answer}, socket) do
  command = %CastVote{
    question_id: socket.assigns.question.id,
    user_id: socket.assigns.current_user.id,
    answer: answer
  }

  case Voting.execute(command) do
    {:ok, _} -> {:noreply, put_flash(socket, :info, "Vote recorded")}
    {:error, reason} -> {:noreply, put_flash(socket, :error, reason)}
  end
end
```

## Development Guidelines

### TDD First

Write tests before implementation:
1. Write a failing test for the expected behavior
2. Implement the minimum code to pass
3. Refactor while keeping tests green

### Event Sourcing Patterns

**Aggregates**: Business logic lives in aggregates
```elixir
defmodule Roughly.Questions.Aggregates.Question do
  use Commanded.Aggregates.Aggregate

  def execute(%Question{}, %CreateQuestion{} = cmd) do
    %QuestionCreated{
      question_id: cmd.question_id,
      text: cmd.text,
      options: cmd.options
    }
  end

  def apply(%Question{} = state, %QuestionCreated{} = event) do
    %Question{state |
      id: event.question_id,
      text: event.text,
      options: event.options
    }
  end
end
```

**Projectors**: Build read models from events
```elixir
defmodule Roughly.Questions.Projectors.QuestionSummary do
  use Commanded.Projections.Ecto

  project %VoteCast{} = event, _metadata, fn multi ->
    Ecto.Multi.update_all(multi, :inc_count,
      from(q in QuestionSummary, where: q.question_id == ^event.question_id),
      inc: [total_votes: 1]
    )
  end
end
```

### CQRS Code Style

**Commands**: Named as actions, always validate
```elixir
defmodule Roughly.Questions.Commands.CreateQuestion do
  defstruct [:question_id, :text, :options, :category]

  def execute(%__MODULE__{} = cmd) do
    # Validation and dispatch
  end
end
```

**Queries**: Named as requests, return {:ok, result} or {:error, reason}
```elixir
defmodule Roughly.Questions.Queries.GetQuestion do
  def execute(%{id: id}) do
    case Repo.get(Question, id) do
      nil -> {:error, :not_found}
      question -> {:ok, question}
    end
  end
end
```

### Context Isolation

Contexts should only communicate through their public APIs:
```elixir
# Good: Use context function
user = Users.get_user!(user_id)

# Bad: Direct schema access across contexts
user = Repo.get!(Roughly.Users.Schemas.User, user_id)
```

## Elixir Guidelines

- **Use `mix precommit`** before committing
- **Use `Req`** for HTTP requests (included by default)
- **Lists don't support index access** - use `Enum.at/2` not `list[i]`
- **Variable rebinding in blocks**: Bind the result of `if`/`case`/`cond` to a variable
- **Never nest multiple modules** in the same file
- **Don't use map access on structs** - use `struct.field` or `Ecto.Changeset.get_field/2`
- **Predicate functions** end with `?`, don't start with `is_`
- **Task.async_stream** for concurrent operations (usually with `timeout: :infinity`)

## Ecto Guidelines

- **Always preload associations** that will be accessed in templates
- **Use `:string` type** for text columns (not `:text`)
- **Use `Ecto.Changeset.get_field/2`** to access changeset fields
- **Don't cast user_id** or other programmatic fields - set explicitly

## Phoenix LiveView Guidelines

- **Use `<.link navigate={...}>`** not deprecated `live_redirect`
- **Avoid LiveComponents** unless specifically needed
- **Name LiveViews with `Live` suffix**: `RoughlyWeb.QuestionLive`
- **Use streams for collections** to avoid memory issues
- **Always give forms unique IDs**: `<.form for={@form} id="vote-form">`

### LiveView Streams

```elixir
# Initialize stream
socket = stream(socket, :questions, questions)

# Reset stream (for filtering)
socket = stream(socket, :questions, filtered_questions, reset: true)

# Template
<div id="questions" phx-update="stream">
  <div :for={{id, question} <- @streams.questions} id={id}>
    {question.text}
  </div>
</div>
```

### Form Handling

```elixir
# Always use to_form
socket = assign(socket, form: to_form(changeset))

# Template
<.form for={@form} id="question-form" phx-submit="save">
  <.input field={@form[:text]} type="text" />
</.form>
```

## HEEx Template Guidelines

- **Use `{...}` for interpolation** in attributes and values
- **Use `<%= ... %>` only for block constructs** (if, for, cond, case)
- **Class lists require `[...]`**: `class={["base", @flag && "conditional"]}`
- **Use `:for` for iteration**: `<div :for={item <- @items}>`
- **Comments**: `<%!-- comment --%>`

## Testing Guidelines

### Unit Tests
```elixir
defmodule Roughly.Questions.Commands.CreateQuestionTest do
  use Roughly.DataCase

  describe "execute/1" do
    test "creates question with valid params" do
      params = %{text: "Do you like coffee?", options: ["Yes", "No"]}
      assert {:ok, question} = CreateQuestion.execute(params)
      assert question.text == "Do you like coffee?"
    end

    test "returns error with invalid params" do
      assert {:error, changeset} = CreateQuestion.execute(%{})
      assert "can't be blank" in errors_on(changeset).text
    end
  end
end
```

### Integration Tests
```elixir
defmodule RoughlyWeb.QuestionLiveTest do
  use RoughlyWeb.ConnCase
  import Phoenix.LiveViewTest

  test "displays question", %{conn: conn} do
    question = insert(:question)
    {:ok, view, _html} = live(conn, ~p"/questions/#{question.slug}")
    assert has_element?(view, "#question-#{question.id}")
  end
end
```

## Agent System

Roughly uses specialized agents in `.claude/agents/`:

- **coordinator** - Orchestrates complex multi-domain work
- **full-stack-dev** - Primary code author for end-to-end implementation
- **bug-hunter** - Debugging specialist
- **code-reviewer** - Code quality and review
- **vault-writer** - Documentation creation
- **product-manager** - Product vision and prioritization

**For simple tasks**: Work directly
**For complex tasks**: Use the coordinator agent

## Skills System

Skills in `.claude/skills/` provide auto-activating procedural guides:

- **event-sourcing** - Commanded patterns for aggregates, commands, events
- **liveview** - Phoenix LiveView patterns
- **ecto** - Schema, migrations, queries
- **test-setup** - ExUnit testing patterns
- **api-design** - REST API patterns
- **docs** - Documentation writing
- **refactor** - Code refactoring patterns

## Vault Documentation

The `vault/` directory contains project documentation:

- **vault/product/**: Product vision, glossary, design philosophy
- **vault/architecture/**: System architecture, data model
- **vault/features/**: Feature documentation
- **vault/pm/**: Tasks, context docs, PM artifacts
- **vault/how-to/**: Development guides

When the user shares insights or decisions, update the relevant vault documentation to capture them.

## Reference Materials

The `_reference/` directory contains example projects:
- **flojo**: CQRS patterns, LiveView + Vue hybrid
- **goflojo**: Go implementation reference
- **Eden**: Additional patterns

Use these for inspiration but adapt patterns for Roughly's needs.

## Key Documentation Links

- [[Product Vision]] - What we're building and why
- [[System Architecture]] - Technical architecture
- [[Data Model]] - Question, vote, user schemas
- [[Glossary]] - Key terminology
- [[Design Philosophy]] - Visual design principles
