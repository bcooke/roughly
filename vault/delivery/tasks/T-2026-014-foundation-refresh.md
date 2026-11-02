---
type: task
id: T-2026-014
status: completed
created: 2026-11-02
updated: 2026-11-02
---

# Runnable application and contributor foundation

Provide a browsable Roughly preview and a coherent public repository while preserving its event-sourced domain and Git history.

## Outcome

- [x] Refresh Phoenix and integrate Vue/LiveVue with a minimal asset setup.
- [x] Provide searchable synthetic questions, topic filters, result pages, and stable links.
- [x] Supervise projectors and verify JSON event projection and duplicate delivery.
- [x] Initialize Ecto and EventStore through repeatable local setup.
- [x] Establish connected concept notes, topic maps, dated research, and decision records.
- [x] Add shared contributor guidance, small PR/issue templates, and CI checks.

## Validation

As of November 2, 2026: `mix precommit` passes 36 tests, compilation, Credo, formatting, and vault links/topic coverage. `mix assets.build` passes. A runtime check exercised command → persisted event → projector → Ecto for question creation and closure. Chrome checks covered search, question navigation, and result-link copying. GitHub CI also passed the initial foundation revision; the PR check history identifies the verified revisions.

Completion here means implementation and local validation are complete. The PR owns review and merge state; this is not a production deployment or approval to collect real responses.

## References

- [PR #11](https://github.com/bcooke/roughly/pull/11).
- [Context and findings](../_context/T-2026-014-context.md).
- [Foundation decision](../../decisions/ADR-001-foundation-refresh.md).
- [Participation investigation](../../discovery/2026-11-02-participation-design.md) and [domain flow proposal](../../discovery/validated-domain-flow.md): substantive work outside this task's scope.
