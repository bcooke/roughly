---
type: decision
id: DR-001
date: 2026-11-02
status: proposed
work: R-001
---

# Keep project knowledge and work records portable

## Context

Roughly needs an understandable public contribution process and a connected body of product and engineering knowledge. On November 2, 2026, repository cleanup had removed a large copied workflow framework. The maintainer requested atomic evergreen notes, rich links, appropriate temporal records, and visible review without company-scale administration or unnecessary dependence on GitHub.

## Proposal

Keep evergreen concepts at the vault root, navigation in topic maps, dated investigation in discovery, significant choices in decision records, and small work records in delivery. Use repository-owned work IDs independent of a forge's issue numbers. Make `PROJECT_STATUS.md` a dated summary rather than a duplicate ledger.

Use GitHub issues for discovery and discussion and PRs for review and checks. Each issue points to its work record; useful conclusions return to committed documents through a PR. Do not create a separate Wiki or Projects board without a concrete need. Keep raw personal and private source material outside the public repository.

## Alternatives and tradeoffs

GitHub-only work tracking is familiar to contributors but leaves authoritative scope, acceptance criteria, and outcomes outside Git. A repo-only workflow is portable but offers a less familiar discussion and intake experience. Full bidirectional synchronization adds machinery and conflict rules that a small project does not need.

This proposal combines a small repository record with an external discussion surface. It requires deliberate reconciliation when scope or decisions change. Avoid copying detailed plans into both systems.

## Consequences and review status

The arrangement is proposed for maintainer review in the foundation PR. It does not prescribe the workflow permanently. Hosting-specific review history, discussions, attachments, and settings still require export during a migration; committed links do not eliminate that dependency. Preserve essential rationale in the repository as work progresses.

[Project Workflow](../Project%20Workflow.md) is the working implementation, [Documentation Guidelines](../_meta/Documentation%20Guidelines.md) defines writing forms, and [Public and Private Knowledge](../Public%20and%20Private%20Knowledge.md) defines the audience boundary. Review them together under [R-001](../delivery/R-001-foundation.md).
