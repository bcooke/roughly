# CLAUDE.md

> **Crucial**: usage of this file is **mandatory** for this project.
> This file combines Chris McCord's "Phoenix Agents" best practices with the specific architecture of Roughly.

## Product Vision

> **Read [[vault/product/Product Vision]] to understand what we're building.**

**TL;DR**: Wikipedia for quantifiable human data. Free, open, searchable polling data with demographic slicing. "What percentage of people think X?" answered definitively.

## Project Context
- **Name**: Roughly (roughly.io)
- **Goal**: Build the definitive source for "what do people think/do/prefer"
- **Stack**: Elixir, Phoenix 1.8+, LiveView, Commanded (CQRS/ES), EventStore, PostgreSQL
- **Testing**: TDD with ExUnit - tests first, always
- **Privacy**: Accounts required to vote, but individual responses are never public (aggregate-only)

## Reference Code
- `_reference/winners/` - Commanded/event-sourcing patterns (primary reference)
- `_reference/flojo/` - Phoenix/LiveView patterns, CQRS folder structure

## Chris McCord's Phoenix Rules (Strict Enforcement)

### 1. LiveView Streams
- **Always** use `phx-update="stream"` on the parent element of a list
- **Always** consume the stream with the ID used as the DOM ID for each child
- **Never** iterate streams with `Enum` functions in templates
- **Do not** use `phx-update="ignore"` unless managing DOM with a JS hook

### 2. Testing Patterns
- **Never** write tests against raw HTML strings
- **Use** `LiveViewTest.render_submit` and `render_change` for form tests
- **Use** Phoenix.test element helpers
- **Isolate** external calls using Mox

### 3. Ecto & Database
- **Always** preload associations if accessed in templates
- **Use** binary_id (UUIDs) for all schemas
- **CQRS**: Write Side = Commanded Aggregates. Read Side = Ecto Projections
- **Never** access Write Side database tables directly; query Read Models only

### 4. Elixir Idioms
- **No** index-based list access (`list[0]` is O(N)). Use pattern matching
- **Bind** results of `if`/`case` blocks if used for side effects
- **Avoid** `String.to_atom/1` on dynamic user input

## TDD Workflow (Mandatory)

All code changes **must** follow test-driven development:

1. **Red**: Write a failing test that describes the desired behavior
2. **Green**: Write the minimal implementation to make the test pass
3. **Refactor**: Clean up while keeping tests green

### Rules
- **Never** write implementation code without a failing test first
- **Unit tests** for pure logic (domain modules, aggregates)
- **Aggregate tests** for CQRS commands
- **LiveView tests** for UI interactions
- **Run `MIX_ENV=test mix test`** before considering any task complete

### Test File Conventions
- Test for `lib/roughly/foo/bar.ex` lives at `test/roughly/foo/bar_test.exs`
- Test for `lib/roughly_web/live/foo_live.ex` lives at `test/roughly_web/live/foo_live_test.exs`

## Event-Sourced Architecture (Commanded)

### Core Pattern
```
Command → Router → Aggregate → Event → EventStore → Projector → Read Model
```

### Structure
```
lib/roughly/
├── questions/
│   ├── questions.ex           # Aggregate
│   ├── commands.ex            # Command structs
│   ├── events.ex              # Event structs
│   └── projections/
│       ├── question.ex        # Read model schema
│       └── projector.ex       # Event handler
├── voting/
│   ├── voting.ex              # Aggregate
│   ├── commands.ex
│   ├── events.ex
│   └── projections/
├── users/
│   ├── users.ex               # Aggregate
│   ├── commands.ex
│   ├── events.ex
│   └── projections/
├── app.ex                     # Commanded.Application
├── router.ex                  # Command router
└── event_store.ex             # EventStore wrapper
```

### Key Rules
- Aggregates handle commands and emit events (pure functions)
- Events are immutable facts - include `@derive Jason.Encoder`
- Projectors listen to events and update read models
- **Never** query aggregates for UI - only projections
- Demographics are just questions - no separate context needed

### Aggregate Pattern
```elixir
def execute(%__MODULE__{}, %CreateQuestion{} = cmd) do
  %QuestionCreated{question_id: cmd.question_id, text: cmd.text}
end

def apply(%__MODULE__{} = state, %QuestionCreated{} = event) do
  %__MODULE__{state | id: event.question_id, text: event.text}
end
```

## Git Workflow

- **Never** commit directly to main
- **Always** create feature branch: `feat/T-YYYY-NNN-description`
- **Squash merge** only (linear history)
- **One task** = one branch = one PR

## Commands
- **Run Tests**: `MIX_ENV=test mix test`
- **Start Server**: `mix phx.server`
- **Database Setup**: `mix setup`
- **EventStore Setup**: `mix event_store.setup`

## Current Work

See [[PROJECT_STATUS]] for active tasks and progress.
