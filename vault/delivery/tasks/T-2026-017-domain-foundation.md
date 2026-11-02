---
type: task
id: T-2026-017
status: completed
created: 2026-11-02
updated: 2026-11-02
---

# Establish the domain architecture foundation

## Outcome

Establish a coherent path from a trusted actor through typed command contracts, runtime validation, capability and ownership checks, aggregates and stored events, projectors, and aggregate-only query contracts. Keep public collection disabled while participation and privacy policy remain open.

[The context map](../../Bounded%20Contexts.md) and [ADR-003](../../decisions/ADR-003-domain-admission-and-context-boundaries.md) define ownership, authentication placement, persistence choices, and implementation limits. No complete authentication system or all future question formats are claimed.

## Evidence

- Ran seven new integration tests before implementation: all failed because the admission and facade APIs were absent.
- Added ownership and missing-response tests: observed an unauthorized change emit an event and missing-state transitions crash. Added contract tests: observed missing types/specs fail. Implemented and refactored with those outcomes green.
- Added an event-to-projection-to-query test: observed equal-worded instruments collide on a slug; added identity-based slugs.
- Tests cover malformed-command and authorization refusals without events, attribution spoofing, grant/revoke behavior without projection delay, principal deactivation, ownership at admission and in aggregates, closed-question behavior, concurrent duplicates, serialized domain payloads, duplicate projector delivery, retraction, and aggregate-only output.
- Removed the inherited credential/profile and vote model; rebuilt it as principal lifecycle and participation responses. Removed unused update scaffolding and development-history compatibility obligations.
- Instrument tests began red for stable options, format cardinality, context provenance, and set semantics; implementation preserves selected UUIDs and collection context through serialization. Multiple-selection query tests caught and corrected a UUID-loading error.
- Development setup rebuilds 204 questions, 360 principals, and 31,467 invented responses against the chosen model.

## Remaining boundaries

The foundation is internal. Public authentication and participation adapters, privacy/retention behavior, strict cross-stream ordering, study/run identities, richer collection/analysis, and the topic graph remain subsequent work. These limits are part of the accepted implementation scope, not evidence that those capabilities have shipped.

Local verification: `mix precommit` passes 56 tests, Credo, formatting, compilation, and vault checks; `mix assets.build` passes. Integration is recorded by the associated PR.
