---
type: note
---

# Population Analysis

A population can be defined by an answer to another exact instrument. This supplies reusable intersections without putting age, gender, location, or other attributes on an account profile. Familiar demographic shortcuts select ordinary question instruments; they do not verify those answers or create a fixed classification system.

For target answer B, qualifying answer A, and an eligible response to target E, the observed share is `|A ∩ B| / |A ∩ E|`. The denominator is respondents who both qualify and answered the target. Missing qualifying answers remain missing. A source with multiple selections can produce overlapping populations. [Question Instruments](Question%20Instruments.md) preserves each source's exact wording and option identities.

## Selection policy

The [analysis facade](../lib/roughly/analysis.ex) and [history queries](../lib/roughly/analysis/queries/history.ex) select the latest applicable version under the chosen clock and cutoff. Qualifying membership is evaluated at that same cutoff, rather than assumed to be permanent or evaluated at the target answer's original moment. [Response History](Response%20History.md) defines the two clocks and withdrawal behavior.

The comparison reports eligible overlap and missing qualifying answers separately. Choosing a group applies its predicate to the main distribution and trends. A comparison answers a conditional question about recorded respondents; [Claims and Evidence](Claims%20and%20Evidence.md) constrains interpretation beyond that group.

## Disclosure boundary

Public group breakdowns require at least ten eligible respondents. Below that floor, totals and answer distributions are withheld; trend points use the same floor. The [public-result contract](../lib/roughly/analysis.ex) performs this suppression before presentation. Internal snapshot queries remain available for calculation and tests.

This floor is not a complete privacy mechanism: overlapping queries, totals, and differences can reveal small cells. A reviewed publication and participation policy remains necessary before collecting real answers. Stronger release controls, minimum cells, repeated-query limits, and appropriate consent are open work, not guarantees provided by this implementation.
