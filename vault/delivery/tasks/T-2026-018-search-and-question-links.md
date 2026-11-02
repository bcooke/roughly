---
type: task
id: T-2026-018
status: completed
created: 2026-11-02
updated: 2026-11-02
---

# Improve search and readable question links

## Outcome

- Search matches whitespace-separated words across prompts, topic names, and answer labels, retaining literal wildcard escaping and topic/pagination filters.
- Live typing and native GET submission share the `q` parameter. An explicit search-all-topics action preserves the query when leaving a topic.
- Public question URLs use readable slugs. Per-route event-sourced claims serialize concurrent collisions; only actual duplicates gain numbered suffixes. Instrument UUIDs remain internal.
- Question result explanations distinguish multiple-selection denominators and use the current withdrawal terminology.

## Evidence

Observed four failing regressions before implementation: multiword lookup, GET-form fallback, leaving a filtered search, and UUID-free concurrent slug allocation. Tests now cover those cases plus collisions with naturally numbered prompts and refusal to publish an unclaimed route. Invalid definitions do not reserve routes.

Basic typing of “coffee” already worked in a fresh Chrome tab; the reported complete search failure was not reproduced there. The change addresses verified limitations without claiming an unidentified failure's cause.

[Question Links](../../Question%20Links.md) records the route contract. The next question-page work should use representative binary, ordered-scale, and multiple-selection examples to develop suitable visualizations and population comparisons; it is outside this repair's scope.

Validation: `mix precommit` passes 61 tests plus compilation, Credo, formatting, and vault checks. `mix assets.build` passes.
