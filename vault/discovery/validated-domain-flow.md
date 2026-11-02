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

## Foundation review on November 2, 2026

The command/event/aggregate and projection/query directories provide CQRS structure, but they do not yet provide complete domain contracts. `CastVote` and `CreateQuestion` are plain structs without field types or runtime command parsing; the router installs logging but no validation or authorization middleware. The aggregate checks some lifecycle transitions but does not establish that a selected option belongs to an active instrument. Public question queries inspected in this review lack input/output specs. Existing aggregate tests exercise transitions, not a complete admission path; passing them does not establish test-first chronology or authorization coverage.

The user aggregate also combines account credentials and demographic fields. That is an inherited arrangement to evaluate, not a decision that accounts, participant attributes, and response identity must share one lifecycle or immutable storage policy.

### Candidate bounded contexts

| Context | Owns | Explicit boundary |
| --- | --- | --- |
| Question knowledge and curation | Instruments, option meaning, publication lifecycle, topic assertions | Publishes versioned instruments; does not decide an individual's answers |
| Participation | Responses, changes, withdrawals, collection context, duplicate policy | Refers to exact instruments and a permitted participant scope |
| Identity and access | Principals, credentials, assurance, grants, account standing | Supplies verified actor identity and current capabilities; avoids conflating demographic observations with credentials |
| Analysis and publication | Population definitions, eligibility, aggregate results, release contracts | Derives evidence through declared source contracts; does not rewrite source answers |

These are working boundaries to validate through concrete use cases in one application, not a mandate for services, separate databases, or one aggregate per context. Contexts own business vocabulary and rules; aggregate boundaries follow consistency needs. Resource-specific authorization combines access capabilities with the owning context's rules.

### Test-first next slice

Before adding public writes, demonstrate failing tests for malformed commands, invalid option/instrument combinations, missing authority, cross-participant mutation, and duplicate/concurrent response behavior. Establish truthful command/event/state types, transition and query specs, runtime parsing, and explicit actor admission as part of a narrow end-to-end feature. Prove refused dispatch writes no events, and preserve replay of historical events without applying new admission rules retroactively.

The [exploration proposal](2026-11-02-question-meaning-and-intersections.md#proposed-next-implementation-slice) supplies a visible feature to exercise these boundaries. A small actor/capability matrix can precede it; final role names, anonymous participation rules, and sensitive-data lifecycle remain open. [Authorization](../Authorization.md) records the enduring distinctions.
