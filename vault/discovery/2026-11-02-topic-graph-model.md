---
type: proposal
date: 2026-11-02
status: open
---

# Topic graph model proposal

This proposal addresses organization without collapsing measurement instruments or imposing a mandatory taxonomy. As of November 2, 2026, Roughly persists one `Question.category` string and derives the browsing topics from it. That is an interim implementation, not a graph. The proposal below is not implemented.

## Four separate layers

| Layer | Identity and meaning | Constraint |
| --- | --- | --- |
| Topic | A stable concept identity with names, aliases, and a description | A name alone does not establish concept identity |
| Question instrument | The exact prompt/version, options, language, and relevant presentation context | Preserve its identity with each response |
| Response | A participant's answer to that instrument, with time and lifecycle | Never rewrite it because organization changes |
| Analysis | A defined population predicate, eligible observations, cutoff, and method | Pooling or inference needs justification |

A concept representing the target being investigated may eventually group instrument versions. It is not necessarily the same entity as a broad navigation topic. Avoid making “coffee” simultaneously mean a subject area and a precise operational question about coffee preference.

## Relational projections of a graph

Start with explicit tables, not a polymorphic “everything is a node” store:

- `topics`: stable UUID, display name, stable slug, definition, lifecycle state, and definition revision.
- `question_topics`: stable relationship UUID, instrument/question UUID, topic UUID, assertion provenance, lifecycle state, and relevant definition reference.
- `topic_relationships`: stable relationship UUID, source topic, target topic, a controlled relation type, provenance, lifecycle state, and a rationale/evidence reference when applicable.

A question can have many membership links. A topic can have many neighbors and, where a relation's contract permits it, several broader concepts. There is no universal `parent_id` and no requirement that the whole graph be a tree or DAG.

Begin with an actual, defined relation such as symmetric `related_to`. Add narrower types only when there is a use case and a precise contract. A strict containment relation has different cycle and transitivity requirements from a loose topical association. An eventually consistent read-side check cannot promise global cycle prevention; that requires a suitable serialization boundary if it becomes a real invariant.

Keep instrument-to-instrument relationships separate. “Alternate wording,” “translation,” and “equivalent measurement” are different assertions. Do not automatically pool their counts or discard exact prompts.

## Event-sourced curation

Provide commands for creating topics, linking/unlinking questions, and relating/unrelating topics. A schema without an exercised write path is insufficient.

A relationship can own a stream keyed deterministically by its type and endpoints. Normalize endpoint order for symmetric types; preserve order for directed ones. Concurrent duplicate writes then reach the same aggregate. Domain validation handles self-links, relation semantics, and lifecycle transitions; projections enforce their own referential integrity as an additional boundary.

Record enough context on events or immutable references: source kind, authenticated actor or explicit automated/development origin, relevant timestamps, relation type, and evidence or proposal identity. Trusted command context establishes provenance; it must not be copied unquestioningly from a public form. Use replay-safe payload values and test serialized events.

Topic definitions can evolve. Preserve revisions where an earlier classification or analysis depends on their meaning. For graph-derived suggestions, record the relevant graph revision and inference context when the suggestion is made; recomputing against a later graph can give a false account of why it was proposed.

AI suggestions should remain proposals until the applicable curation policy accepts them. Acceptances, corrections, and rejections provide distinct information. Do not label a scripted seed edge as human-authored or a statistical association as a semantic fact. No automatic inference or curation policy is selected by this proposal.

## Queries and migration

The existing PostgreSQL stack can query memberships and edges, join answer populations, and expose neighbor/subgraph views. Search, navigation, semantic organization, and population analysis are separate consumers. Direct membership and inherited membership should be distinct query modes; do not silently expand a population because a topic relationship changes.

Keep old events readable. Materialize legacy categories as topics and membership assertions through idempotent commands with explicit import/development provenance, rather than pretending an author made a new classification. Update query modules to read memberships, and then retire the category field as an active write contract. Keep any remaining compatibility behavior explicit.

The first demonstrable slice should include topic/link commands, projections, serialized-event tests, duplicate/retraction tests, overlapping seed memberships, and browsing a question through more than one topic. Manual relationship creation must work before adding inferred graph growth. A graph visualization or a new database is not a prerequisite.

## Related

- [Topic Graph](../Topic%20Graph.md): enduring distinctions.
- [Question meaning and intersections](2026-11-02-question-meaning-and-intersections.md): exact instruments and eligible denominators.
- [Claims and Evidence](../Claims%20and%20Evidence.md): what an assertion establishes.
- [Development Fixtures](../Development%20Fixtures.md): reproducible local scenarios.
