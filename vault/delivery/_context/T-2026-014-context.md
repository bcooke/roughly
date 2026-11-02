---
type: context
task: T-2026-014
date: 2026-11-02
---

# Foundation refresh context

## Starting point

Inspection on November 2, 2026 found an early Commanded domain with aggregate tests and migrations, but a generated homepage, unsupervised projectors, and a large copied tool-specific workflow. The foundation branch also included previously unpushed domain refactoring and migrations.

## Findings that affect implementation

A runtime check exposed a gap absent from pure aggregate tests: JSON deserialization supplies question type as a string, while Ecto's enum field requires casting before insertion. The question projector now casts that boundary. A regression test covers serialized creation, close transitions, and duplicate delivery; the runtime create/close check then passed.

The visible browser uses an explicit synthetic catalog. Its counts do not represent event-sourced responses or a real sample. No guessing exercise or response collection is enabled. Participation and identity policy remain an investigation, not an accidental consequence of an interface choice.

## Repository choices

A fresh scaffold reduced the configuration audit, with selected domain code, tests, event names, and migrations retained. Vue SSR and unnecessary UI dependencies were removed for the preview's small browser interaction.

Knowledge uses atomic concept notes and topic maps. Dated investigation and decisions retain uncertainty and rationale. A small task/context pair preserves relevant implementation history without requiring mirrored issues, a detailed hierarchy, or a separate formal review ceremony. See [the process decision](../../decisions/DR-001-portable-project-knowledge.md).

## Evidence and limits

[The task](../tasks/T-2026-014-foundation-refresh.md) and [PR #11](https://github.com/bcooke/roughly/pull/11) identify validation. The working domain needs explicit command entry points, cross-domain validation, concurrency policy, and privacy/retention behavior before real collection; see [the domain flow proposal](../../discovery/validated-domain-flow.md). No production deployment was performed by this task.
