# Project Status

Updated November 2, 2026.

## Current milestone

A local browsing preview on a fresh Phoenix 1.8.16 foundation. Vue 3 and LiveVue 1.2.3 are integrated through Vite. Existing domain code and Git history are preserved.

## Available

- Searchable synthetic questions, topic filters, shareable search URLs, and an empty state.
- Stable question pages, horizontal answer breakdowns, response counts, and results/methodology anchors.
- Clear synthetic-data labeling. No real responses are collected.
- A small LiveVue interaction for copying result links; no prediction exercise.
- Questions, voting, and users aggregates, separate command/event modules, Ecto projections, migrations, and supervised projectors.
- Regression coverage for JSON event projection, close transitions, and duplicate event delivery.
- Dedicated development PostgreSQL container, repeatable setup for Ecto and EventStore, and pinned local runtimes.
- Shared AGENTS.md instructions, a thin Claude import, contributor documentation, and an atomic, interlinked public Markdown vault.
- CI definition for backend checks and frontend build. Hosted CI will run when a branch is pushed.

## Validation

`mix precommit` and `mix assets.build` are the required local gates. A runtime smoke check dispatched create/close commands through persisted events and the supervised question projector into Ecto. The preview is also checked interactively in Chrome.

## Work and review

- [R-001](vault/delivery/R-001-foundation.md): foundation refresh and contribution process, under review.
- [R-002](vault/delivery/R-002-participation-methodology.md): participation and data-quality investigation, open.
- [R-003](vault/delivery/R-003-domain-flow.md): validated real-domain flow, open.

These repository records own detailed scope, acceptance criteria, and outcomes. GitHub issues link to them for discussion. [DR-001](vault/decisions/DR-001-portable-project-knowledge.md) proposes this portable arrangement for maintainer review; a board or Wiki is not required.

The [vault index](vault/README.md) provides topic maps for product/methodology, engineering, and contributing. Evergreen notes, dated research, decision records, and historical proposals have separate roles. The public vault contains shared project knowledge; private reflection and raw references stay outside the repository.

## Open boundaries

The retained aggregates are not a complete or hardened voting backend. Public authentication, answer collection, demographic slices, representative estimates, and production deployment are not implemented. Nonprofit governance is an intention to explore, not an established organization.

Historical design proposals under `vault/archive/` describe possible future behavior. Current runtime behavior and this status take precedence over those sketches.
