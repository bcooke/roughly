---
type: note
---

# Domain Writes

Durable Roughly domain facts flow through commands, pure aggregates, immutable events, and EventStore. [Read Models](Read%20Models.md) derive queryable state from that history. A projector's database write is part of that derivation, not an independent source of domain truth.

Aggregate execution validates intent against aggregate state and emits events. Applying events rebuilds that state. Cross-aggregate policy, authorization, and validation belong at explicit domain boundaries, with tests for concurrency and replay where those properties matter.

Transient navigation, search filters, build artifacts, and [Synthetic Preview Data](Synthetic%20Preview%20Data.md) are not durable participant actions and do not need domain events. New persistent writes need an explicit authority and rebuild story; a convenient direct Ecto write is not sufficient justification.

Event sourcing does not imply retaining every private value forever in an event envelope. The storage, linkage, and erasure of personal payloads need a deliberate [Participant Identity](Participant%20Identity.md) and privacy design before real collection.

The [command router](../lib/roughly/router.ex) and [Commanded application](../lib/roughly/app.ex) are implementation entry points. [the domain flow proposal](discovery/validated-domain-flow.md) tracks the gap between the domain foundation and a complete collection flow.
