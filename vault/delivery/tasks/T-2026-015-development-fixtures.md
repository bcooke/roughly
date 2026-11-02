---
type: task
id: T-2026-015
status: completed
created: 2026-11-02
updated: 2026-11-02
---

# Seed a fuller application and simplify the interface

Replace the small in-memory preview with a repeatable development dataset and real projected reads. Remove development commentary and promotional slogans; add a plain, evergreen About page.

## Outcome

- [x] 204 curated questions across 17 topics, 360 development participants, and 31,467 invented responses.
- [x] Deterministic, resumable seeding through Commanded, with production execution disabled.
- [x] Named queries for persisted questions, aggregate results, topics, and related questions, plus bounded pagination.
- [x] Direct homepage and About copy, simple navigation/footer, and no sample badges or engineering panels.
- [x] Connected notes preserve the product's broader empirical ambition and open semantics/cohort questions.

## Evidence

Local checks pass 41 tests plus compilation, Credo, formatting, and vault links. The frontend build passes. Full seeding and a rerun preserved counts without duplicates; extending the catalog added only new questions/responses. Browser checks exercised question results, related-question navigation, and About.

See [context](../_context/T-2026-015-context.md), [the seed decision](../../decisions/ADR-002-development-seeds.md), and [PR #12](https://github.com/bcooke/roughly/pull/12). Completion means implementation and local validation; the PR records integration. Public participation and data-source ingestion remain outside scope.
