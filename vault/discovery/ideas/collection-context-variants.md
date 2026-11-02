---
type: idea
status: exploring
created: 2026-11-02
---

# Collection context and method variants

## Possibility

Support more than one collection experience while preserving the conditions needed to distinguish their evidence. This could allow method comparisons and iteration without committing every question to one format or one participation model.

## Candidate context

| Dimension | Examples to distinguish |
| --- | --- |
| Instrument | Exact wording/version, language, instructions, answer meanings, question format |
| Presentation | Displayed answer order, scale orientation, actual images, layout variant |
| Information | Results displayed before answering, preceding prompts or claims, known entry route |
| Participation | Anonymous/pseudonymous/identified conditions and the actual assurance mechanism |
| Collection | Source, mode, time/cutoff, eligibility, assignment to a study variant |
| Evidence status | Observed, participant-reported, inferred, unknown |

Define the minimum useful context, shared run configuration, per-response differences, and access/retention rules before implementing fields. Do not turn the table into a mandate to collect all possible telemetry or personal information.

## Formats and answering modes

Question formats need explicit answer semantics: binary, single-choice, multiple-selection, ordered scale, numeric input, ranking, and open response are possibilities with different validation and analysis needs. A type label alone does not establish support. Selection counts for a multiple-selection question need not sum to its respondent denominator; scale categories are not automatically numeric intervals.

Answering mode is a separate choice: answering one question, moving through related questions, or participating in a defined survey sequence can use the same underlying instrument while introducing different context. Preserve relevant order and preceding material. Relatedness helps navigation without establishing measurement equivalence.

## Analysis questions

Which comparisons are defensible? Which variants should remain separate? Can an experiment identify an effect, or is participation into each method itself selective? What cannot be recovered from historical data? How should a public result expose its method and denominator?

Context supports investigation; it is not a universal adjustment variable. Knowing that an image was rendered does not prove it was seen. Knowing that one identity policy was used does not establish honesty. Unobserved exposure, coverage gaps, and unmeasured differences can remain.

The domain implements four selection formats and a bounded collection-context value; see [ADR-003](../../decisions/ADR-003-domain-admission-and-context-boundaries.md). Public collection modes, study assignment, and adjustment methods remain unimplemented. [Collection Context](../../Collection%20Context.md) explains the enduring distinctions; this idea owns the open implementation questions.

## Related

- [Participation investigation](../2026-11-02-participation-design.md).
- [Question instruments and intersections](../2026-11-02-question-meaning-and-intersections.md).
- [Question imagery](question-imagery.md).
- [Ideas index](README.md).
