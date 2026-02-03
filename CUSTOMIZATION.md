# Customizing the Meta-Framework

This project uses a meta-framework for Claude Code development, originally from "Balustrade". This guide explains how to customize it for your needs.

---

## Quick Reference

The meta-framework provides:
- **Hooks**: Git hooks that enforce standards (`.claude/hooks/`)
- **Commands**: Slash commands for task management (`.claude/commands/`)
- **Vault**: Organized documentation structure (`vault/`)
- **Agents**: Specialized AI agents (`.claude/agents/`)
- **Skills**: Reusable expertise modules (`.claude/skills/`)

---

## Customizing Hooks

### Edit Pre-commit Checks

Edit `.claude/hooks/pre-commit.sh`:

**Don't care about temporal language?** Comment out:
```bash
# check_temporal_language "$FILE"
```

**Different task structure?** Modify:
```bash
validate_task_frontmatter() {
    # Add your required fields
    if ! grep -q '^your_field:' "$file"; then
        echo "❌ Missing your_field"
        exit 1
    fi
}
```

### Add Your Conventions

See `vault/how-to/Adding Your Conventions.md` for examples:
- API naming standards
- Error handling patterns
- Test requirements
- Database migration safety

Add checks to `pre-commit.sh`:
```bash
check_my_convention() {
    # Your validation logic
}

# Then add to checks section
check_my_convention "$FILE"
```

### Block vs Warn

**Block (fails commit)**:
```bash
exit 1
```

**Warn (shows message but allows)**:
```bash
# Don't exit, just echo warning
```

---

## Adding Agents

Create new agents in `.claude/agents/`:

### Example: Elixir Developer Agent

Create `.claude/agents/elixir-dev.md`:

```markdown
# Elixir Developer

You are an Elixir/Phoenix development specialist.

## Responsibilities

- Phoenix LiveView implementation
- Commanded event sourcing patterns
- Ecto schema and query design
- ExUnit testing

## Guidelines

- Follow OTP principles
- Use pattern matching over conditionals
- Leverage the pipe operator for clarity
- Write property-based tests for complex logic

## Tech Stack

- Elixir 1.15+
- Phoenix 1.7+ with LiveView
- Commanded for CQRS/ES
- PostgreSQL via Ecto
```

---

## Adding Skills

Create new skills in `.claude/skills/`:

### Example: Event Sourcing Skill

Create `.claude/skills/event-sourcing.md`:

```markdown
# Event Sourcing Skill

Best practices for Commanded and CQRS patterns.

## Aggregates

- One aggregate per bounded context
- Keep aggregates small and focused
- Validate commands before emitting events

## Events

- Events are immutable facts
- Name events in past tense (UserRegistered, VoteCast)
- Include all data needed for projections

## Projections

- Build read models from events
- Can be rebuilt from event stream
- Optimize for query patterns
```

---

## Modifying Commands

Edit commands in `.claude/commands/`:

### Change Task ID Format

Edit `.claude/commands/p.md` to change from `T-YYYY-NNN` to your format.

### Add New Commands

Create `.claude/commands/deploy.md`:
```markdown
# Deploy

Deploy the application to production.

## Steps

1. Run tests
2. Build production bundle
3. Deploy to hosting
4. Verify deployment
5. Update PROJECT_STATUS.md
```

Then use `/deploy` in Claude Code.

---

## Updating Dev Container

Edit `.devcontainer/devcontainer.json`:

Currently configured for Elixir:
```json
{
  "name": "roughly",
  "features": {
    "ghcr.io/devcontainers/features/elixir:1": {}
  },
  "forwardPorts": [4000],
  "postCreateCommand": "mix local.hex --force && mix local.rebar --force"
}
```

---

## Vault Structure

### Evergreen Docs (no temporal language)

- `vault/product/` - Product vision, design philosophy
- `vault/architecture/` - System design, data model
- `vault/features/` - Feature specifications

### PM Docs (temporal language OK)

- `vault/pm/tasks/` - Task tracking
- `vault/pm/epics/` - Epic planning
- `vault/pm/_context/` - Working notes

### Meta Docs

- `vault/_meta/` - Writing guidelines
- `vault/how-to/` - Process documentation
- `vault/_templates/` - PM templates

---

## Verification

After customization:

```bash
# 1. Hooks installed?
ls -l .git/hooks/ | grep '.claude'

# 2. Hooks executable?
ls -l .claude/hooks/*.sh

# 3. Test pre-commit
git add .
git commit -m "test: verify hooks"
# Should validate

# 4. Test slash commands
# In Claude Code:
/status
# Should read PROJECT_STATUS.md

# 5. Test task lifecycle
/p Test task creation
/s T-2026-XXX
/c
```

---

## Documentation

- `HOW-IT-WORKS.md` - Visual walkthrough of the system
- `SUMMARY.md` - Complete file manifest
- `vault/how-to/` - Process documentation
