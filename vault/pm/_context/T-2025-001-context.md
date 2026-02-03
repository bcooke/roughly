# Context: T-2025-001 Tailor Balustrade for Roughly

**Task**: [[T-2025-001-tailor-balustrade-for-roughly]]
**Created**: 2025-02-02
**Status**: In Progress

## Overview

Transform the Balustrade meta-framework template into the foundation for "The Roughly Project" (roughly.io) - a Wikipedia-like encyclopedia for quantifiable human data.

## Key Decisions

### Framework Documentation
**Decision**: Keep and rework CUSTOMIZATION.md, HOW-IT-WORKS.md, SUMMARY.md
**Rationale**: These explain how the meta-framework works, which is valuable internal documentation
**Alternative considered**: Delete entirely - rejected because meta-framework context is useful

### Phoenix Setup
**Decision**: Documentation only this session
**Rationale**: Focus on vision/architecture docs first; Phoenix setup is a separate task
**Alternative considered**: Full Phoenix setup now - deferred to T-2026-001

### Example Content
**Decision**: Delete all Todo App examples, start fresh on data model
**Rationale**: Roughly has unique data model requirements; legacy Quibble code not needed as reference

### Logo Concept
**Decision**: Keep ≈ (approximately equal) symbol with "ROUGHLY" / "APPROXIMATE.LY" branding
**Rationale**: Perfectly captures the essence - approximate truth, polling data as best estimate

## Reference Materials

### Original Mockup
User provided wireframe showing:
- Category navigation (Home, World, US, Business, Technology, Entertainment, Sports, Science)
- Stat ticker with "Vote!" CTAs
- Search bar (Google-style)
- Question page with vote buttons, percentages, pie chart
- Breakdowns tabs (Men, Women, US, World)
- Similar Questions section

### Logo Concept
User provided ≈ symbol design with "APPROXIMATE.LY" text

## Implementation Notes

### Files Created
- `vault/product/Product Vision.md` - Full project vision
- `vault/product/Glossary.md` - Key terminology
- `vault/product/Design Philosophy.md` - 538-inspired design system
- `vault/architecture/System Architecture.md` - Phoenix/Commanded architecture
- `vault/architecture/Data Model.md` - Questions, responses, demographics schema
- `vault/features/Question Search.md` - Search functionality
- `vault/features/Demographic Slicing.md` - Population filtering
- `vault/features/Data Contribution.md` - Voting system
- `vault/pm/tasks/T-2026-001-setup-phoenix-project.md` - Next task

### Files Modified
- `README.md` - Complete rewrite for Roughly
- `PROJECT_STATUS.md` - Updated for Roughly project
- `.devcontainer/devcontainer.json` - Configured for Elixir
- `CUSTOMIZATION.md` - Rebranded, kept meta-framework docs
- `HOW-IT-WORKS.md` - Rebranded, kept meta-framework docs
- `SUMMARY.md` - Updated file manifest

### Files Deleted
- `example-app/` directory
- All Todo App PM artifacts (epic, stories, tasks, bug, contexts)
- `vault/features/Todo Management.md`

## Open Questions

1. Should we add more demographic categories to the data model?
2. What charting library for LiveView?
3. Identity verification approach for voters?

## Progress Timeline

- 2025-02-02: Task started, exploration complete, implementation in progress
