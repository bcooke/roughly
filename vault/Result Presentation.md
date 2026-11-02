---
type: note
---

# Result Presentation

A result view presents a declared denominator and the observations counted against it. Switching its chart, table, or displayed unit must not change its population or answer semantics. [Claims and Evidence](Claims%20and%20Evidence.md) distinguishes a response distribution from an estimate of the wider population; [Question Instruments](Question%20Instruments.md) defines the exact options being counted.

## Question views

The [question page](../lib/roughly_web/live/question_live.ex) chooses a part-to-whole donut for small binary/single-choice option sets, independent horizontal bars for multiple selections or longer nominal lists, and columns in instrument order for ordered scales. Geometry uses unrounded count ratios; displayed percentages are rounded. Ordinal positions do not establish equal numerical intervals. Multiple-selection shares use respondents as their denominator and need not sum to 100%.

All views preserve option order and stable answer identities. Labels and counts accompany color, and a semantic table provides the same counts and shares. An empty denominator has an explicit empty state rather than an invented leading answer. Percentage/count display changes annotation, while chart geometry remains a response share.

Chart/table and displayed-unit choices are URL state. [Question Links](Question%20Links.md) can preserve that view, but a changing result remains distinct from a versioned evidence citation. The page exposes no individual response histories.

## Further analysis

The implemented timeline uses [Response History](Response%20History.md), and cross-question views use [Population Analysis](Population%20Analysis.md). Time series require comparable observations at defined cutoffs. Population comparisons require eligible intersections, missingness rules, and a privacy policy. Neither can be manufactured from a single aggregate distribution; the revision projection and qualifying-answer joins supply the additional evidence for these views. [The visualization exploration](discovery/ideas/data-led-visualizations.md) holds broader possibilities, and [population intersections](discovery/2026-11-02-question-meaning-and-intersections.md) defines the analysis work still needed.
