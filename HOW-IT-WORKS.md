# How The Meta-Framework Works

A visual walkthrough of how hooks, commands, and vault work together.

---

## The Big Picture

```
┌─────────────────────────────────────────────────────────────┐
│                      ROUGHLY PROJECT                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Phoenix / Elixir / Commanded               │ │
│  │                   (your application)                    │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ Meta-framework manages this ▼
┌─────────────────────────────────────────────────────────────┐
│                    META-FRAMEWORK LAYER                      │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    HOOKS     │  │   COMMANDS   │  │    VAULT     │      │
│  │  (Enforce)   │  │   (Guide)    │  │  (Document)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         ▲                 ▲                  ▲              │
│         └─────────────────┴──────────────────┘              │
│                    All work together                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Problem It Solves

### Without Meta-Framework

```
User: "What's the status?"
Claude: *reads 10 files, scans git*
        [5000 tokens used]
        "You're working on search..."

User: "Create a commit"
Claude: *creates commit with random format*
        (no validation, inconsistent messages)

User: "What conventions should I follow?"
Claude: *might remember, might forget*
        (no enforcement)
```

### With Meta-Framework

```
User: /status
Claude: *reads PROJECT_STATUS.md only*
        [500 tokens used]
        "Working on T-2025-001 (template setup)"

User: git commit
Hook: *validates automatically*
      "❌ Invalid commit format"
      (blocks bad commits)

User: Adds temporal language to docs
Hook: *validates automatically*
      "❌ No 'will' in evergreen docs"
      (enforces conventions)
```

**Result**: 10x token reduction, consistent workflows, automatic enforcement.

---

## Core Components

### 1. Hooks (Enforcement)

**What**: Shell scripts that run automatically at git events

**When**: Before commits, after commits, before compaction

**Why**: Enforce standards without relying on memory

```
You attempt commit
        ▼
   pre-commit.sh runs
        ▼
   ┌─ Validates code quality
   ├─ Checks doc standards
   ├─ Validates task structure
   └─ Enforces YOUR conventions
        ▼
   ✅ Pass → commit proceeds
   ❌ Fail → commit blocked
```

**Hooks Included**:
- `pre-commit.sh` - Validates before commit
- `commit-msg.sh` - Validates commit message format
- `post-commit.sh` - Auto-updates PROJECT_STATUS.md
- `pre-compaction.sh` - Saves context before Claude's memory compression

### 2. Commands (Guided Workflows)

**What**: Slash commands that guide consistent task management

**When**: You invoke them in Claude Code (`/p`, `/s`, `/c`, etc.)

**Why**: Ensure every task follows same lifecycle

```
/p "Implement search API"
        ▼
   Creates task file
   Creates context doc
   Updates PROJECT_STATUS.md
   Commits everything
        ▼
   Task T-2026-001 ready!

/s T-2026-001
        ▼
   Creates branch feat/T-2026-001-implement-search-api
   Updates task status → in-progress
   Updates PROJECT_STATUS.md "Current Focus"
   Commits changes
        ▼
   Ready to work!

/c
        ▼
   Reviews completion
   Updates task status → completed
   Updates PROJECT_STATUS.md
   Offers to create PR
        ▼
   Task done!
```

**Commands Included**:
- `/p <description>` - Plan new task
- `/s <TASK-ID>` - Start task
- `/c` - Close task
- `/ctx <note>` - Update context
- `/status` - Quick status check (~500 tokens)
- `/wrap` - End-of-session summary

### 3. Vault (Documentation)

**What**: Organized markdown files for product/architecture/PM

**When**: You document your product, not your code

**Why**: Knowledge graph of your project

```
vault/
├── product/           # Product vision (evergreen)
│   ├── Product Vision.md
│   ├── Glossary.md
│   └── Design Philosophy.md
├── architecture/      # System design (evergreen)
│   ├── System Architecture.md
│   └── Data Model.md
├── features/          # Feature specs (evergreen)
│   ├── Question Search.md
│   ├── Demographic Slicing.md
│   └── Data Contribution.md
└── pm/                # Project management (temporal OK)
    ├── tasks/
    ├── epics/
    └── _context/
```

**Evergreen docs** (product/, architecture/, features/):
- Timeless - describe current state
- No temporal language ("will", "soon", "recently")
- Hooks can enforce this automatically

**PM docs** (pm/):
- Track progress and status
- Temporal language OK here
- Link to evergreen docs

### 4. PROJECT_STATUS.md (Token Efficiency)

**What**: Single file with complete project state

**When**: Read this FIRST before asking "what's the status?"

**Why**: ~500 tokens vs 5000+ for scanning vault

```
PROJECT_STATUS.md contains:
├── Current Focus (what task, what goal)
├── Recently Completed (last 3)
├── Next Up (top 3 priorities)
├── Open Questions / Blockers
├── Key Decisions (architectural)
└── Files Recently Modified (auto-updated)
```

---

## How They Work Together

### Example: Starting New Work

```
1. You: /p Implement demographic slicing

2. /p command:
   ├─ Creates vault/pm/tasks/T-2026-002-implement-demographic-slicing.md
   ├─ Creates vault/pm/_context/T-2026-002-context.md
   ├─ Updates PROJECT_STATUS.md "Next Up"
   └─ Commits all files

3. You: /s T-2026-002

4. /s command:
   ├─ Creates branch feat/T-2026-002-implement-demographic-slicing
   ├─ Updates task status → in-progress
   ├─ Updates PROJECT_STATUS.md "Current Focus"
   └─ Commits changes

5. You: *make code changes*

6. You: git commit -m "feat: add demographic projector"

7. pre-commit hook runs:
   ├─ Checks for debugger statements ✅
   ├─ Checks for merge conflicts ✅
   ├─ Validates task structure ✅
   └─ Checks YOUR conventions ✅

8. commit-msg hook runs:
   └─ Validates "feat: add demographic projector" format ✅

9. post-commit hook runs:
   └─ Updates PROJECT_STATUS.md timestamp ✅

10. You: /ctx Decided to use composite keys for demographic slices

11. /ctx command:
    ├─ Appends to vault/pm/_context/T-2026-002-context.md
    └─ Commits

12. You: /c

13. /c command:
    ├─ Reviews task checklist
    ├─ Updates task status → completed
    ├─ Moves to PROJECT_STATUS.md "Recently Completed"
    └─ Offers to create PR

All automated. All consistent. Every time.
```

---

## Task Lifecycle (Visual)

```
┌──────────────────────────────────────────────────────┐
│                   TASK LIFECYCLE                      │
└──────────────────────────────────────────────────────┘

   /p                    /s                    /c
    │                     │                     │
    ▼                     ▼                     ▼
[BACKLOG] ───────▶ [IN-PROGRESS] ───────▶ [COMPLETED]
    │                     │                     │
    │                     │                     │
Creates:             Creates:             Creates:
- Task file          - Branch            - PR (optional)
- Context doc        - Updates status    - Final status
- Status entry       - Updates focus     - Move to history
```

---

## Token Usage Flow

```
WITHOUT META-FRAMEWORK:
User asks "status" → Claude scans vault → 10+ files → 5000 tokens
                                             ↓
                                        ❌ Expensive


WITH META-FRAMEWORK:
User asks "/status" → Claude reads PROJECT_STATUS.md → 1 file → 500 tokens
                                                          ↓
                                                     ✅ Efficient
```

---

## Hook Enforcement Flow

```
Code Change
    ▼
git add
    ▼
git commit ────────────┐
    ▼                  │
pre-commit hook runs   │  Validates:
    ├─ Code quality    │  - No debuggers
    ├─ Doc standards   │  - No temporal language
    ├─ Task structure  │  - Valid task status
    └─ Your rules ─────┘  - YOUR conventions
    ▼
✅ Pass → commit-msg hook
    ▼
✅ Pass → commit created
    ▼
post-commit hook runs
    └─ Updates PROJECT_STATUS.md
```

---

## Key Design Principles

### 1. Determinism Over Flexibility

Hooks enforce automatically. Same result every time.

**Why**: No relying on Claude (or you) to remember conventions.

### 2. Token Efficiency First

Every design minimizes token usage:
- PROJECT_STATUS.md (single source of truth)
- Slash commands (structured updates)
- Hooks (no validation overhead)

**Result**: ~10x reduction in common operations.

### 3. Convention Over Configuration

Standard structure, predictable workflows, automated maintenance.

**Like Rails**: Opinionated defaults you can change.

---

## FAQ

### "How do hooks run automatically?"

Git calls them at specific events:
- `pre-commit` → before commit is created
- `commit-msg` → after message is written
- `post-commit` → after commit succeeds

You install once: `bash .claude/hooks/install-hooks.sh`

Then they run automatically forever.

### "How does /status know what to read?"

The `/status` command tells Claude:
> "Read PROJECT_STATUS.md ONLY. Do not scan vault."

Claude follows instructions → reads 1 file → fast response.

### "How does PROJECT_STATUS.md stay current?"

Three ways:
1. **Slash commands** update it (/p, /s, /c)
2. **post-commit hook** updates timestamp/files
3. **You** can edit manually if needed

### "What if I don't want temporal language checks?"

Edit `.claude/hooks/pre-commit.sh`:

```bash
# Comment out the check:
# check_temporal_language "$FILE"
```

### "Can I add my own slash commands?"

Yes! Create `.claude/commands/your-command.md` and use `/your-command` in Claude Code.

---

## Related Documentation

- `CUSTOMIZATION.md` - How to customize the framework
- `SUMMARY.md` - Complete file inventory
- `vault/how-to/` - Process documentation
