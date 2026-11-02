---
type: note
---

# Domain Writes

Durable Roughly domain facts flow through commands, pure aggregates, immutable events, and EventStore. [Read Models](Read%20Models.md) derive queryable state from that history. A projector's database write is part of that derivation, not an independent source of domain truth.

Aggregate execution validates intent against aggregate state and emits events. Applying events rebuilds that state. Cross-aggregate policy, authorization, and validation belong at explicit domain boundaries, with tests for concurrency and replay where those properties matter.

Transient navigation, search filters, and build artifacts do not need domain events. [Development Fixtures](Development%20Fixtures.md) deliberately exercise domain events in isolated development data; they do not represent real participant actions. New persistent writes need an explicit authority and rebuild story; a convenient direct Ecto write is not sufficient justification.

Event sourcing does not imply retaining every private value forever in an event envelope. The storage, linkage, and erasure of personal payloads need a deliberate [Participant Identity](Participant%20Identity.md) and privacy design before real collection.

The [command router](../lib/roughly/router.ex) and [Commanded application](../lib/roughly/app.ex) are implementation entry points. [the domain flow proposal](discovery/validated-domain-flow.md) tracks the gap between the domain foundation and a complete collection flow.

Commands, events, and aggregate state need contracts describing actual field values, including nullability and serialized representations. Transition specs describe reachable successes and refusals; runtime parsing and aggregate rules enforce admission. [Authorization](Authorization.md) makes the trusted actor and resource policy explicit. A typespec or projection constraint alone cannot enforce these rules.
