---
type: note
---

# Read Models

Read models optimize access to facts whose authority lies in event history. Projectors translate delivered events into Ecto schemas; public entry points and named query modules keep business queries out of the web layer.

Delivery can be repeated, and replay reconstructs older events through the same interpretation boundary. Projector behavior needs tests for serialized payloads, duplicate delivery, ordering assumptions, and schema compatibility. The [question projector regression test](../test/roughly/questions/projections/projector_test.exs) exercises JSON enum casting, close transitions, and duplicate delivery.

A unique index in a projection protects that table; it does not alone define a correct concurrent command policy. Coordinate those requirements with [Domain Writes](Domain%20Writes.md).

The read-only [Synthetic Preview Data](Synthetic%20Preview%20Data.md) catalog is a fixture source, not a projection of collected responses. [System Architecture](System%20Architecture.md) points to the runtime boundaries.
