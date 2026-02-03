---
type: task
id: T-2026-002
story:
epic:
status: backlog
priority: p1
created: 2026-02-03
updated: 2026-02-03
---

# Task: Customize Pre-commit Hook for Elixir

## Task Details
**Task ID**: T-2026-002
**Status**: Backlog
**Priority**: P1
**Branch**: feat/T-2026-002-customize-precommit-hook-elixir
**Created**: 2026-02-03

## Description
Customize the pre-commit hook (`.claude/hooks/pre-commit.sh`) to validate Elixir-specific code quality standards instead of generic/Node.js checks.

## Checklist
- [ ] Add `mix format --check-formatted` validation
- [ ] Add `mix credo --strict` linting (if credo installed)
- [ ] Add `mix dialyzer` type checking (optional, can be slow)
- [ ] Remove Node.js-specific checks (ESLint, etc.)
- [ ] Keep universal checks (temporal language, task validation)
- [ ] Test hook with sample commits

## Technical Details
### Current checks to keep
- Temporal language in evergreen docs
- Task file validation (frontmatter, status)
- Merge conflict markers
- Debugger statement detection

### Elixir-specific checks to add
```bash
# Format check
mix format --check-formatted

# Credo linting
mix credo --strict --format oneline

# Compile warnings as errors
mix compile --warnings-as-errors
```

## Dependencies
### Blocked By
- T-2026-001 (Phoenix project must exist for mix commands)

## Notes
- Dialyzer is slow - consider making it optional or running in CI only
- Credo requires adding to mix.exs dependencies
