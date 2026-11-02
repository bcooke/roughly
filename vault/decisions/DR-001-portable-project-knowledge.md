---
type: decision
id: DR-001
date: 2026-11-02
status: accepted
---

# Keep knowledge portable and contribution process lightweight

## Context

On November 2, 2026, Roughly needed a public contribution baseline while its product was taking shape. The maintainer wanted connected evergreen notes, dated investigation, and decision records, without slowing development through task bookkeeping or becoming unnecessarily dependent on a hosting platform.

## Decision

Use one public repository containing the application and its knowledge vault. Organize durable concepts as atomic notes with topic maps; use discovery for provisional research and decisions for consequential choices. Keep the README and dated project status as entry points.

Use focused PRs, relevant checks, and a brief diff review before squash merging. Ready PRs are the default; drafts are for unfinished work. Use lightweight T/BUG/IMP records for meaningful work and context files when useful findings need preservation. Do not require an issue, a board, a detailed hierarchy, or a mirrored tracker for each change. Issues are available when discussion or coordination helps. A separate Wiki is unnecessary when the vault already owns project knowledge.

## Alternatives and rationale

A forge-only knowledge base would put essential reasoning outside Git. A small task and optional context file preserve implementation history; mirrored trackers, exhaustive backfilling, and a detailed delivery hierarchy would add maintenance before the project needs that coordination. A mandatory formal review stage would also slow product exploration without evidence that the added ceremony helps at this scale.

Committed notes and ordinary PRs give contributors a visible process while preserving room to move quickly. Stronger controls can be adopted through an explicit change when scale or operational risk warrants them.

## Consequences

Useful findings from external discussions need to return to committed notes. Git alone does not preserve hosting-specific comments, attachments, or settings; migration can require export. The chosen lightweight process does not justify merging known failures or skipping relevant validation.

[Project Workflow](../Project%20Workflow.md) implements the process, [Documentation Guidelines](../_meta/Documentation%20Guidelines.md) defines the note forms, and [Public and Private Knowledge](../Public%20and%20Private%20Knowledge.md) defines the publication boundary.
