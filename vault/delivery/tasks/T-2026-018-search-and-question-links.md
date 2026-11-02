---
type: task
id: T-2026-018
status: completed
created: 2026-11-02
updated: 2026-11-02
---

# Global search and readable question links

## Outcome

[PR #17](https://github.com/bcooke/roughly/pull/17) makes search a shared discovery surface with inline suggestions, a header modal, keyboard selection, recent searches, and full results with topic and question-format filters. Result previews show aggregate response counts and a leading answer. The interface includes loading, empty, retry, and stale-request handling, with native GET navigation as a fallback.

Retrieval matches prompt, topic, and answer wording using English stemming, literal fragments, and word-level typo tolerance. Examples covered by tests include “cofee,” “liking coffee,” and “What percentage of people like coffee?” Search does not infer instrument equivalence or synthesize statistical claims. [Search](../../Search.md) owns the retrieval and interaction contract.

Public question URLs use readable slugs. Per-route event-sourced claims serialize concurrent collisions; actual duplicates receive numbered suffixes. Instrument UUIDs remain internal. [Question Links](../../Question%20Links.md) records the contract and reservation limits.

Question explanations distinguish multiple-selection denominators and use withdrawal terminology. A larger question-page redesign remains the next separate milestone: representative formats, appropriate visualizations, and clearly defined population comparisons.

## Evidence

Observed failing tests before implementation for multiword lookup, native GET fallback, leaving a filtered search, concurrent UUID-free slug allocation, richer retrieval, and frontend request-state behavior. Passing regressions cover natural numbered collisions, refusal to publish unclaimed routes, invalid definitions without reservations, malformed API input, format filters, and public output boundaries.

Validation: `mix precommit` passes 67 ExUnit tests, three frontend request-state tests, compilation, Credo, formatting, and vault checks. `mix assets.build` passes Vue/TypeScript and the production build. Native Safari checks exercise typo suggestions, arrow-key selection into a readable route, global Command K, session recents, and submission to the full results page. Desktop visuals were inspected; mobile device testing remains outstanding.

The disposable development databases were rebuilt through the normal seed path to exercise the new slug claim flow. The complete catalog reran without duplicate responses.
