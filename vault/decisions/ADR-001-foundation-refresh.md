---
type: decision
id: ADR-001
date: 2026-11-02
status: accepted
---

# Refresh the application foundation

## Context

On November 2, 2026, the application had a generated homepage, early Commanded aggregates, projection modules, migrations, and unit tests. It had no working public response-collection flow. The intended Vue integration also changed the asset pipeline, so a fresh generated baseline offered a smaller configuration audit than incrementally adapting the earlier scaffold.

## Decision

Generate a fresh Phoenix 1.8.16 scaffold, integrate LiveVue through its supported installer, and selectively carry over domain code, tests, migrations, and useful documentation. Preserve Git history and serialized event names. Keep one application at the repository root.

Use Phoenix for routes and server state, with Vue for browser interactions. Avoid PrimeVue and unnecessary component suites. Keep core content in HEEx and disable Vue SSR for the preview, avoiding an additional JavaScript server runtime. Keep synthetic counts outside persistent user and response history.

## Rationale and alternatives

An in-place dependency update would preserve more generated configuration, but the small amount of application behavior did not justify retaining an asset setup being replaced. Copying a mature application's entire framework would also import dependencies and operational assumptions unrelated to Roughly. A new repository would fragment useful history.

## Consequences

The generated defaults still require review, including dependency cost and runtime configuration. The domain remains an early foundation; adopting Commanded does not implement authorization, collection policy, privacy, or cross-domain validation. Those gaps are tracked in [the domain flow proposal](../discovery/validated-domain-flow.md), with methodology in [the participation investigation](../discovery/2026-11-02-participation-design.md).

[System Architecture](../System%20Architecture.md) and [Domain Writes](../Domain%20Writes.md) own the continuing explanation. [The foundation PR](https://github.com/bcooke/roughly/pull/11) records validation and integration; accepting the scaffold direction does not imply production deployment.
