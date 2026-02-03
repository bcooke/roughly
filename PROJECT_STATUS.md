# Project Status

**Last Updated**: 2026-02-03
**Project**: The Roughly Project (roughly.io)

---

## Current Focus

**Active Task**: None - select from backlog
**Branch**: main
**Goal**: Phoenix foundation complete, ready for feature development

---

## Recently Completed (Last 3)

- ✅ **T-2026-009** - Implement CQRS code structure
- ✅ **T-2026-007** - Design question relationship graph model
- ✅ **T-2026-006** - Set up CLAUDE.md and AGENTS.md

---

## Next Up (Top 3 Priorities)

1. **T-2026-012** - Refactor to Commanded event-sourcing with TDD (CRITICAL)
2. **T-2026-011** - Create auth & user schemas (superseded by T-2026-012)
3. **T-2026-010** - Create initial Ecto schemas (superseded by T-2026-012)

---

## Backlog

### Foundation (P0 - Critical)
- **T-2026-012** - Refactor to Commanded event-sourcing with TDD

### Foundation (P1 - After T-2026-012)
- **T-2026-011** - Create auth & user schemas
- **T-2026-010** - Create initial Ecto schemas (questions/votes)

### Design & Docs (P2)
- **T-2026-008** - Create design system and Tailwind theme
- **T-2026-004** - Expand Glossary and User Personas
- **T-2026-005** - Improve Feature Documentation Quality

---

## Open Questions / Blockers

- Data model: How to efficiently query population overlaps?
- Polling methodology: How to detect and handle bad-faith responses?
- Identity: Require verified human identities for voting?
- **Privacy model**: Accounts required (no anonymous voting), but individual answers private
  - Only aggregate data visible publicly
  - Consider encrypting individual vote records
  - k-anonymity threshold for demographic slices?

---

## Key Decisions

- **Tech Stack**: Phoenix/Elixir with LiveView, Commanded for event sourcing, PostgreSQL
- **TDD Mandatory**: All code changes must follow Red → Green → Refactor. Never write implementation without failing test first
- **Event-Sourced Architecture**: Commanded aggregates for write side, Ecto projections for read side. Never query aggregates directly
- **No Demographics Context**: Demographics are just questions - no separate context needed
- **Design Philosophy**: Minimal, white/gray base, functional accent colors (538-inspired)
- **Logo Concept**: ≈ symbol with "APPROXIMATE.LY" / "ROUGHLY" branding
- **Values**: Free, open source, Wikipedia model (not monetized like Gallup)
- **Privacy**: Accounts required to vote (no anonymous), but individual responses are private (aggregate-only public data)
- **Git Workflow**: Squash and merge only, linear history, PRs required for main
- **Task Granularity**: Small, focused tasks with individual PRs

---

## Workflow Rules

- All changes to main require a PR
- Squash merge only (linear history)
- Delete branch after merge
- One task = one branch = one PR

---

## Files Recently Modified

<!-- Auto-updated by post-commit hook -->

---

## Notes

- This file is the **single source of truth** for project status
- Kept in sync with `vault/pm/` via hooks and slash commands
- Read this file first before asking "what's the status?"
