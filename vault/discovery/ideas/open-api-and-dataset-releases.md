---
type: idea
status: exploring
created: 2026-11-02
---

# Open API and dataset releases

## Direction

Make Roughly's public knowledge reusable outside its website. Explore an openly documented read API and downloadable, versioned releases, so researchers, writers, and other applications can inspect and work with the data.

An API serves queries and evolving results. A release provides a reproducible snapshot. They serve different needs and should share definitions, identifiers, and provenance rather than become divergent products.

## Publication contract to define

- Which question instruments, topic relationships, aggregate counts, collection-method descriptions, and analysis definitions are public?
- What does “full dataset” mean? Distinguish the complete public knowledge corpus from identifiable response history and internal operational records.
- How are denominators, missingness, exclusions, source versions, weighting, and collection cutoffs represented?
- Which formats provide practical portability, and what schema/versioning guarantees do consumers need?
- How are corrections, withdrawals, releases, citations, and source-data licensing handled? Code licensing does not itself decide every data source's publication rights.

Public openness does not imply a raw export of private responses or event logs. Aggregate slices and repeated releases can also expose information through combinations or differences. Publication granularity and privacy review need a defined policy; no particular safeguard or microdata access model is selected here.

## Distribution options

Keep formats and release metadata independent of a host. A self-hosted download and a dataset archive can complement each other. [Zenodo's versioning documentation](https://help.zenodo.org/docs/deposit/manage-versions/) is one research starting point for versioned releases and persistent identifiers, not a hosting choice or an instruction to upload data.

No external dataset publication, API endpoint, licensing decision, or public response export is implemented by this idea. Development fixtures remain invented data and must not be released as polling evidence.

## Related

- [Question Links](../../Question%20Links.md): a live page differs from a versioned citation.
- [Claims and Evidence](../../Claims%20and%20Evidence.md).
- [Participant Identity](../../Participant%20Identity.md).
- [Collection Context](../../Collection%20Context.md).
- [Ideas index](README.md).
