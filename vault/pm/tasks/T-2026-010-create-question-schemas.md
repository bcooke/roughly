---
type: task
id: T-2026-010
story:
epic:
status: backlog
priority: p1
created: 2026-02-03
updated: 2026-02-03
---

# Task: Create Initial Ecto Schemas for Questions Domain

## Task Details
**Task ID**: T-2026-010
**Status**: Backlog
**Priority**: P1
**Branch**: feat/T-2026-010-create-question-schemas
**Created**: 2026-02-03

## Description
Create the initial Ecto schemas for the Questions domain, including migrations. This is the core data model for Roughly.

## Checklist
- [ ] Create Question schema with migrations
- [ ] Create ResponseOption schema (embedded or separate)
- [ ] Create Vote schema with migrations
- [ ] Create QuestionSummary read model
- [ ] Create DemographicSlice read model
- [ ] Write schema tests
- [ ] Create seed data for development

## Schemas to Create

### Question
```elixir
schema "questions" do
  field :text, :string
  field :slug, :string
  field :question_type, Ecto.Enum, values: [:binary, :multiple_choice, :scaled]
  field :status, Ecto.Enum, values: [:draft, :active, :closed, :moderated]
  field :category, :string
  field :methodology, :string

  embeds_many :answer_options, AnswerOption

  timestamps(type: :utc_datetime)
end
```

### Vote
```elixir
schema "votes" do
  field :answer_id, :string
  field :demographic_snapshot, :map
  field :voted_at, :utc_datetime

  belongs_to :question, Question, type: :binary_id
  belongs_to :user, User, type: :binary_id

  timestamps(type: :utc_datetime)
end
```

### QuestionSummary (Read Model)
```elixir
schema "question_summaries" do
  field :total_votes, :integer
  field :answer_counts, :map
  field :answer_percentages, :map
  field :last_vote_at, :utc_datetime

  belongs_to :question, Question, type: :binary_id

  timestamps(type: :utc_datetime)
end
```

## Dependencies
### Blocked By
- T-2026-007 (need relationship model design)
- T-2026-009 (need CQRS folder structure)

### Blocks
- Feature implementation

## Notes
- Use UUIDs for all primary keys
- Snapshot demographics with each vote
- Consider full-text search from day one
