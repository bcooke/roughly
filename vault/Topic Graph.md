---
type: note
---

# Topic Graph

A topic names a concept used to organize questions. A question can concern several topics, and topics can relate through explicit edges. A single category, a tag string, or a mandatory parent tree cannot represent all those relationships.

## Distinct relationships

A question being about coffee differs from coffee being related to sleep. Both differ from two prompts investigating the same target, or two answers exhibiting a statistical association. Those relations need distinct meanings and evidence; sharing a graph view does not make them interchangeable.

Membership belongs on question–topic links rather than in one category field. Stable topic identities let names and aliases support discovery without making a label the identity. A browsing collection can be a view of the graph, not its underlying constraint.

The [question-meaning investigation](discovery/2026-11-02-question-meaning-and-intersections.md) explains why topical connection is not measurement equivalence. Neither a shared topic nor an inferred similarity score authorizes combining response counts.

## Relationships have authority and history

Authored links, imported classifications, model proposals, and statistical derivations have different provenance. Preserve their source and status. A proposed link is not automatically an accepted classification. Removing or revising a relationship should preserve the assertion's history without rewriting responses.

Relevance, confidence, and statistical association are also distinct. A numeric weight needs a defined quantity and interpretation; omit it rather than invent a default that looks measured.

[Domain Writes](Domain%20Writes.md) provides command/event authority for curation. [Read Models](Read%20Models.md) can project graph nodes and links into relational tables and derive graph-shaped views. A graph model does not require a graph database, and event sourcing does not make inferred semantics true.

[The topic graph proposal](discovery/2026-11-02-topic-graph-model.md) describes entities, migration, and implementation boundaries. [Project Status](../PROJECT_STATUS.md) distinguishes that proposal from the single-category implementation.
