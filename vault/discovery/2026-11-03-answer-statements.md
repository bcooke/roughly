---
type: research
date: 2026-11-03
status: open
---

# Answer statements and population predicates

An answer option can identify a proposition as well as a selectable response. For “How often do you do X?”, the label “Sometimes” can correspond to “does X sometimes.” Each option can then support a proportion statement: “[share] of [population] do X sometimes.” Formalizing that relationship is domain work, not merely search copywriting. The terminology below is provisional; it does not establish a new philosophical category or an implemented schema.

[Population Proportions](../Population%20Proportions.md) refines the vocabulary: an open condition becomes a proposition when applied to a subject and scope. The [research review](2026-11-03-knowledge-and-measurement.md) grounds that distinction in broader prior art. The proposed sentence contract below remains unimplemented.

## Separate meaning from measurement

| Element | Proposed role |
| --- | --- |
| Answer proposition | A statement with an explicit subject whose meaning corresponds to an exact instrument and option; it does not contain a changing percentage. |
| Population definition | A predicate specifying who qualifies, with a reference time and qualification rules. |
| Target proportion | The share of the defined population for whom the proposition holds, over a specified time or interval. |
| Observed proportion | The share in an eligible evidence set, under stated answer-selection and counting rules. |
| Evidence-backed statement | A rendering of an observed result, retaining counts, denominator, time, sources, and method. |

The target proportion may exist even when no observations are available. A result of zero is different from an unknown result. “Always,” “sometimes,” and “never” need the instrument's reference period and meaning; language alone does not establish precise frequency thresholds. A percentage is a value attached to a scoped proposition, not the identity of the proposition itself.

[Claims and Evidence](../Claims%20and%20Evidence.md) distinguishes the target from its evidence. A response supports “this respondent selected this option,” with further assumptions needed to infer that the proposition holds in their life. Public wording must not convert respondents into all people through a sentence template.

## Populations as related questions

A qualifying answer to another instrument supplies a membership predicate. The same target proposition can be evaluated overall or among qualifying respondents without creating unrelated copies of its meaning. Missing qualification is unknown, not false. Multiple-selection predicates may overlap. “Overall” must still declare an eligible universe; it does not mean humanity automatically.

A derived predicate such as “aged 65 or older” from a birthday answer needs an explicit derivation and evaluation date. It differs from selecting “65 or older” on an age-group instrument. The model must preserve that distinction, source identity, and provenance. Gender and location answers similarly describe recorded qualifications rather than verified or permanent traits.

[Population Analysis](../Population%20Analysis.md) implements one answer-defined predicate at a shared cutoff and an eligible intersection denominator. Arbitrary predicate expressions, birthday-derived ages, and generalized temporal qualification are not implemented. [Response History](../Response%20History.md) owns the implemented clocks.

## Proposed contracts

Keep instrument/option identity separate from a curated answer proposition and its language-specific renderings. Preserve the exact question's scope, polarity, and response meanings. A canonical sentence organizes a proposition within that definition; it does not establish equivalence between differently worded instruments. Proposed relationships between propositions can be curated and revised without pooling their observations.

A structured result should reference its target proposition, population predicate, evidence selection, cutoff or interval, method, numerator, denominator, and any suppression or missingness. Distinguish the time about which a statement speaks from the time evidence was recorded or published. Multiple-selection shares need not sum to one; ordered labels do not imply equal numeric distances.

Sentence definitions should be validated with the instrument and versioned when meaning changes. Generated suggestions may assist authors, but must not silently define meaning or rewrite historical observations. Presentation edits that preserve meaning should remain distinct from semantic revisions. A semantic link alone does not authorize combining data from separate sources.

## Existing foundation and next slice

[Answer Discovery](../Answer%20Discovery.md) already gives each option a readable address, and [Question Instruments](../Question%20Instruments.md) preserves stable option identities. The summary renderer still uses generic “selected [label]” phrasing; there is no stored answer-proposition or sentence contract. Routes and summaries therefore cover discovery, not this semantic model.

A useful implementation slice would define and test propositions for one frequency instrument, including all its options, before extending to other formats. Verify sentence rendering for overall and answer-defined populations, missing and suppressed results, zero denominators, historical scope, and instrument revisions. Reuse the same structured result for visible content, answer addresses, metadata, and a future API. Research terminology separately rather than choosing a permanent name before the definitions are sound.
