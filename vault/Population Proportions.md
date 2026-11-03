---
type: note
---

# Population Proportions

A population proportion is the share of a defined population satisfying a specified condition. For human questions, a definition must identify who counts, what condition is being considered, and the relevant time. This gives [Quantifiable Human Facts](Quantifiable%20Human%20Facts.md) a mathematical form without implying that every defined quantity is observable.

## Target quantity

For a finite nonempty population P at reference time t, and a condition C with a determinate true or false value for every member under the chosen definition:

`p(P, C, t) = |{x ∈ P(t) : C(x, t)}| / |P(t)|`

The percentage is `100 × p`. A lifetime condition can mean “had experienced X by t”; an interval condition must specify the interval. Population membership can have its own time policy. Counting people differs from counting visits, transactions, or opportunities, so the unit of analysis belongs in the definition. A population with no members yields an undefined proportion, not zero.

This finite-population construction is a working framework for Roughly, not a definition of all empirical knowledge or a new theorem. It assumes meaningful membership and condition rules. Ambiguous terms, vague predicates, disputed classifications, and inaccessible events require further work; the notation does not eliminate them. A changing value need not be indeterminate, and a determinate value need not be knowable from surviving evidence.

## A space of targets

For chosen families of population definitions, conditions, and temporal scopes, consider admissible tuples `(P, C, T)`. Each tuple defines a target when its membership, unit, condition, and time rules are sufficiently specified. Some tuples overlap or describe the same quantity; linguistic similarity alone does not establish that equivalence. This gives a space to organize without treating every combination of words as a meaningful or measurable fact.

The admissible target space, the quantities observable through a particular method, and the quantities supported by available evidence are different sets. Their boundaries depend on definitions, access, and assumptions; a catalog cannot certify universal knowability merely by admitting a question.

## From a condition to a statement

“Has entered salt water” is a condition or predicate. Applying it to a person with a cutoff forms a proposition that can be true or false. “The share of adults who had entered salt water by date t” specifies a target quantity. “That share is p” makes a quantitative claim about it. A question asks for information; an answer option can express a condition in the question's context.

“Sometimes” alone lacks its activity, reference period, and interpretation. A curated sentence can make that context explicit, but must not invent precision absent from the instrument. [Question Instruments](Question%20Instruments.md) preserves wording and meanings; [the answer-statement proposal](discovery/2026-11-03-answer-statements.md) holds the unimplemented sentence contract.

## Observed result and estimate

A result calculated over eligible recorded respondents describes those records. Its numerator counts qualifying recorded answers and its denominator counts eligible respondents under a stated selection method. A target-population estimate uses evidence and additional assumptions to estimate a target quantity. An exact calculation on records can still be a poor estimate of a wider population. [Claims and Evidence](Claims%20and%20Evidence.md) owns that distinction.

A share of people selecting an option is not the probability that a claim is true, a forecast that an event will happen, or proof that an option is preferable. Multiple-selection conditions can overlap; their shares need not sum to one. Missing evidence is not a negative answer. Withheld results and empty denominators must not render as zero.

## What evidence can distinguish

[Identification analysis](https://arxiv.org/abs/2204.11318) separates what an observable distribution and assumptions can determine from finite-sample estimation. A working finite-population analogue asks which complete populations remain compatible with the evidence and declared assumptions. If compatible completions imply different proportions, the evidence has not singled out a value. This is conditional on the evidence model, not a proof of absolute unknowability.

For an original worked example, suppose a known population has 100 people. The condition is observed without error for 40: 20 satisfy it and 20 do not. With no assumptions about the remaining 60, the target share can range from 20% to 80%. The observed share is 50% of the 40, but neither it nor a narrower interval follows for the full population without more evidence or assumptions. These logical bounds are not a sampling confidence interval. Roughly does not implement this bounds analysis.

## Conditional populations

An additional membership condition A defines a subpopulation. In complete target data, the proportion is `|{x ∈ P : A(x) ∧ C(x)}| / |{x ∈ P : A(x)}|`, when its denominator is nonzero, with temporal policies retained. Recorded answers to another instrument provide evidence of qualification; they do not automatically establish actual membership in a target group.

[Population Analysis](Population%20Analysis.md) implements observed intersections with eligible target answers, a shared cutoff, and explicit missingness. Derived age predicates need an evaluation date and a source; an age-group answer and an age derived from a birthday are different observations. Joining marginal percentages from separate sources cannot reconstruct the required individual overlap.

## Vocabulary and provenance

“Population,” “proportion,” “predicate,” “proposition,” and “estimand” have established uses. Roughly uses **target proportion** for the desired quantity, **observed proportion** for an evidence-set calculation, and **result statement** for its contextual prose rendering. These working definitions should be evaluated against examples, rather than presented as a newly discovered epistemology.

[The knowledge and measurement review](discovery/2026-11-03-knowledge-and-measurement.md) records primary sources, scope, and the grounds for this synthesis. The public guide gives a shorter explanation; code implements only the contracts linked from the owning notes.
