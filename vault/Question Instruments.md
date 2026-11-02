---
type: note
---

# Question Instruments

An instrument is the exact definition used to collect an answer: wording, language, format, instructions, and answer meanings. Its identity is separate from a topic or the broader quantity someone wants to investigate. The same topic can contain different instruments without making their measurements interchangeable. [Topic Graph](Topic%20Graph.md) organizes discovery; [Claims and Evidence](Claims%20and%20Evidence.md) defines what observations can support.

Options have stable identifiers within the instrument, independent of their displayed labels. A response refers to the instrument and selected option identifiers. An altered wording, option meaning, or format needs a distinct definition rather than silently reinterpreting earlier answers. Proposed equivalence, translation, or pooling belongs in an explicit, revisable relationship or analysis method.

## Formats and presentation

Binary and single-choice formats select one option. Multiple-selection answers select a set; their percentages can sum above 100% because the denominator is respondents. An ordered scale preserves category order without claiming equal numeric distances. Ranking, numeric values, and open text require their own semantics rather than encoding them as arbitrary strings in a selection field.

Display order, images, preceding information, and results displayed before answering belong to [Collection Context](Collection%20Context.md). They can vary while the underlying instrument remains identifiable. If an image is itself essential stimulus content, its exact identity must also become part of the instrument definition; storing optional surrounding image context alone does not implement visual-choice instruments.

Charts are presentations of evidence, not answer formats. A chart choice must not change the denominator or reinterpret an option. [The visualization exploration](discovery/ideas/data-led-visualizations.md) covers question-specific and multi-question views.

[The foundation decision](decisions/ADR-003-domain-admission-and-context-boundaries.md) and [instrument rules](../lib/roughly/questions/instrument.ex) define the implemented selection formats and remaining boundaries.
