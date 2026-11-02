---
type: proposal
date: 2026-11-02
status: open
---

# Validated domain flow proposal

## Problem

As of November 2, 2026, local fixtures are written through Commanded and browsing reads Ecto projections. This demonstrates the persistence and read path; the app still lacks a validated public response-collection flow.

## Acceptance criteria

- Public domain command entry points and named queries over Ecto read models.
- Question/status/option validation and the participation controls chosen through [the participation investigation](2026-11-02-participation-design.md).
- Explicit duplicate-response and concurrency behavior at the command boundary.
- Integration coverage of event serialization/replay and projection-to-query behavior.
- Aggregate-only public reads and reviewed privacy/retention behavior before collection.
- A deliberate replacement of preview fixtures without mixing synthetic and collected counts.

Scope this into focused PRs as decisions become clear. A domain demonstration is not authorization to accept public responses.

## Related

- [Public discussion](https://github.com/bcooke/roughly/issues/10).
- [Domain Writes](../Domain%20Writes.md), [Read Models](../Read%20Models.md), and [System Architecture](../System%20Architecture.md).
- [Development Fixtures](../Development%20Fixtures.md).
