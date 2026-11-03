---
type: research
date: 2026-11-02
status: open
---

# Question meaning and population intersections

This proposal separates a concept people want to investigate from the exact instrument used to collect evidence. It is not an implemented canonicalization or cohort-analysis model.

## Conditional proportions

Let A be respondents selecting a qualifying answer to one question, B respondents selecting an answer of interest to another, and E respondents with an eligible answer to that second question. The observed conditional share is `|A ∩ B| / |A ∩ E|`, provided the denominator is nonzero. For example, among women who answered a flavor question, what share selected chocolate?

Missing responses must not be treated as a negative answer. The result describes that eligible intersection; it does not automatically estimate all women or eliminate self-selection. “Prefer not to answer,” retracted responses, eligibility, and weighting need explicit analysis rules. Requiring multiple answers can itself select a different sample.

Time is another dimension. “People whose latest answer qualifies” differs from “people who qualified when they answered the second question.” An analysis needs its answer-selection policy, cutoff, and population definition to be reproducible.

## Preserve the measurement instrument

A concept such as coffee preference can have several prompts, languages, option sets, and presentation orders. Similar wording does not establish equivalent measurement. [Pew's survey-question guidance](https://www.pewresearch.org/writing-survey-questions/) documents wording and order effects; it does not supply an automatic equivalence test.

Use the question/instrument version as the identity attached to a response. Preserve or immutably reference exact wording, options, relevant presentation order, language, and collection context. A spelling correction, changed option, or alternate phrasing must not silently reinterpret old responses.

The existing question UUID can anchor an exact instrument; a separate concept can organize related instruments. The choice to pool results needs a stated method and evidence. A discovery grouping is not permission to pool.

## Model relationships as revisable claims

A graph can represent “related to,” “investigates the same concept,” “translation of,” or a proposed equivalence. Record the relationship's provenance and grounds. Curation can change or withdraw such claims without rewriting the original responses. Avoid an irreversible merge based only on synonym similarity or a model-generated score.

[Historical relationship sketches](../archive/2026-02-proposals/Question%20Relationships.md) should be read cautiously: examples equating liking coffee with drinking coffee are not evidence of semantic or measurement equivalence.

## Event sourcing and read models

A useful domain event records a coherent fact with sufficient context. Breaking an answer into smaller fragments is not automatically more faithful; the relationships that give it meaning must survive. A response event can reference an immutable question/instrument event rather than duplicate its full payload.

[Domain Writes](../Domain%20Writes.md) preserves authority and revision history. [Read Models](../Read%20Models.md) can provide relational joins, cross-tabs, and graph-shaped views over that history. A conceptual graph does not require a graph database. A derived aggregate is also not evidence stronger than its source responses.

[Development Fixtures](../Development%20Fixtures.md) reuse participant identities across questions to support testing intersections. Their invented distributions do not demonstrate real correlations or validate cohort methodology. [Claims and Evidence](../Claims%20and%20Evidence.md) and [the participation investigation](2026-11-02-participation-design.md) supply related constraints.

## Proposal and subsequent foundation work

Build a complete question exploration path before broadening every subsystem. Establish immutable instrument identity, stable option identity, and validated answer semantics for a small set of formats; discard obsolete development-only event shapes while the project remains unreleased. The subsequent [domain foundation](../delivery/tasks/T-2026-017-domain-foundation.md) implements exact instrument identities, stable option IDs, four selection formats, and collection context. [Population Analysis](../Population%20Analysis.md) subsequently implements a single answer-defined predicate and cutoff policy; generalized predicate composition remains open. The older string-option vote model has been removed.

Exercise the model with one population predicate defined by an answer to another question, using a stated answer-selection cutoff and eligible denominator. Return aggregate results only, distinguish missing answers from nonqualifying answers, and test retractions and empty intersections. Use repeatable fixture scenarios with known overlaps and contrasting distributions rather than assuming independently generated answers provide useful comparison examples.

Expose this as one working question page with an overall view, a population comparison, and appropriate alternative result presentations. Add a small multi-question exploration using the same analysis queries once the first comparison works. Keep chart presentation separate from question formats and analysis definitions, so later API consumers can reuse the same definitions.

This is a recommended sequence, not an accepted schema or an implemented capability. The [visualization idea](ideas/data-led-visualizations.md) captures the broader direction; [collection variants](ideas/collection-context-variants.md) separates response formats from answering modes. Topic graph implementation can follow with a concrete discovery use case rather than requiring a complete graph system before this first exploration works.
