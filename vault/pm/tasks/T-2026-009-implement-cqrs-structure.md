---
type: task
id: T-2026-009
story:
epic:
status: backlog
priority: p1
created: 2026-02-03
updated: 2026-02-03
---

# Task: Implement CQRS Code Structure

## Task Details
**Task ID**: T-2026-009
**Status**: Backlog
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
- [ ] Create Questions context with commands/queries/schemas folders
- [ ] Create Voting context structure
- [ ] Create Users context structure
- [ ] Create Demographics context structure
- [ ] Set up base command pattern (struct + execute/1)
- [ ] Set up base query pattern
- [ ] Create context gateway modules
- [ ] Add Flojo.Commands.Error equivalent

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
