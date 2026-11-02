---
type: guidance
---

# Documentation Guidelines

The vault develops connected project knowledge through focused notes. Its structure should let a reader load the smallest useful explanation, then follow relationships as needed.

## Search before writing

Search the vault for the topic, synonyms, and related concepts. Extend an existing note when it already owns the idea. Split a note when distinct ideas need independent explanations and links, not simply because it is long. Link the resulting notes in both relevant directions.

Evergreen root notes have one clear subject, minimal `type: note` frontmatter, at least two meaningful links to related concepts, and an inbound link from a topic map. Links should explain an actual relationship rather than meet a quota. Maps in `topics/` navigate; they do not duplicate explanations or maintain copies of data tables. Structural metadata and links provide organization without a tag taxonomy.

## Choose the form that matches the claim

| Form | Owns | Avoid |
| --- | --- | --- |
| Evergreen root note | A concept, mechanism, principle, or documented contract | Progress logs, promises, and unqualified snapshots of changing arrangements |
| Topic map | Short entry points and related-note links | Repeating the content it points to |
| Dated discovery record | Research questions, scoped observations, sources, alternatives, uncertainty | Turning one observation into a permanent conclusion |
| Decision record | Context, choice or proposal, rationale, alternatives, consequences, status | Describing a proposal as ratified or equating a decision with implementation |
| Delivery record | Work identity, scope, outcome, status, evidence, external references | Duplicating the entire knowledge base or forge discussion |
| Project status | A dated summary with links to work and capabilities | Becoming a second detailed work ledger |
| Archive | Historical material, clearly marked and excluded from active guidance | Presenting obsolete designs as the running system |

## Keep evergreen claims durable

Removing “currently” does not make a statement evergreen. Ask whether the sentence explains a mechanism or merely copies an arrangement that changes elsewhere. Prefer a source-of-authority link over repeating module inventories, exact versions, counts of enforcement sites, or a hand-maintained roadmap.

Useful implementation facts still need an owner. Put operational commands in the README or their configuration, date observations in work/research records, and point from conceptual notes to that authority. Update a contract note when its implemented contract changes.

Dates are appropriate in historical research and decisions. Separate what was observed, what was inferred, what was proposed, and what was demonstrated. An unresolved idea can inform a concept note without being described as shipped or proven. Do not let careful-sounding prose manufacture certainty.

## Decisions and evidence

Record significant technical choices as ADRs and broader product/process choices as DRs in `decisions/`. Include a date and status (`proposed`, `accepted`, `superseded`, or `rejected`). Reference the work and knowledge they affect. When a choice changes, preserve the historical rationale and link its replacement; update active guidance separately.

Use sources for substantive external claims. Keep relevant evidence and its limitations, not a transcript of every discarded hypothesis. Shared reasoning must be understandable without private files or access to another project's repository. Attribution belongs in sources, Git history, or necessary record metadata; evergreen prose speaks for the project.

## Links and checks

Use relative Markdown links with URL-encoded spaces. They are readable on GitHub and supported as internal links by [Obsidian](https://obsidian.md/help/links). Keep filenames stable and repair inbound links when moving notes. Do not use Obsidian-only plugins for essential navigation.

`mix docs.check` checks active relative Markdown targets, note frontmatter, related-note links, and topic-map coverage. It deliberately does not ban temporal words or judge scientific claims. Templates and archived proposals are excluded from structural checks; editorial review is still required.

[Project Workflow](../Project%20Workflow.md) defines work and review. [Public and Private Knowledge](../Public%20and%20Private%20Knowledge.md) defines audience boundaries. Use the [note template](templates/Note.md) and [decision template](templates/Decision%20Record.md) when they help; remove empty scaffolding.
