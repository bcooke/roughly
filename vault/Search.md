---
type: note
---

# Search

Search helps people discover questions through prompt wording, answer labels, and topic names. The suggestion panel and full results page share the same public retrieval contract. Results open the exact [Question Instrument](Question%20Instruments.md) through its [Question Link](Question%20Links.md); similarity does not establish equivalent meaning or justify pooling responses.

## Retrieval and ownership

[Read Models](Read%20Models.md) supply an indexed document assembled from public instrument fields. English stemming, literal fragments, and word-level trigram similarity tolerate word variants and spelling mistakes. Every substantive search term must match; a small set of introductory question phrases is removed. Ranking combines exact prompt and phrase matches with full-text rank and word similarity. This is lexical retrieval, without a semantic model or generated answers.

The query contract is owned by [Search](../lib/roughly/search.ex), with SQL in [Matches](../lib/roughly/search/queries/matches.ex). Only aggregate response previews are attached. Principal identities and individual response histories are excluded from this index and its output.

## Interaction contract

The homepage offers inline suggestions; the shared header opens a modal with Command/Ctrl K. Arrow keys select a suggestion, Enter opens a selection or the full results page, and Escape dismisses suggestions. Loading, empty, and failed requests have distinct states. Superseded requests cannot replace the active query. Recent searches are saved only after navigation, stored in browser session storage, limited to six entries, and clearable. They produce no domain events.

Full results retain the query, topic, format, and page in the URL. Native GET forms provide a server-rendered route when the enhanced entry point is unavailable. Counts describe matching questions or recorded responses, not a representative population estimate; see [Polling Methodology](Polling%20Methodology.md).

`GET /api/search/suggest` is a bounded public presentation endpoint. It is not the versioned research API or dataset export proposed in the [open data idea](discovery/ideas/open-api-and-dataset-releases.md).

## Dependencies

PostgreSQL supplies [full-text controls](https://www.postgresql.org/docs/17/textsearch-controls.html) and [pg_trgm](https://www.postgresql.org/docs/17/pgtrgm.html). The read-model migration enables the extension and adds GIN indexes; no external search service or frontend component dependency is required.
