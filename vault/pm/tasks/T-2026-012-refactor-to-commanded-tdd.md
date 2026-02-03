---
type: task
id: T-2026-012
story:
epic:
status: completed
priority: p0
created: 2026-02-03
updated: 2026-02-03
---

# Task: Refactor to Commanded Event-Sourcing with TDD

## Task Details
**Task ID**: T-2026-012
**Status**: Backlog
**Priority**: P0 (Critical - fixes architectural mistake)
**Branch**: feat/T-2026-012-refactor-to-commanded-tdd
**Created**: 2026-02-03

## Description

Refactor the current CQRS code structure to properly use Commanded for event-sourcing. The current implementation created plain Ecto schemas without:
- TDD (tests first)
- Commanded aggregates
- Events
- Projectors

This task fixes that by implementing the proper event-sourced architecture following the `_reference/winners` patterns.

## What Needs to Change

### Remove
- `lib/roughly/demographics.ex` - demographics are just questions, not a separate context
- `lib/roughly/demographics/` - entire folder
- Current placeholder context gateways (questions.ex, voting.ex, users.ex at root)

### Restructure Following Winners Pattern
```
lib/roughly/
├── questions/
│   ├── questions.ex           # Aggregate (not context gateway)
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
│       ├── vote.ex
│       └── projector.ex
├── users/
│   ├── users.ex               # Aggregate
│   ├── commands.ex
│   ├── events.ex
│   └── projections/
│       ├── user.ex
│       ├── user_profile.ex
│       └── projector.ex
├── app.ex                     # Commanded.Application
├── router.ex                  # Command router
└── event_store.ex             # Already exists
```

## Checklist

### Phase 1: Setup & Cleanup
- [x] Remove demographics context (demographics are questions)
- [x] Update CLAUDE.md with TDD + Commanded requirements
- [x] Add commanded_ecto_projections dependency

### Phase 2: Questions Domain (TDD)
- [x] Write tests for CreateQuestion command
- [x] Create Questions aggregate
- [x] Create Questions.Commands module
- [x] Create Questions.Events module
- [x] Create Question projection schema
- [x] Create Questions.Projector

### Phase 3: Voting Domain (TDD)
- [x] Write tests for CastVote command
- [x] Create Voting aggregate
- [x] Create Voting.Commands module
- [x] Create Voting.Events module
- [x] Create Vote projection schema
- [x] Create Voting.Projector

### Phase 4: Users Domain (TDD)
- [x] Write tests for RegisterUser command
- [x] Create Users aggregate
- [x] Create Users.Commands module
- [x] Create Users.Events module
- [x] Create User projection schema
- [x] Create Users.Projector

### Phase 5: Wire Up
- [x] Create Roughly.App (Commanded.Application) - updated
- [x] Create Roughly.Router (Command router)
- [x] Verify all tests pass (26 tests)

## Reference
- `_reference/winners/lib/winners/bankroll/` - Aggregate pattern
- `_reference/winners/lib/winners/router.ex` - Router pattern
- `_reference/winners/lib/winners/app.ex` - Application pattern
- `_reference/winners/test/winners/bankroll/` - Test patterns

## Notes
- Follow TDD strictly: write failing test FIRST, then implement
- Demographics are questions with demographic answer options
- User profiles capture demographics, but that's just data on the User aggregate
