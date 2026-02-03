# Context: T-2026-006 Set Up CLAUDE.md and AGENTS.md

**Task**: [[T-2026-006-setup-claude-agents-md]]
**Created**: 2026-02-03
**Status**: In Progress

## Progress Update (2026-02-03)

### Completed
- Created CLAUDE.md as redirect to AGENTS.md
- Created comprehensive AGENTS.md with:
  - Project overview and values
  - Privacy model documentation ("Anonymous but Accountable")
  - Git workflow and Balustrade PM conventions
  - Development commands (setup, testing, quality)
  - Architecture overview with CQRS patterns
  - Elixir, Ecto, Phoenix, LiveView guidelines
  - Agent and skills documentation
  - Testing guidelines (TDD emphasis)
- Updated Product Vision with privacy model details
- Updated System Architecture with correct privacy language

### Decisions Made
- CLAUDE.md is minimal redirect (following flojo pattern)
- AGENTS.md is comprehensive guide
- Emphasized privacy model as core architectural principle
- Included Balustrade PM workflow as standard

## Overview

Create the foundational AI assistant guidance documents for Roughly. These files ensure consistent behavior across all AI interactions with the codebase.

## Key Decisions

- Follow flojo's pattern: CLAUDE.md as redirect, AGENTS.md as primary guide
- Heavily customize for Roughly's domain (polling, demographics, question relationships)
- Emphasize event-sourcing and TDD from day one
- Document Balustrade PM conventions as project standard

## Reference Materials

### From flojo
- CQRS structure: `/lib/flojo/{context}/commands/`, `/lib/flojo/{context}/queries/`, `/lib/flojo/{context}/schemas/`
- Agent organization pattern
- Development commands format

### From Roughly vault
- `vault/product/Product Vision.md` - Core vision
- `vault/product/Glossary.md` - Domain terms
- `vault/architecture/System Architecture.md` - Phoenix/Commanded setup
- `vault/architecture/Data Model.md` - Question/Response model

### From Balustrade
- PM workflow (tasks, branches, PRs)
- Vault structure and conventions
- Pre-commit hooks

## Roughly-Specific Content to Include

### Domain Concepts
- Questions (with answer options, types)
- Responses/Votes (immutable events)
- Demographics (slicing, snapshots)
- Population overlaps (cross-question analysis)
- Question relationships (graph/taxonomy - future)

### Conventions
- No Claude Code branding in commits/PRs
- TDD required (write tests first)
- Event-sourcing pattern for all domain changes
- CQRS code structure following flojo patterns

## Implementation Plan

1. Create CLAUDE.md as redirect to AGENTS.md
2. Create comprehensive AGENTS.md with:
   - Project overview section
   - Critical workflow rules
   - Development commands
   - Architecture overview
   - CQRS code patterns
   - Domain concepts
   - Agent/Skills documentation

## Open Questions

- Should we have separate CLAUDE.md content or just redirect?
- How detailed should CQRS patterns be in AGENTS.md vs skills?

## Next Steps

1. Run `/s T-2026-006` to start work
2. Read flojo AGENTS.md fully for structure inspiration
3. Write CLAUDE.md and AGENTS.md
4. Commit and create PR
