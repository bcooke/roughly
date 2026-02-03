---
type: task
id: T-2026-003
story:
epic:
status: backlog
priority: p2
created: 2026-02-03
updated: 2026-02-03
---

# Task: Add Elixir-Specific Skills

## Task Details
**Task ID**: T-2026-003
**Status**: Backlog
**Priority**: P2
**Branch**: feat/T-2026-003-add-elixir-skills
**Created**: 2026-02-03

## Description
Create Elixir/Phoenix-specific skills in `.claude/skills/` to provide domain expertise for the codebase.

## Checklist
- [ ] Create `event-sourcing.md` skill (Commanded patterns)
- [ ] Create `liveview.md` skill (Phoenix LiveView patterns)
- [ ] Create `ecto.md` skill (Schema, migrations, queries)
- [ ] Update `test-setup.md` for ExUnit patterns
- [ ] Update `api-design.md` for Phoenix conventions

## Skills to Create

### event-sourcing.md
- Commanded aggregate patterns
- Command/Event design
- Projection patterns
- Event versioning
- Testing aggregates

### liveview.md
- Component patterns
- PubSub for real-time
- Streams for large lists
- Form handling
- JavaScript hooks

### ecto.md
- Schema design
- Changeset patterns
- Query composition
- Migration best practices
- Embedded schemas

## Notes
- Reference Eden project for Elixir patterns
- Base on Commanded and Phoenix documentation
