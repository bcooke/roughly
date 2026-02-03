---
type: task
id: T-2026-009
story:
epic:
status: in-progress
priority: p1
created: 2026-02-03
updated: 2026-02-03
---

# Task: Implement CQRS Code Structure

## Task Details
**Task ID**: T-2026-009
**Status**: In Progress
**Priority**: P1
**Branch**: feat/T-2026-009-implement-cqrs-structure
**Created**: 2026-02-03

## Description
Set up the CQRS code structure following flojo patterns:
- Commands for write operations
- Queries for read operations
- Schemas for data structures
- Context modules as public APIs

## Checklist
- [x] Create Questions context with commands/queries/schemas folders
- [x] Create Voting context structure
- [x] Create Users context structure
- [x] Create Demographics context structure
- [x] Set up base command pattern (struct + execute/1)
- [x] Set up base query pattern
- [x] Create context gateway modules
- [x] Add Flojo.Commands.Error equivalent

## Code Structure
```
lib/roughly/
├── questions/
│   ├── commands/
│   │   ├── create_question.ex
│   │   └── add_response_option.ex
│   ├── queries/
│   │   ├── get_question.ex
│   │   └── search_questions.ex
│   └── schemas/
│       ├── question.ex
│       └── response_option.ex
├── voting/
│   ├── commands/
│   │   └── cast_vote.ex
│   ├── queries/
│   │   └── get_vote_counts.ex
│   └── schemas/
│       └── vote.ex
└── questions.ex  # Context gateway
```

## Dependencies
### Blocked By
- T-2026-006 (need CLAUDE.md conventions)

### Blocks
- T-2026-010 (schemas go in this structure)

## Reference
- `_reference/flojo/lib/flojo/marketplace/commands/`
- `_reference/flojo/lib/flojo/commands/error.ex`
