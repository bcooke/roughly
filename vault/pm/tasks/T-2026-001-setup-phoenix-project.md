---
type: task
id: T-2026-001
story:
epic:
status: backlog
priority: p0
created: 2025-02-02
updated: 2025-02-02
---

# Task: Set Up Phoenix/Elixir Project

## Task Details
**Task ID**: T-2026-001
**Story**: -
**Epic**: -
**Status**: Backlog
**Priority**: P0 (Foundation)
**Branch**: feat/T-2026-001-setup-phoenix-project
**Created**: 2025-02-02
**Started**:
**Completed**:

## Description
Initialize the Phoenix/Elixir project structure with Commanded for event sourcing. This establishes the technical foundation for Roughly.

## Checklist
- [ ] Verify Elixir/Phoenix toolchain installed
- [ ] Run `mix phx.new roughly --live` to create Phoenix project
- [ ] Add Commanded and related dependencies
- [ ] Configure PostgreSQL connection
- [ ] Set up basic event store
- [ ] Create placeholder aggregates (Question, Vote, User)
- [ ] Configure ExUnit for TDD
- [ ] Verify LiveView working with hello world

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
- [ ] Phoenix server starts
- [ ] LiveView hello world renders
- [ ] Event store connection works
- [ ] ExUnit runs

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
