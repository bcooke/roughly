---
type: work
id: R-001
status: in-review
created: 2026-11-02
updated: 2026-11-02
---

# Application foundation and contribution process

## Outcome

Provide a runnable, clearly synthetic browsing preview and an understandable public repository, preserving the event-sourced domain and Git history.

## Acceptance criteria

- Fresh Phoenix/LiveVue configuration with reproducible Ecto, EventStore, and asset setup.
- Browse, search, topic filters, readable question results, and stable links with synthetic-data labeling.
- Supervised projectors and regression coverage for serialized event projection.
- Shared contributor instructions, CI, connected evergreen notes, dated research, and explicit decision records.
- A lightweight, portable work/review process documented as a proposal for maintainer review.

## Evidence as of November 2, 2026

`mix precommit` passed 36 tests, compilation, Credo, formatting, and the vault graph check. `mix assets.build` passed. Chrome checks exercised search, question navigation, and Vue link copying. A runtime check dispatched create/close commands through EventStore and the supervised question projector into Ecto. The vault check validated active links and topic-map coverage for 13 concept notes. Hosted CI evidence belongs in the PR.

This preview does not collect responses. The event-sourced domain flow remains [R-003](R-003-domain-flow.md); participation methodology remains [R-002](R-002-participation-methodology.md).

## References

- [Public discussion](https://github.com/bcooke/roughly/issues/8)
- [Foundation ADR](../decisions/ADR-001-foundation-refresh.md)
- [Workflow proposal](../decisions/DR-001-portable-project-knowledge.md)
