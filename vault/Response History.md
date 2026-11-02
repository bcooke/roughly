---
type: note
---

# Response History

Current answers and historical evidence are different read contracts. The current response projection supports browsing; a private revision projection preserves accepted selections, revisions, and withdrawals for analysis. Both are updated in one projector transaction, with duplicate event delivery ignored. The [history query](../lib/roughly/analysis/queries/history.ex) owns revision selection; [Domain Writes](Domain%20Writes.md) remains authoritative.

## Two clocks

Receipt time comes from EventStore metadata. Answer time comes from collection context, with receipt time as an explicit fallback. Per-field provenance is retained; an answer date can be reported rather than independently observed. [Collection Context](Collection%20Context.md) explains that distinction.

Receipt-date snapshots reconstruct what had been recorded by a cutoff. Answer-date snapshots reconstruct retained evidence dated at or before that cutoff, ordered by event number to resolve revisions. Backfilled evidence or corrections can revise earlier answer-date points. These are not interchangeable histories, nor a guarantee that a population's preferences changed.

The public date view uses month-end cumulative distributions, including the selected date as the final checkpoint. Empty denominators are gaps, not zero-percent measurements. The response-count view samples the retained first-response sequence at up to 24 checkpoints and includes the final revisions. Its horizontal axis counts retained question responses across all respondents; a selected population has its own eligible denominator at each checkpoint. It uses receipt time and order. It is distinct from a monthly incidence distribution or a longitudinal study of a fixed panel.

## Withdrawal and publication

A withdrawn response is excluded from every public historical view, including cutoffs preceding its withdrawal. Historical charts therefore change after withdrawals; they are not immutable releases. [Question Links](Question%20Links.md) and [dataset release exploration](discovery/ideas/open-api-and-dataset-releases.md) distinguish live exploration from a reproducible, policy-governed citation.

Private revision rows include continuity identifiers needed for joins. Only aggregate DTOs reach the page. [Population Analysis](Population%20Analysis.md) applies the same cutoff to qualifying and target responses. No public response-collection adapter is enabled by these read capabilities.

Live exploration gathers several queries over asynchronous projections. A shared analytical cutoff is not an atomic, versioned publication snapshot; reproducible releases need a declared evidence watermark and release policy.

Live exploration gathers several queries over asynchronous projections. A shared analytical cutoff is not an atomic, versioned publication snapshot; reproducible releases need a declared evidence watermark and release policy.
