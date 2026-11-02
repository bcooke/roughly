---
type: note
---

# Bounded Contexts

A bounded context owns a coherent model and the meaning of its terms. A question instrument, a participant's answer, an account credential, and a published estimate have different rules and lifecycles. Contexts make their relationships explicit rather than sharing one universal user or question object. [Fowler's explanation](https://martinfowler.com/bliki/BoundedContext.html) grounds the distinction in model consistency and language; it does not prescribe Roughly's particular split.

## Working context map

| Context | Owns | Supplies to other contexts |
| --- | --- | --- |
| Question knowledge and curation | Exact instruments, option meaning, publication lifecycle, topic assertions | Instrument identities and answer-eligibility decisions |
| Participation | Response identity, changes, withdrawals, collection context | Recorded observations with source and instrument references |
| Identity and access | Principals, authentication, grants, account standing | Verified identity assertions and current capabilities |
| Analysis and publication | Population definitions, eligible denominators, result and release contracts | Aggregate evidence with declared interpretation |

These boundaries can live in one application. A context is neither a service requirement nor an aggregate boundary. Aggregate boundaries follow consistency requirements within the model. Revisit a split when actual workflows reveal conflicting language or lifecycles, not simply when a directory becomes large.

## Where authentication and authorization fit

Authentication verifies a principal through credentials or another chosen mechanism. Identity and access owns that mechanism and its session lifecycle. [Phoenix scopes](https://phoenix.hexdocs.pm/scopes.html) can carry authenticated request context; a scope is not itself proof of permission for every resource.

Authorization combines current capabilities with rules owned by the relevant context. Participation decides whether the actor may change a particular answer; questions decides whether an instrument accepts an answer; publication decides what evidence can be disclosed. [Authorization](Authorization.md) defines admission beneath adapters. Shared enforcement should not turn identity and access into the owner of every domain's rules.

Participant continuity and [Participant Identity](Participant%20Identity.md) assurance are not synonymous with an account. Avoid making demographics or real-world identity mandatory merely because an authentication library models users. Cohorts can be derived from separately sourced observations under explicit analysis definitions.

## Persistence and integration

[Domain Writes](Domain%20Writes.md) preserves accepted domain history. Credentials, recovery secrets, and session tokens need purpose-specific mutable storage and expiry rather than automatic inclusion in immutable events. [Read Models](Read%20Models.md) serves derived results. The [foundation decision](decisions/ADR-003-domain-admission-and-context-boundaries.md) records implementation mapping, consistency limits, and unreleased-model iteration policy.
