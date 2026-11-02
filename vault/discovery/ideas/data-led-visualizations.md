---
type: idea
status: exploring
created: 2026-11-02
---

# Data led visualizations

## Possibility

Let visual interest come from the data: answer distributions, comparisons, changes over time, population intersections, and relationships among questions. A restrained interface need not be visually sparse when the information is rich.

Examples to explore include compact distribution charts in browsing, fuller comparisons on question pages, and linked views that show how a selected population changes an eligible result. None implies that the required data or analysis exists yet.

## Question views and exploratory pages

The visualization vocabulary should extend beyond bars. Candidate forms include pie/donut charts for suitable part-to-whole views, lines for supported temporal comparisons, and radar charts for exploration of comparable dimensions. Choose a form for the analytical question and available evidence; variety alone is not the objective. [Datawrapper’s chart selection guide](https://www.datawrapper.de/blog/chart-types-guide) offers examples organized by analytical purpose.

A question page can have a context-specific presentation and more than one useful view. Keep the response format separate from the result visualization: a single-choice question does not require one universal chart, and selecting a different chart must not alter what its answers mean. Radar dimensions, time-series points, or geographic estimates need meaningful underlying measurements rather than decorative transformations of unrelated counts.

A broader exploratory page could combine several questions into an interactive infographic, with linked population filters, comparisons, and contextual explanations. It should preserve the source instruments and denominator for each panel; several questions on one page do not imply one shared sample or interchangeable measures.

Population views should be reusable across questions where the evidence supports them: age, location, self-described attributes, or groups defined by answers to other questions. Population definitions are analytical predicates, not necessarily a fixed profile taxonomy. Missing qualifying answers remain unknown, and groups can overlap. [Collection Context](../../Collection%20Context.md) and the [intersection proposal](../2026-11-02-question-meaning-and-intersections.md) constrain which comparisons are defensible.

## Open questions

- Which visual forms help readers understand the question and denominator rather than merely spend more time on the page?
- How should small cells, uncertain estimates, missing answers, and incomparable instruments be represented?
- Which views belong in browsing versus answering? A data-generated chart can still expose results or frame a response.
- Can a useful accessible table or textual representation accompany each visualization?

A chart derived from data is not neutral by construction: selection, axes, aggregation, and emphasis are design choices. Evaluate comprehension and interpretation alongside interaction metrics. Do not add an appealing chart that implies unavailable evidence.

## Related

- [Design Philosophy](../../Design%20Philosophy.md).
- [Claims and Evidence](../../Claims%20and%20Evidence.md).
- [Population intersections](../2026-11-02-question-meaning-and-intersections.md).
- [Ideas index](README.md).
