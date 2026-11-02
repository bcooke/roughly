# Project Status

Updated November 2, 2026.

## Current milestone

A locally seeded application on a fresh Phoenix 1.8.16 foundation. Vue 3 and LiveVue 1.2.3 are integrated through Vite. The unreleased domain model is being rebuilt around exact instruments, evidence context, and explicit domain admission.

## Available

- Browsing over persisted question projections, topic filters, pagination, related questions, and aggregate response counts.
- Global search with live suggestions, keyboard navigation, session recents, typo tolerance, word variants, result previews, and shareable filtered results. Readable question URLs use event-sourced collision claims. See [T-2026-018](vault/delivery/tasks/T-2026-018-search-and-question-links.md).
- A plain About page and a simplified interface without repeated fixture notices or promotional slogans.
- Development fixtures seeded through Commanded: 204 questions across 17 topics, 360 invented participants, and 31,467 responses. Reruns preserve counts. These are invented local development data, not collected polling evidence.
- Ecto and EventStore setup, supervised projectors, regression tests, and query/LiveView tests.
- Shared contributor instructions, linked atomic notes, dated discovery, and decision records.
- GitHub CI for backend checks, vault links, and frontend builds.
- Internal domain admission: typed command/event/state/query contracts, runtime command validation, event-sourced capability grants, explicit actor attribution, response ownership checks, and stable response identities.
- Stable option identities, four selection formats, collection context with per-field provenance, and respondent denominators for multiple-selection results.
- Event-to-projection-to-query and serialization and replay coverage. See [T-2026-017](vault/delivery/tasks/T-2026-017-domain-foundation.md) and [ADR-003](vault/decisions/ADR-003-domain-admission-and-context-boundaries.md) for scope and consistency limits.

## Validation

`mix precommit` and `mix assets.build` are the local gates. Seed runs exercised the full command/event/projector/read-model path; rerunning the complete catalog appended no duplicate responses. The UI has been checked in Chrome and search interactions in Safari. Mobile device testing remains outstanding.

## Product direction

- Use the seeded application to refine question presentation, navigation, and visual direction.
- [Topic graph proposal](vault/discovery/2026-11-02-topic-graph-model.md): replace the interim single-category field with overlapping memberships and typed relationships; this is not implemented.
- [Participation investigation](vault/discovery/2026-11-02-participation-design.md): results exposure, identity, honesty, sampling, and privacy remain open.
- [Validated domain flow proposal](vault/discovery/validated-domain-flow.md): connect domain commands and projected reads to the application before real collection.

[T-2026-015](vault/delivery/tasks/T-2026-015-development-fixtures.md) records the fixture and interface work.

The [vault index](vault/README.md) leads to connected product/methodology and engineering notes. [Project Workflow](vault/Project%20Workflow.md) uses focused PRs and relevant checks with small T/BUG/IMP records for meaningful work and optional context files. [Foundation task](vault/delivery/tasks/T-2026-014-foundation-refresh.md) links the scope and context; [PR #11](https://github.com/bcooke/roughly/pull/11) contains the implementation and validation history.

## Open boundaries

The internal foundation is not a complete public participation system. Public authentication, answer collection, demographic slices, representative estimates, and production deployment are not implemented. Nonprofit governance is an intention to explore, not an established organization.

Historical design proposals under `vault/archive/` describe possible future behavior. Current runtime behavior and this status take precedence over those sketches.
