---
type: note
---

# Authorization

Authentication establishes a principal; authorization decides whether that principal may perform an operation on a resource. Public reading, participation, curation, and administration have different capabilities. A role can bundle capabilities, but an account, verified identity, or administrative title does not by itself establish permission to every operation or access to private responses.

## Admission at the domain boundary

Resolve actor identity at a trusted entry point and carry it explicitly into command dispatch. Resolve current permissions from authoritative policy rather than trusting roles or privileges supplied in a request. The actor initiating an operation can differ from its subject: creating or changing an answer must not let a caller impersonate another participant by supplying their identifier.

Enforce capability, resource scope, ownership, and lifecycle constraints beneath UI adapters. LiveView, API, workers, and maintenance tools must use the same admission rules. A hidden button is not enforcement. System actors need explicit purposes and permissions rather than an automatic bypass. Restricted reads need their own access checks; successful write authorization does not make answer histories public.

[Domain Writes](Domain%20Writes.md) records accepted facts. Admission failures should return a defined refusal without producing domain events. A separate operational audit may record a refusal without treating it as an accepted action. Test direct dispatch and alternate entry points, including revoked authority and attempts to change another participant's answer.

## Identity and policy remain separate

[Participant Identity](Participant%20Identity.md) separates continuity, assurance, and public attribution. Anonymous or pseudonymous participation can have explicitly scoped capabilities; registered accounts need not imply public attribution. The participation policy must decide which actions each condition permits. No KYC requirement, fixed role hierarchy, or anonymous collection policy follows from this distinction.

[Bounded Contexts](Bounded%20Contexts.md) separates identity/access ownership from domain-specific policy. [ADR-003](decisions/ADR-003-domain-admission-and-context-boundaries.md) defines the internal admission implementation, trusted actor boundary, system permissions, and consistency limits. This is a command foundation; public authentication and a complete participation policy remain separate work.
