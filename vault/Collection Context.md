---
type: note
---

# Collection Context

An answer is evidence produced under particular conditions. The exact question instrument, its presentation, the route into participation, and relevant information available to a participant affect how that evidence can be interpreted. A collection system should preserve the context it needs to explain and investigate its results.

## Instrument, presentation, and observation

The instrument defines wording, language, answer semantics, instructions, and any stimulus that is part of the question. A yes/no prompt, multiple-choice list, ranking, scale, and open response are different instruments or formats; they are not automatically interchangeable measurements.

Presentation records what was actually offered: rendered option order, image or illustration version, relevant preceding information, layout/format variant, and any random assignment. Preserve immutable references to the actual material. A mutable image URL or a generative prompt alone cannot establish which image was displayed.

Observed context can describe an entry route, results displayed before answering, collection mode, and the participation/identity assurance in force. A page-render event does not establish attention or comprehension; absence of a recorded results view does not establish no prior exposure. Distinguish an observation, a participant report, a derived inference, and an unknown value.

[AAPOR's disclosure standards](https://aapor.org/standards-and-ethics/disclosure-standards/) call for the measurement tool's wording and presentation and relevant preceding context. They support preserving this information, not a claim that Roughly's methods have been validated.

## Versioned context, not indiscriminate telemetry

A response can reference an immutable instrument version and a collection-context record. Share common configuration across a study or collection run and record per-response differences where they actually vary. [Domain Writes](Domain%20Writes.md) can preserve those facts or references without duplicating entire screens in every response event.

Collect context for a named analytical or integrity purpose, with appropriate access and retention. [Participant Identity](Participant%20Identity.md) distinguishes assurance from public identity and operator access. Recording an assurance category is not a reason to place identity documents, raw identifiers, or unnecessary browsing history in immutable events.

## Analysis does not erase the collection design

Context can support separate estimates, comparisons, sensitivity analyses, or a designed experiment. It does not make collection methods comparable by itself, correct missing population coverage, establish truthful answers, or remove unmeasured confounding. Pooling data needs an explicit method and eligible denominator.

[Claims and Evidence](Claims%20and%20Evidence.md) separates observations from target quantities. [Results Exposure](Results%20Exposure.md) addresses prior information. [The context-variant idea](discovery/ideas/collection-context-variants.md) holds unresolved design choices; the [context value](../lib/roughly/participation/context.ex) implements a bounded subset, including per-field provenance and optional reported answer time. [ADR-003](decisions/ADR-003-domain-admission-and-context-boundaries.md) distinguishes that stored context from unimplemented study assignment, repeated-measurement identities, and inference methods.
