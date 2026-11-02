---
type: task
id: T-2026-019
status: completed
created: 2026-11-02
updated: 2026-11-02
---

# Question exploration and vision coverage

[PR #18](https://github.com/bcooke/roughly/pull/18) contains the implementation and review.

## Outcome

Give question pages a clearer visual hierarchy and usable result exploration: format-appropriate distributions, percentage/count views, a semantic exact-count table, shareable view state, concise counting context, related navigation, and meaningful empty states. Add representative local fixtures through Commanded.

Preserve unfinished product thinking through a [linked coverage review](../../discovery/2026-11-02-vision-coverage.md), correct stale proposal claims, and give [writing integration](../../discovery/ideas/writing-and-question-links.md) its own home. This is repository knowledge, not additional website pages or a second issue tracker.

## Scope boundaries

The page consumes the existing aggregate result contract. It does not introduce collection, population slicing, time series, source ingestion, topic graphs, or statistical inference. Exact instruments, option order, respondent denominators, and withdrawal semantics remain intact. No new chart dependency is required.

## Evidence

Three LiveView regressions failed before implementation, then passed: chart/table navigation, multiple-selection denominators, and ordered-scale/empty presentation. A fixture regression failed before adding genuine multiple selections and an ordered-scale scenario. Browser and final verification findings follow in the PR.

Validation: `mix precommit` passes 72 backend tests, three frontend tests, compilation, Credo, formatting, and vault checks. `mix assets.build` passes. Native Safari inspection covers donut, ordered-scale, and multiple-selection pages, count/table switching, and a narrow browser window. Physical mobile-device testing remains outstanding. Seed expansion adds two instruments and 366 responses through Commanded; rerunning adds no duplicates (206 questions, 31,833 responses total). A regression also protects question pages with no topic.
