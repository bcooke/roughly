---
type: note
---

# Project Workflow

Use focused pull requests to explain and integrate changes. The repository contains the knowledge needed to understand the project; the hosting platform provides review, discussion, and automated checks. [The process decision](decisions/DR-001-portable-project-knowledge.md) records this deliberately small arrangement.

## Make a change

1. Search the code and related notes, then work on a focused branch.
2. Implement and validate the behavior. Run `mix precommit` and `mix assets.build` for application changes.
3. Open a ready PR with a short explanation, relevant evidence, and material limitations. Drafts are useful only when work actually needs to remain unfinished.
4. Inspect the diff and check results, address real problems, then squash merge. Early development does not require a separate formal review ceremony.

For a meaningful chunk of work, use a small repo-local record with a familiar `T-YYYY-NNN`, `BUG-YYYY-NNN`, or `IMP-YYYY-NNN` ID. State the problem, outcome, evidence, and associated PR. Add a context file only when there are findings or reasoning worth preserving. [The foundation task](delivery/tasks/T-2026-014-foundation-refresh.md) and [its context](delivery/_context/T-2026-014-context.md) are an example.

Do not backfill every small edit or make paperwork a prerequisite for coding. An issue, epic hierarchy, project board, or mirrored tracker is not required. Use an issue when public discussion helps. A task's completion records implementation and validation; the PR owns review/merge state, and deployment is a separate observation. Add stronger controls as contribution and operational needs justify them.

## Preserve useful knowledge

Update an existing atomic note when understanding changes. Use topic maps for navigation, dated research for provisional findings, and a decision record for a consequential choice. [Documentation Guidelines](_meta/Documentation%20Guidelines.md) defines those forms; documentation should explain the project rather than narrate every coding session.

[Project Status](../PROJECT_STATUS.md) is a dated orientation, not a task database. Essential decisions, contracts, and research findings belong in committed Markdown rather than exclusively in issue comments or a separate Wiki. Link to public discussions when useful, and bring their durable conclusions back into the repository.

## Portability

Code and documents move with Git. Hosting-specific discussions, attachments, checks, and settings need deliberate export if their history matters during a migration; a URL alone is not a backup. Avoid building synchronization machinery without a concrete need.

[System Architecture](System%20Architecture.md) explains engineering boundaries. [Public and Private Knowledge](Public%20and%20Private%20Knowledge.md) defines which information belongs in a public contribution.
