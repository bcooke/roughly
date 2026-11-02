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

## Product direction

- Use the preview to refine question presentation, navigation, and visual direction.
- [Participation investigation](vault/discovery/2026-11-02-participation-design.md): results exposure, identity, honesty, sampling, and privacy remain open.
- [Validated domain flow proposal](vault/discovery/validated-domain-flow.md): connect domain commands and projected reads to the application before real collection.

The [vault index](vault/README.md) leads to connected product/methodology and engineering notes. [Project Workflow](vault/Project%20Workflow.md) uses focused PRs and relevant checks with small T/BUG/IMP records for meaningful work and optional context files. [Foundation task](vault/delivery/tasks/T-2026-014-foundation-refresh.md) links the scope and context; [PR #11](https://github.com/bcooke/roughly/pull/11) contains the implementation and validation history.

## Open boundaries

The retained aggregates are not a complete or hardened voting backend. Public authentication, answer collection, demographic slices, representative estimates, and production deployment are not implemented. Nonprofit governance is an intention to explore, not an established organization.

Historical design proposals under `vault/archive/` describe possible future behavior. Current runtime behavior and this status take precedence over those sketches.
