---
type: work
id: R-003
status: open
created: 2026-11-02
updated: 2026-11-02
---

# Build a validated event-sourced application flow

## Problem

As of November 2, 2026, browsing uses synthetic fixtures. Commanded aggregates and projectors exist, but the app lacks a complete validated collection flow over them.

## Acceptance criteria

- Public domain command entry points and named queries over Ecto read models.
- Question/status/option validation and the participation controls chosen through [R-002](R-002-participation-methodology.md).
- Explicit duplicate-response and concurrency behavior at the command boundary.
- Integration coverage of event serialization/replay and projection-to-query behavior.
- Aggregate-only public reads and reviewed privacy/retention behavior before collection.
- A deliberate replacement of preview fixtures without mixing synthetic and collected counts.

Scope this into focused PRs as decisions become clear. A domain demonstration is not authorization to accept public responses.

## References

- [Public discussion](https://github.com/bcooke/roughly/issues/10).
- [Domain Writes](../Domain%20Writes.md), [Read Models](../Read%20Models.md), and [System Architecture](../System%20Architecture.md).
- [Synthetic Preview Data](../Synthetic%20Preview%20Data.md).
