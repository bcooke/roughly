# Contributing to Roughly

Start with the README setup and `PROJECT_STATUS.md`. Discuss substantial feature or methodology changes before implementation. Use a focused feature branch and describe the behavior, validation, and remaining limitations in a pull request.

## Work and pull requests

Work records in `vault/delivery/` own scope, completion criteria, status, and durable outcomes. Use a stable repository ID such as `R-001`, with GitHub issues as optional public discussion and discovery. Small fixes can use a PR alone. Reconcile useful discussion outcomes through a PR rather than leaving essential reasoning only on the hosting platform.

Use a focused branch and a draft PR while work is incomplete. Link the work record and any external issue. Before merging, review the diff, resolve material findings, and check CI. Prefer squash merges. A merged PR is not automatically a production deployment.

[Project Workflow](vault/Project%20Workflow.md) describes the working process; [DR-001](vault/decisions/DR-001-portable-project-knowledge.md) marks the portability arrangement as a proposal under maintainer review. No board, Wiki, task hierarchy, or AI tool is required.

## Engineering

Keep domain logic in pure aggregates and explicit commands. Query read models through named query modules and a public context entry point. Place each Elixir module in its own file. New behavior should begin with a failing test; exercise observable outcomes and use stable DOM IDs in LiveView tests.

Run `mix precommit` (including the vault graph check) and `mix assets.build`. Include changes to both lockfiles when dependencies change. Frontend clients for Phoenix and LiveVue are resolved from the locked Hex packages, so the server and browser implementations stay aligned. Vite aliases avoid installing those libraries' development toolchains as application dependencies.

## Public documentation

The [vault index](vault/README.md) leads through topic maps to atomic evergreen notes. [Documentation Guidelines](vault/_meta/Documentation%20Guidelines.md) defines search-before-create, rich links, dated investigation, decision records, and the difference between provisional evidence and durable guidance. Use relative Markdown links so contributors can navigate on GitHub or in Obsidian.

Keep raw personal notes, private company context, credentials, and unreviewed source material outside the repository. Shared explanations must be understandable without access to a maintainer's private workspace.

## Tool independence

AGENTS.md is the shared instruction source; CLAUDE.md imports it. Contributors may use Codex, Claude, other tools, or no assistant. Repeatable project-specific workflows may use the standard `.agents/skills/<name>/SKILL.md` layout when needed. The project does not require generic command aliases, task hooks, or a particular agent orchestration system.

## Data and dependencies

Never publish individual responses or imply that a convenience sample represents a population. Synthetic examples must be labeled at the point of use. Review dependencies for license, maintenance, necessity, and transitive cost; prefer platform capabilities and small components.
