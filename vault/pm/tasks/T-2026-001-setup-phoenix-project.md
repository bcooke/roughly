---
type: task
id: T-2026-001
story:
epic:
status: completed
priority: p0
created: 2025-02-02
updated: 2025-02-02
---

# Task: Set Up Phoenix/Elixir Project

## Task Details
**Task ID**: T-2026-001
**Story**: -
**Epic**: -
**Status**: Completed
**Priority**: P0 (Foundation)
**Branch**: feat/T-2026-001-setup-phoenix-project
**Created**: 2025-02-02
**Started**: 2026-02-03
**Completed**: 2026-02-03

## Description
Initialize the Phoenix/Elixir project structure with Commanded for event sourcing. This establishes the technical foundation for Roughly.

## Checklist
- [x] Verify Elixir/Phoenix toolchain installed
- [x] Run `mix phx.new roughly --live` to create Phoenix project
- [x] Add Commanded and related dependencies
- [x] Configure PostgreSQL connection
- [x] Set up basic event store
- [x] Create placeholder aggregates (Question, Vote, User)
- [x] Configure ExUnit for TDD
- [x] Verify LiveView working with hello world

## Technical Details
### Approach
- Use Phoenix 1.7+ with LiveView
- Configure Commanded for CQRS/ES pattern
- Set up umbrella app structure if needed
- TDD from the start

### Dependencies to Add
```elixir
{:commanded, "~> 1.4"},
{:commanded_eventstore_adapter, "~> 1.4"},
{:eventstore, "~> 1.4"},
{:jason, "~> 1.4"}
```

### Testing Required
- [x] Phoenix server starts
- [x] LiveView hello world renders
- [x] Event store connection works
- [x] ExUnit runs

### Documentation Updates
- Update README with actual setup instructions
- Document any deviations from planned architecture

## Dependencies
### Blocked By
- T-2025-001 (Template transformation - must complete first)

### Blocks
- All feature development

## Context
See [[T-2026-001-context]] for detailed implementation notes.

## Notes
- Requires Elixir 1.15+ and Erlang/OTP 26+
- Requires PostgreSQL 15+
- May need to adjust architecture docs based on actual implementation
