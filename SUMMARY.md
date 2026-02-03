# Roughly: Project Summary

**The Roughly Project** - Wikipedia for quantifiable human data

**Domain**: roughly.io

---

## Project Structure

### Core Application (To Be Built)
- Phoenix/Elixir with LiveView
- Commanded for event sourcing
- PostgreSQL database
- TDD from day one

### Meta-Framework (From Balustrade)
- Git hooks for enforcement
- Slash commands for workflows
- Vault documentation structure
- Agents and skills for Claude Code

---

## File Breakdown

### .claude/ (META-FRAMEWORK)
```
hooks/
  ├── pre-commit.sh         # Validates code, docs, PM discipline
  ├── commit-msg.sh         # Conventional commits
  ├── post-commit.sh        # Auto-updates PROJECT_STATUS.md
  ├── pre-compaction.sh     # Saves context before compression
  ├── user-prompt-submit.sh # Task creation enforcement
  └── install-hooks.sh      # Installation script

commands/
  ├── p.md                  # Plan task
  ├── s.md                  # Start task
  ├── c.md                  # Close task
  ├── ctx.md                # Update context
  ├── status.md             # Quick status check
  ├── wrap.md               # Session summary
  ├── call.md               # Invoke agent
  ├── review.md             # Address PR feedback
  └── ...                   # Additional commands

agents/
  ├── coordinator.md        # Multi-domain coordination
  ├── full-stack-dev.md     # Feature implementation
  ├── code-reviewer.md      # Code quality review
  ├── bug-hunter.md         # Debugging specialist
  ├── vault-writer.md       # Documentation writing
  ├── vault-organizer.md    # Vault maintenance
  └── _packs/               # Specialized agent packs

skills/
  ├── refactor.md           # Code refactoring patterns
  ├── test-setup.md         # Testing guidance
  ├── api-design.md         # API best practices
  └── docs.md               # Documentation writing

settings.json               # Hook configuration
```

### vault/ (DOCUMENTATION)
```
product/
  ├── Product Vision.md     # What Roughly is and why
  ├── Glossary.md           # Key terminology
  └── Design Philosophy.md  # Visual design principles

architecture/
  ├── System Architecture.md # Phoenix/Commanded architecture
  └── Data Model.md          # Questions, responses, demographics

features/
  ├── Question Search.md     # Core search functionality
  ├── Demographic Slicing.md # Population filtering
  └── Data Contribution.md   # Polling and voting system

_meta/
  ├── Vault Writing Guidelines.md
  ├── Code Conventions.md
  ├── Definition of Done.md
  ├── Avoiding Temporal Language.md
  └── ...

how-to/
  ├── PM-Hierarchy.md
  ├── Git Workflow.md
  ├── Hooks and Automation.md
  ├── Dev Container Setup.md
  └── ...

_templates/
  ├── Epic.md
  ├── Story.md
  ├── Task.md
  ├── Bug.md
  └── Context.md

pm/
  ├── epics/                # Epic tracking
  ├── stories/              # User stories
  ├── tasks/                # Task files
  │   └── T-2025-001-tailor-balustrade-for-roughly.md
  ├── bugs/                 # Bug tracking
  └── _context/             # Working notes
```

### Root Files
```
README.md                   # Project overview and vision
PROJECT_STATUS.md           # Current status (token-efficient)
CUSTOMIZATION.md            # Meta-framework customization guide
HOW-IT-WORKS.md             # Visual system walkthrough
SUMMARY.md                  # This file
.gitignore                  # Git ignores
.devcontainer/
  └── devcontainer.json     # Elixir dev environment
```

### Reference Materials
```
_reference/                 # Gitignored reference projects
  ├── Eden/                 # Reference implementation
  ├── flojo/                # Reference implementation
  └── goflojo/              # Reference implementation
```

---

## Key Features

### 1. Event-Sourced Architecture
Every vote is an immutable event. Complete audit trail for all data.

### 2. Demographic Slicing
Filter any question by demographics (gender, age, location, etc.)

### 3. Population Overlap
Cross-question analysis: "What % of coffee drinkers exercise daily?"

### 4. Search-First UX
Google-style search for questions about human data.

### 5. Free and Open
Wikipedia model - no paywalls, no premium tiers.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Web | Phoenix 1.7+ with LiveView |
| Domain | Elixir with Commanded (CQRS/ES) |
| Database | PostgreSQL |
| Search | PostgreSQL full-text (initially) |
| Styling | TBD (minimal, 538-inspired) |

---

## Design Principles

- **Minimal**: White/gray base, no visual clutter
- **Functional**: Color only for semantic meaning
- **Data-forward**: Charts and percentages are the hero
- **Trustworthy**: Clean, statistical, transparent

---

## Current Status

See `PROJECT_STATUS.md` for:
- Current focus
- Recent completions
- Next priorities
- Key decisions

---

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/status` | Quick status (~500 tokens) |
| `/p <desc>` | Plan new task |
| `/s <ID>` | Start task |
| `/c` | Close task |
| `/ctx <note>` | Update context |
| `/wrap` | Session summary |
| `/call <agent>` | Invoke specialist |

---

## Documentation

### Product
- `vault/product/Product Vision.md` - What and why
- `vault/product/Glossary.md` - Terminology
- `vault/product/Design Philosophy.md` - Visual design

### Architecture
- `vault/architecture/System Architecture.md` - Technical design
- `vault/architecture/Data Model.md` - Data structures

### Features
- `vault/features/Question Search.md` - Search functionality
- `vault/features/Demographic Slicing.md` - Filtering
- `vault/features/Data Contribution.md` - Voting system

### Process
- `vault/how-to/PM-Hierarchy.md` - Task management
- `vault/how-to/Git Workflow.md` - Commit conventions
- `HOW-IT-WORKS.md` - System walkthrough
- `CUSTOMIZATION.md` - Framework customization

---

## Get Started

```bash
# Install hooks
bash .claude/hooks/install-hooks.sh

# Check status
/status

# Start working
/s T-2025-001
```

---

## License

MIT
