---
type: task
id: T-2026-006
story:
epic:
status: in-progress
priority: p0
created: 2026-02-03
updated: 2026-02-03
---

# Task: Set Up CLAUDE.md and AGENTS.md

## Task Details
**Task ID**: T-2026-006
**Status**: In Progress
**Priority**: P0 (Foundation)
**Branch**: feat/T-2026-006-setup-claude-agents-md
**PR**: https://github.com/bcooke/roughly/pull/5
**Created**: 2026-02-03

## Description
Create proper CLAUDE.md and AGENTS.md files following the Phoenix/flojo baseline pattern but customized for Roughly. These files establish project context for AI assistants and document our conventions.

## Checklist
- [x] Create CLAUDE.md with project overview and critical rules
- [x] Create AGENTS.md with multi-agent system documentation
- [x] Document Balustrade PM conventions (tasks, PRs, commits)
- [x] Document vault structure and usage
- [x] Document architecture (event-sourcing, CQRS, TDD)
- [x] Document product vision and key concepts
- [x] Reference flojo patterns for CQRS code structure

## Technical Details
### CLAUDE.md Should Include
- Project overview (polling/statistics encyclopedia)
- Tech stack (Phoenix, Commanded, PostgreSQL)
- Critical workflow rules (PRs, commits, no Claude Code branding)
- Development commands (mix setup, test, server)
- Key architectural principles

### AGENTS.md Should Include
- Multi-agent system overview
- Agent descriptions and when to use them
- Skills system documentation
- CQRS code structure patterns
- Domain concepts (Questions, Votes, Demographics)

### Reference Materials
- `_reference/flojo/AGENTS.md` - CQRS patterns, agent structure
- `_reference/flojo/CLAUDE.md` - Redirect pattern
- `vault/product/Product Vision.md` - Roughly vision
- `vault/architecture/` - Architecture docs

## Dependencies
### Blocked By
- None (foundational)

### Blocks
- All future development (establishes conventions)

## Context
See [[T-2026-006-context]] for detailed implementation notes.

## Notes
- Base on Phoenix/flojo baseline but heavily customize for Roughly
- Emphasize: TDD, event-sourcing, no Claude Code branding
- Document the Balustrade PM system as project convention
