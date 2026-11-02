---
type: decision
status: accepted
date: 2026-11-02
---

# ADR-004: Historical analysis and answer publication

## Context

A latest-answer projection cannot reconstruct past distributions. Reported answer time differs from receipt time, cross-question comparisons need explicit eligibility, and crawlable summaries can overstate what an open response set establishes. The application remains an unreleased preview with fictional data and no public collection adapter.

## Decision

Maintain a private response-revision projection atomically alongside current responses. Retain receipt time from EventStore, supplied answer time and its provenance, stable response/principal/instrument references, selections, status, and event order. [Response History](../Response%20History.md) defines the cutoff and revision rules. Response-count checkpoints use receipt order; answer-date reconstructions may change after backfills or corrections.

Exclude a withdrawn response from all public historical views. Live charts are recomputed views, not immutable releases. Evaluate qualifying and target answers at the same selected cutoff under [Population Analysis](../Population%20Analysis.md). Familiar demographic shortcuts reference exact instruments rather than authenticated-user profile fields. Apply a ten-respondent floor to conditional group publications, without claiming it solves disclosure risk.

Publish inspectable aggregate summaries and option-specific addresses alongside the full question. Closing collection retains evidence addresses. Use visible Dataset microdata, canonical metadata, and bounded sitemap shards under [Answer Discovery](../Answer%20Discovery.md). Keep preview fixtures noindex and require an explicit production indexing flag. No special search-result treatment or answer-engine inclusion is promised.

## Alternatives

Reconstructing history from current totals would invent unavailable evidence. Treating answer and receipt clocks as equivalent would conceal late-arriving observations. Fixed account demographics would conflate identity with separately sourced answers. Publishing historical withdrawals unchanged would require a different, reviewed publication and consent policy. Forum-style Q&A markup would misdescribe a fixed poll distribution.

## Consequences and limits

The disposable development projections and fixtures are rebuilt through the normal command path. No event compatibility machinery is required for those fixtures. Real collected history will require deliberate replay and release procedures.

Live analysis consists of multiple queries over asynchronous projections, not an atomic versioned research release. Stronger privacy controls, source validation, representative inference, multi-predicate studies, and public collection remain open. This decision establishes preview read contracts, not a validated survey methodology or permission to collect real answers.

[T-2026-020](../delivery/tasks/T-2026-020-evidence-exploration.md) records implementation and evidence; [ADR-003](ADR-003-domain-admission-and-context-boundaries.md) owns command admission and context boundaries.
