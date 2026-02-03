---
type: task
id: T-2025-001
story:
epic:
status: completed
priority: p0
created: 2025-02-02
updated: 2026-02-03
---

# Task: Tailor Balustrade Template for Roughly

## Task Details
**Task ID**: T-2025-001
**Story**: -
**Epic**: -
**Status**: Completed
**Priority**: P0 (Foundation)
**Branch**: main (direct commits - pre-branch-protection)
**Created**: 2025-02-02
**Started**: 2025-02-02
**Completed**: 2026-02-03

## Description
Transform the Balustrade template into the foundation for "The Roughly Project" - a Wikipedia-like encyclopedia of world percentages and polling data. This involves updating all project references, establishing the project vision documentation, and preparing the codebase for Phoenix/Elixir development.

**Project Vision**: Roughly (roughly.io) is a resurrection of "Quibble" - a site to catalog quantifiable human data (preferences, behaviors, attitudes) in a free, open, Wikipedia-like manner. Think: "What percentage of people prefer chocolate to vanilla?" sliceable by any demographic.

## Checklist
- [x] Delete example-app folder
- [x] Delete Todo App PM artifacts (epic, stories, tasks, bug, contexts)
- [x] Update README.md with Roughly project description
- [x] Update PROJECT_STATUS.md with project details
- [x] Update .devcontainer for Elixir
- [x] Create Product Vision documentation (vault/product/)
- [x] Create Glossary documentation
- [x] Create Design Philosophy documentation
- [x] Create System Architecture documentation (vault/architecture/)
- [x] Create Data Model documentation
- [x] Create Feature documentation (vault/features/)
- [x] Update CUSTOMIZATION.md, HOW-IT-WORKS.md, SUMMARY.md
- [x] Update .gitignore for Elixir
- [x] Update .claude/aliases.sh
- [x] Create next task (T-2026-001 Phoenix setup)
- [x] Create context document
- [x] Final commit
- [x] Install git hooks
- [x] Create Roughly-specific agents (full-stack-dev, product-manager, user-tester)

## Technical Details
### Approach
- Systematic rebranding of Balustrade → Roughly where appropriate
- Keep meta-framework documentation for internal reference
- Create comprehensive Roughly-specific product/architecture/feature docs
- Defer Phoenix setup to separate task (T-2026-001)

### Files Created
- `vault/product/Product Vision.md`
- `vault/product/Glossary.md`
- `vault/product/Design Philosophy.md`
- `vault/architecture/Data Model.md`
- `vault/features/Question Search.md`
- `vault/features/Demographic Slicing.md`
- `vault/features/Data Contribution.md`
- `vault/pm/tasks/T-2026-001-setup-phoenix-project.md`
- `vault/pm/_context/T-2025-001-context.md`

### Files Modified
- `README.md` - Complete rewrite
- `PROJECT_STATUS.md` - Roughly project details
- `.devcontainer/devcontainer.json` - Elixir configuration
- `CUSTOMIZATION.md` - Rebranded
- `HOW-IT-WORKS.md` - Rebranded
- `SUMMARY.md` - Updated manifest
- `.gitignore` - Added Elixir ignores
- `.claude/aliases.sh` - Rebranded
- `vault/architecture/System Architecture.md` - Complete rewrite

### Files Deleted
- `example-app/` (entire directory)
- `vault/pm/epics/E-2025-001-todo-app-mvp.md`
- `vault/pm/stories/US-2025-001-setup-api.md`
- `vault/pm/stories/US-2025-002-build-frontend.md`
- `vault/pm/tasks/T-2025-001-setup-todo-api.md`
- `vault/pm/tasks/T-2025-002-create-html-interface.md`
- `vault/pm/bugs/B-2025-001-fix-cors-error.md`
- `vault/pm/_context/E-2025-001-context.md`
- `vault/pm/_context/T-2025-001-context.md` (old example)
- `vault/features/Todo Management.md`

## Dependencies
### Blocked By
- None (foundation task)

### Blocks
- T-2026-001 (Phoenix setup)
- All future Roughly development

## Context
See [[T-2025-001-context]] for detailed implementation notes and project background.

## Commits
- `feat: transform Balustrade template into Roughly project foundation`
- `feat(agents): add Roughly-specific agents`

## Review Checklist
- [x] Project vision clearly documented
- [x] README accurately describes Roughly
- [x] Architecture documented for Phoenix/Commanded
- [x] Data model documented
- [x] Features documented
- [x] Committed to git
- [x] Pushed to GitHub

## Notes
- Key tech stack: Phoenix, Elixir, LiveView, Commanded (event sourcing)
- Design: Minimal, white/gray, functional accents (538-inspired)
- Logo concept: ≈ symbol with "ROUGHLY" / "APPROXIMATE.LY"
- Values: Free, open source, Wikipedia-like, scientific polling approach
- User provided original mockup and logo concept for reference
