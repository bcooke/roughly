---
type: task
id: T-2026-007
story:
epic:
status: completed
priority: p1
created: 2026-02-03
updated: 2026-02-03
---

# Task: Design Question Relationship Graph Model

## Task Details
**Task ID**: T-2026-007
**Status**: Completed
**Priority**: P1
**Branch**: feat/T-2026-007-design-question-graph-model
**PR**: https://github.com/bcooke/roughly/pull/6
**Created**: 2026-02-03
**Completed**: 2026-02-03

## Description
Design a robust data model for question relationships, including:
- Same question (semantic equivalence)
- Related questions (topical relationship)
- Sub-questions (hierarchical)
- Question taxonomy and categorization
- Relationship scoring/strength

## Checklist
- [x] Research graph database patterns (can use PostgreSQL with extensions)
- [x] Design relationship types and their semantics
- [x] Design scoring/strength model for relationships
- [x] Document in vault/architecture/Question Relationships.md
- [x] Define Ecto schemas for relationships
- [x] Consider how to detect/suggest relationships

## Key Concepts to Model
- **Equivalence**: "Is X the same question as Y?" (e.g., different wordings)
- **Relatedness**: "Is X related to Y?" (scored, 0-1)
- **Hierarchy**: "Is X a sub-question of Y?"
- **Taxonomy**: Categories, tags, topics
- **Facts**: How questions relate to factoids/statistics

## Dependencies
### Blocked By
- T-2026-006 (need CLAUDE.md conventions first)

### Blocks
- T-2026-010 (Ecto schemas need this design)

## Notes
- Consider using ltree or pg_trgm for hierarchy/similarity
- Look at how Stack Overflow handles related questions
- Consider ML for relationship detection in future
