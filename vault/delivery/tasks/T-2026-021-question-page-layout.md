---
type: task
id: T-2026-021
status: completed
created: 2026-11-03
updated: 2026-11-03
---

# Question page layout and shared page edges

[PR #20](https://github.com/bcooke/roughly/pull/20) contains the implementation and validation.

## Outcome

Align navigation, divider, main content, and footer on one shared shell. Put question evidence in the main column and supporting navigation, counting details, and related questions in a responsive sidebar. Replace nominal donuts with shared-baseline bars, condense the header and answer summary, and place time and population analysis alongside each other on wide screens. Optional controls use native disclosures; narrow views retain section navigation and stack content.

[Result Presentation](../../Result%20Presentation.md) owns the presentation contract. Analysis, denominator rules, answer routes, and collection policy remain unchanged. The responsive timeline uses its measured width so chart labels remain readable in adjacent panels.

## Evidence

`mix precommit` passes 84 backend tests, three frontend tests, Credo, formatting, and documentation checks. `mix assets.build` passes. Native Safari checks cover desktop and narrow layouts, table navigation, and expanded date/comparison controls. Physical-device checks remain outstanding.

The related [answer-statement investigation](../../discovery/2026-11-03-answer-statements.md) captures a separate semantic modeling gap without pretending the layout implements it.
