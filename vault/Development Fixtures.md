---
type: note
---

# Development Fixtures

Development fixtures exercise the application's real command, event, projection, query, and interface paths with invented data. They are an engineering tool, not evidence about a population.

The [curated catalog](../dev/roughly/dev/questions.json) contains question wording, options, and invented response weights. [The seed generator](../dev/roughly/dev/seeds.ex) creates stable identities, dispatches commands with development-source metadata, skips existing records, and waits for projections. Deterministic IDs make a rerun resumable without appending duplicate responses.

Seed code compiles only in development and test builds; execution requires explicit development configuration. Seed participants are principals without credentials or demographic profiles. Production configuration does not enable seeding. Keep generated development history in a development database, separate from any collected data.

The interface presents the intended product experience without repeating engineering caveats on each page. Fixture provenance belongs in the development environment, seed code, and README. Do not deploy a database of invented responses as public polling results or treat plausible-looking weights as researched estimates.

[Domain Writes](Domain%20Writes.md) defines the persistence path and [Read Models](Read%20Models.md) defines aggregate reads. [Polling Methodology](Polling%20Methodology.md) governs interpretation of collected data. The README owns [setup and repeatable seed commands](../README.md#run-locally).
