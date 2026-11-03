---
type: note
---

# Answer Discovery

A question page should give readers an inspectable answer: the exact question, answer labels, counts, denominator, and counting method. These facts also belong in initial server-rendered HTML so discovery does not depend on executing a chart. [Result Presentation](Result%20Presentation.md) owns the views; [Claims and Evidence](Claims%20and%20Evidence.md) limits their interpretation.

## Addresses and visible answers

The question has one canonical route. Each immutable option also has a readable `/questions/:slug/answers/:answer-slug` route, allocated deterministically within that instrument. Normalization collisions gain numbered suffixes. The focused page reports that option's share and links to the full distribution; it does not declare one poll choice to be the objectively correct answer.

Summaries use recorded respondents and explicit counts, rather than silently turning an open response set into a worldwide estimate. Structured Dataset/PropertyValue microdata describes the same visible counts and shares. No confidence interval, verified identity, representative sampling, or publication license is invented. [Question Links](Question%20Links.md) distinguishes these live answers from versioned citations.

## Crawling contract

Initial HTML supplies descriptions, canonical URLs, social metadata, and robots directives. The bundled metadata hook updates these on LiveView navigation. Presentation-only variants canonicalize to the question or focused answer; population, cutoff, and comparison variations are not independently indexable. Invalid question/option paths return HTTP 404.

A sitemap index lists bounded shards of question and answer routes. Indexing is disabled by default. `ROUGHLY_PUBLIC_INDEXING=true` only enables it in production; local fixtures remain noindex and absent from sitemap output. Production source readiness and publication policy must precede enabling discovery of empirical claims.

Google's [AI search guidance](https://developers.google.com/search/docs/appearance/ai-features) emphasizes ordinary SEO foundations, textual content, and structured data consistent with visible information. Its [QAPage guidance](https://developers.google.com/search/docs/appearance/structured-data/qapage) concerns question-and-answer contributions; Roughly's fixed poll choices and computed distribution are not modeled as forum answers. [Schema.org Dataset](https://schema.org/Dataset) supplies descriptive vocabulary without promising a search rich result. [Canonical URL guidance](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls) informs the distinction between an address and presentation variations.

Search indexing or inclusion in an answer engine is not guaranteed. This is a discoverable content foundation, not an assertion that special markup creates ranking or validates the underlying data. [Results Exposure](Results%20Exposure.md) still applies: a search snippet can expose a distribution before a reader participates. Collection flows need their own exposure policy.

[The answer-statement proposal](discovery/2026-11-03-answer-statements.md) separates option labels from full propositions and scoped statistical statements. The generic summary renderer does not yet implement curated sentence definitions.
