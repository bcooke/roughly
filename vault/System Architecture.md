---
type: note
---

# System Architecture

Roughly separates an event-sourced domain, queryable read models, and a Phoenix web interface. [Domain Writes](Domain%20Writes.md) defines authoritative state changes; [Read Models](Read%20Models.md) defines derived reads.

The [application supervision tree](../lib/roughly/application.ex) starts repositories, Commanded, projectors, and the HTTP endpoint. [Runtime configuration](../config/runtime.exs) owns deployment connection settings. The [setup aliases](../mix.exs) own initialization commands. These pointers are preferable to maintaining duplicate inventories of modules and settings.

Phoenix owns routes and server state. HEEx renders readable content; Vue through LiveVue supplies browser interactions. [Vite configuration](../assets/vite.config.mjs) resolves browser clients from locked Hex packages, keeping browser and server implementations aligned. Dependency changes require a clear purpose and license review.

[Development Fixtures](Development%20Fixtures.md) identifies the development-only data source. The web layer reads question and vote projections through [the Questions entry point](../lib/roughly/questions.ex). [Project Status](../PROJECT_STATUS.md) identifies implemented capabilities, and [the domain flow proposal](discovery/validated-domain-flow.md) tracks the real-domain flow. [The foundation ADR](decisions/ADR-001-foundation-refresh.md) records the scaffold choice and its tradeoffs.
