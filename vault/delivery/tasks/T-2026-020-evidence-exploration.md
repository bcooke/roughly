---
type: task
id: T-2026-020
status: completed
created: 2026-11-02
updated: 2026-11-02
---

# Historical evidence, population comparisons, and answer discovery

[PR #19](https://github.com/bcooke/roughly/pull/19) contains the implementation and review.

## Outcome

Build question pages that answer more than a current total: cumulative distributions under explicit clocks and cutoffs, receipt-order checkpoints, intersections defined by another exact question, readable focused-answer pages, and truthful crawlable content. Preserve missingness, option semantics, and withdrawals across every public view.

[Response History](../../Response%20History.md), [Population Analysis](../../Population%20Analysis.md), and [Answer Discovery](../../Answer%20Discovery.md) own the implemented contracts. No response collection, representative estimate, full research API, graph-topic implementation, or dataset release is introduced.

## Evidence

Observed failing behavior tests before the history/intersection and discovery implementation. Tests cover revisions and duplicate delivery, clock differences, withdrawals, eligible overlap and missingness, small-group suppression, bounded trend checkpoints, readable option collisions, initial HTML answers, canonical/noindex metadata, and invalid option routes. A replay test exposed string keys in per-field provenance; explicit enum decoding fixes it.

The disposable local database is rebuilt through Commanded with dated fictional responses, revisions, demographic-question instruments, and deliberately contrasting coffee scenarios. Receipt timestamps remain actual EventStore timestamps; the development fixture supplies invented answer dates rather than rewriting receipt history.

Final verification and browser findings are recorded with the PR.

Validation: `mix precommit` passes 84 backend and three frontend tests, compilation, Credo, formatting, and 25-note vault checks; `mix assets.build` passes. Native Safari checks cover date and receipt-order graphs, keyboard checkpoint inspection, population drill-downs, and a narrow window. Physical device testing remains outstanding. The seed catalog contains 209 questions across 18 topics, 360 invented principals, and 33,177 responses; a full rerun adds no records or revisions.

Discovery regressions also protect closed instruments' evidence addresses, filtered-answer scope preservation, explicit receipt timing on the response-count axis, 404s, and sitemap publication gating. The group disclosure floor is not a complete privacy policy, and live multi-query reads are not versioned research releases.
