# Project Status

**Last Updated**: 2025-02-02
**Project**: The Roughly Project (roughly.io)

---

## Current Focus

**Active Task**: T-2025-001 - Tailor Balustrade Template for Roughly
**Branch**: main (pending branch creation)
**Goal**: Transform meta-framework template into Roughly foundation

**Progress**: Nearly complete - all documentation created, ready for commit

---

## Recently Completed (Last 3)

- (none yet - project just initialized)

---

## Next Up (Top 3 Priorities)

1. **T-2025-001** - ✅ Complete (pending commit)
2. **T-2026-001** - Set up Phoenix/Elixir project with Commanded
3. Define and implement core data model (Questions, Responses, Demographics)

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
- **Framework Docs**: Keep CUSTOMIZATION.md, HOW-IT-WORKS.md, SUMMARY.md as internal meta-framework reference

---

## Files Recently Modified

<!-- Auto-updated by post-commit hook -->
- README.md
- PROJECT_STATUS.md
- .devcontainer/devcontainer.json
- vault/product/Product Vision.md
- vault/product/Glossary.md
- vault/product/Design Philosophy.md
- vault/architecture/System Architecture.md
- vault/architecture/Data Model.md
- vault/features/Question Search.md
- vault/features/Demographic Slicing.md
- vault/features/Data Contribution.md
- CUSTOMIZATION.md
- HOW-IT-WORKS.md
- SUMMARY.md

---

## Task Breakdown (Active Task)

**T-2025-001**: Tailor Balustrade for Roughly
- [x] Delete example-app and Todo App PM artifacts
- [x] Update PROJECT_STATUS.md
- [x] Rewrite README.md
- [x] Create Product Vision documentation
- [x] Create Architecture documentation
- [x] Create Feature documentation
- [x] Update framework docs (CUSTOMIZATION, HOW-IT-WORKS, SUMMARY)
- [x] Update .claude/ configuration
- [x] Create next task (T-2026-001 Phoenix setup)
- [ ] Final commit

---

## Notes

- This file is the **single source of truth** for project status
- Kept in sync with `vault/pm/` via hooks and slash commands
- Read this file first before asking "what's the status?"
- Token-efficient: ~500 tokens vs 5000+ for scanning vault
- Auto-updated by hooks and commands
