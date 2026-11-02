---
type: note
---

# Project Workflow

Roughly's proposed workflow keeps knowledge and work records in Git, with a forge providing contribution and review surfaces. Stable repository IDs and relative links preserve meaning across a hosting change. [The workflow decision proposal](decisions/DR-001-portable-project-knowledge.md) records the tradeoffs and review status.

## Work ownership

A small work record in `vault/delivery/` owns its scope, completion criteria, status, and durable outcome. Use sequential IDs such as `R-001`; no epic/story/task hierarchy is required. GitHub issues can collect public discussion and point to that record. The repository record lists the external issue or PR as an optional reference, not its identity.

Do not maintain the same detailed plan in both places. Reconcile material conclusions and scope changes through a PR; do not assume comments automatically update committed documentation. An issue can be open while work is under review, but it is not proof of implementation or deployment.

## Change flow

1. Search existing work and knowledge. Small fixes can use a PR alone; significant work needs a focused record stating the problem and outcome.
2. Use a feature branch. Start domain behavior with a failing test, implement, and run the appropriate checks.
3. Open a draft PR while implementation or review is incomplete. Link the repository work ID and any external issue; explain behavior, evidence, and remaining limits.
4. Review the diff and CI results, resolve material findings, and use a squash merge. Update the work record as part of the reviewed change. Completion and deployment are separate observations.
5. Reconcile external issue status after merge. Promote reusable findings into [atomic knowledge notes](_meta/Documentation%20Guidelines.md), and significant choices into decision records.

`mix precommit` and `mix assets.build` are the application gates. The vault link check protects document connectivity; editorial judgment protects meaning.

## Portability and audience

The root README starts contributors, topic maps navigate knowledge, and [Project Status](../PROJECT_STATUS.md) summarizes dated implementation state by linking to work records. A separate Wiki or board is optional and should not own exclusive project knowledge. Git history records changes; work records preserve enough outcomes and links to remain understandable without forge discussions.

Code and documents can move with Git. Hosting-specific discussions, attachments, CI settings, and review history need deliberate export if their loss would matter; links alone are not a migration backup. Avoid a synchronization service until there is a demonstrated coordination need.

See [Public and Private Knowledge](Public%20and%20Private%20Knowledge.md) for audience boundaries and [System Architecture](System%20Architecture.md) for engineering context.
