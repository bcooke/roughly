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

- ✅ **T-2026-002** - Customize pre-commit hook for Elixir
- ✅ **T-2026-001** - Set up Phoenix/Elixir project with Commanded
- ✅ **T-2025-001** - Tailor Balustrade Template for Roughly

---

## Next Up (Top 3 Priorities)

1. **T-2026-003** - Add Elixir-specific skills
2. **T-2026-004** - Expand Glossary and User Personas
3. **T-2026-005** - Improve Feature Documentation Quality

---

## Backlog

- **T-2026-004** - Expand Glossary and User Personas
- **T-2026-005** - Improve Feature Documentation Quality

---

## Open Questions / Blockers

- Data model: How to efficiently query population overlaps?
- Polling methodology: How to detect and handle bad-faith responses?
- Identity: Require verified human identities for voting?

---

## Key Decisions

- **Tech Stack**: Phoenix/Elixir with LiveView, Commanded for event sourcing, PostgreSQL
- **Design Philosophy**: Minimal, white/gray base, functional accent colors (538-inspired)
- **Logo Concept**: ≈ symbol with "APPROXIMATE.LY" / "ROUGHLY" branding
- **Values**: Free, open source, Wikipedia model (not monetized like Gallup)
- **Architecture**: Event-sourced from day one for vote auditability
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
