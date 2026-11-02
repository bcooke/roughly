---
type: decision
id: ADR-002
date: 2026-11-02
status: accepted
---

# Seed isolated development data through the domain

The six-question in-memory catalog could not adequately exercise browsing at scale or the application's persistence path. Use curated prompts and invented answer weights to seed development participants, questions, and responses through Commanded. Read their projections through the same named queries the application uses.

This amends the fixture detail of [ADR-001](ADR-001-foundation-refresh.md): invented development history is permitted in isolated development stores, with explicit metadata and seed tooling excluded from production compilation. It does not authorize mixing invented records with collected data.

Stable IDs make runs additive and resumable; they must not silently reinterpret old fixture history when wording or weights change. An intentional reset drops both Ecto and EventStore. Raw projection inserts remain appropriate for focused sandboxed read-side tests, not runtime seed authority.

Keep fixture provenance in developer tooling and documentation. The local interface represents the intended product without banners or repeated synthetic-count commentary. Do not publish seeded data as empirical evidence.

[Development Fixtures](../Development%20Fixtures.md) owns the working explanation. [T-2026-015](../delivery/tasks/T-2026-015-development-fixtures.md) records implementation evidence; [Claims and Evidence](../Claims%20and%20Evidence.md) defines the distinction from empirical knowledge.
