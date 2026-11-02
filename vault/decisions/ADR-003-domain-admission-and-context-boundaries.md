---
type: decision
status: accepted
date: 2026-11-02
---

# Domain admission and context boundaries

## Context

The initial CQRS layout demonstrated persistence, but plain structs and transition tests did not establish runtime validation, actor authority, resource ownership, or complete contracts. Option labels served as answer identities, and the user aggregate mixed credentials with demographic fields. No production data exists; disposable development history does not justify preserving those shapes.

## Contexts and storage

Adopt the [working context map](../Bounded%20Contexts.md) in one Phoenix application. `Questions` owns exact instruments and eligibility; `Participation` owns responses and collection conditions; `Identity` owns principal continuity and standing; `Access` owns grants and common admission; `Analysis` owns aggregate read contracts. Knowledge curation, authentication, and publication remain broader responsibilities of the map, with concrete implementations added as workflows require them.

Remove the inherited user/profile model and unused question-update scaffolding. A principal contains no credential or demographic profile. Credentials, recovery secrets, and sessions will use purpose-specific mutable storage behind a reviewed authentication adapter. [Phoenix's authentication documentation](https://phoenix.hexdocs.pm/mix_phx_gen_auth.html) supplies a starting point; no login or signup flow is introduced here.

Rewrite development schemas and rebuild fixtures when the model changes. Do not add migrations, stream aliases, or compatibility decoders solely for unreleased fixture history. Current serialization and replay still need tests: an event written today must reconstruct the intended state.

## Instruments and evidence

A question UUID identifies one exact, immutable instrument: wording, language, format, ordered option definitions, and stable option UUIDs. Similar wording or topic membership does not merge results. URLs include instrument identity, allowing equal-worded instruments without collisions. [Question Instruments](../Question%20Instruments.md) distinguishes format from presentation.

Support binary, single-choice, multiple-selection, and ordered-scale selection semantics. Store selected option UUIDs as a set, not labels or incidental click order. Repeated option IDs are refused. Scales retain category order without assuming equal intervals or computing an unjustified mean. Numeric, ranking, and open-response semantics remain separate future formats.

Record collection context on initial answers and revisions: known presentation order, result display, mode, assurance, immutable image hashes, presentation variant, run reference, and an optional answer time. Per-field provenance distinguishes observed, reported, inferred, and unspecified values. Missing context remains unknown. The event envelope's recording time is not automatically the time an imported answer was given. Context enables investigation; it does not correct bias or establish equivalent measurements.

One active response stream per instrument/principal serializes duplicate submissions. A changed answer preserves prior events; withdrawal excludes it from current counts. Multiple-selection percentages use the number of active respondents, not the number of selections. Run references are provenance only in this slice: they do not implement repeated-measurement identities, study assignment, or run-specific estimates. The interim category field remains discovery scaffolding pending the [topic graph implementation](../discovery/2026-11-02-topic-graph-model.md).

## Admission and contracts

Every routed command passes domain-owned shape validation and fail-closed actor/capability admission. `Dispatch` stamps flat attribution from a trusted actor and prevents supplied metadata replacing that actor. The envelope is an internal identity assertion, not an authentication token. Adapters must derive it from verified state; arbitrary trusted Elixir code can construct one.

Resolve principal standing and grants from authoritative event history, independent of projector delay. Capabilities are `curate_questions` and `manage_access`; roles can bundle them later. Named system sources have explicit permissions, with no default bypass. Only development enables fixture seeding; fixtures obey the same instrument, selection, and response-identity rules.

Participation owns response ownership and calls questions for eligibility. Changes and withdrawals carry a bound actor, checked again in the response aggregate. Withdrawal remains possible after question closure. [OWASP's authorization guidance](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) supports least privilege and enforcement across entry points; it does not establish production readiness.

Commands, events, state, transitions, and public queries publish truthful contracts. Runtime parsing and behavior tests enforce rules; typespecs alone do not. Architecture checks guard contract coverage and the dispatch seam. Projectors and aggregate-only queries are exercised from persisted, serialized events.

## Consistency and remaining boundaries

Cross-stream checks observe authoritative state at admission. A close, revocation, or deactivation concurrent with another stream's admitted write is not one atomic transaction. A subsequent admission sees the completed change; strict commit ordering needs a deliberately different consistency design. Event-history reads favor a simple authority over throughput; replacing them with projections requires defined lag/revocation semantics.

Public collection, authentication adapters, anonymous participation policy, privacy/retention behavior, study/run semantics, population comparisons, topic graph persistence, external evidence ingestion, and dataset publication remain subsequent work. [T-2026-017](../delivery/tasks/T-2026-017-domain-foundation.md) records the implemented foundation and checks.
