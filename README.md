# Roughly

> **Wikipedia for quantifiable human data**

Roughly is an open-source encyclopedia of polling data about human preferences, behaviors, and attitudes. Search questions like "Do you like the taste of coffee?" and see results sliced by demographics.

**Domain**: [roughly.io](https://roughly.io)

---

## Vision

Imagine if you could poll every person on Earth and they'd tell the truth. You could answer:
- "What percentage of people prefer chocolate to vanilla?"
- "How many people brush their teeth every night?"
- "What percentage of New Englanders are Patriots fans?"

And you could **slice it any way** - by gender, age, geography, religion, or any combination.

Roughly is the best approximation of that impossible ideal: a free, open, searchable database of what humanity thinks, feels, and does.

---

## Core Concepts

### Questions & Responses
Every poll is a **Question** with defined **Response** options. Questions can be yes/no, multiple choice, or scaled.

### Demographics & Populations
**Demographics** define who someone is (age, gender, location, etc.). A **Population** is any group defined by demographic criteria.

### Slicing
The magic: combine any two questions to create insights. "What percentage of *men who drink coffee* also *exercise daily*?" requires two questions and filters by demographics.

### The ≈ Symbol
Our logo uses the "approximately equal" symbol (≈) because all polling data is an approximation. We're transparent about methodology and confidence levels.

---

## Design Philosophy

- **Minimal**: White and gray base, no visual clutter
- **Functional**: Accent colors only for semantic meaning (error, warning, success, interactive)
- **Data-forward**: Charts and percentages are the hero, not chrome
- **538-inspired**: Clean, statistical, trustworthy aesthetic

---

## Tech Stack

- **Phoenix/Elixir** with LiveView for real-time interactivity
- **Commanded** for event sourcing (every vote is an auditable event)
- **PostgreSQL** for persistent storage
- **TDD** from day one

---

## Values

| Value | What It Means |
|-------|---------------|
| **Free** | No paywalls, no premium tiers, no selling data |
| **Open** | Open source code, transparent methodology |
| **Wikipedia model** | Community-driven, potentially non-profit, donation-supported |
| **Scientific rigor** | Take polling methodology seriously, acknowledge limitations |
| **Not Gallup** | Gallup monetizes polling; we democratize it |
| **Not Quora** | Quora raised VC and enshittified; we won't |

---

## Project Structure

```
roughly/
├── .claude/                    # Claude Code meta-framework
│   ├── hooks/                  # Git hooks for enforcement
│   ├── commands/               # Slash commands for workflows
│   ├── agents/                 # Agent templates
│   └── skills/                 # Reusable expertise
├── vault/                      # Documentation (Obsidian-compatible)
│   ├── product/                # Product vision, glossary, design
│   ├── architecture/           # System design, data model
│   ├── features/               # Feature specifications
│   ├── _meta/                  # Writing guidelines
│   ├── how-to/                 # Process docs
│   └── pm/                     # Project management
├── _reference/                 # Reference materials (gitignored)
├── .devcontainer/              # Dev container (Elixir configured)
├── PROJECT_STATUS.md           # Current project state
└── README.md                   # This file
```

---

## Getting Started

### Prerequisites
- Elixir 1.15+ and Erlang/OTP 26+
- PostgreSQL 15+
- Node.js 18+ (for asset compilation)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/roughly/roughly.git
cd roughly

# Install git hooks
bash .claude/hooks/install-hooks.sh

# (Phoenix project setup - coming soon)
# mix setup
# mix phx.server
```

---

## Contributing

Roughly is open source and welcomes contributions.

1. Check `PROJECT_STATUS.md` for current priorities
2. Read `vault/how-to/Git Workflow.md` for commit conventions
3. Use `/p` command in Claude Code to plan new work
4. Submit PRs against `main`

---

## History

Roughly is a resurrection of **Quibble** (K-W-I-B-B-L), a project originally built on WordPress. The core idea has remained constant: create a canonical, searchable record of quantifiable human data, free and open to all.

---

## License

MIT - Use freely, modify as needed.

---

## Links

- **Website**: [roughly.io](https://roughly.io)
- **Repository**: [github.com/roughly/roughly](https://github.com/roughly/roughly)
- **Status**: See `PROJECT_STATUS.md`
