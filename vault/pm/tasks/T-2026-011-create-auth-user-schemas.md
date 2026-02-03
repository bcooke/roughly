---
type: task
id: T-2026-011
story:
epic:
status: backlog
priority: p1
created: 2026-02-03
updated: 2026-02-03
---

# Task: Create Auth & User Schemas

## Task Details
**Task ID**: T-2026-011
**Status**: Backlog
**Priority**: P1
**Branch**: feat/T-2026-011-create-auth-user-schemas
**Created**: 2026-02-03

## Description
Create authentication and user schemas for Roughly. Key requirements:
- Accounts required to answer questions (no anonymous voting)
- Individual responses must be private (only aggregate data visible)
- Demographics captured for slicing but not individually attributable

## Checklist
- [ ] Create User schema with migrations
- [ ] Create UserProfile schema (demographics)
- [ ] Set up phx.gen.auth or custom auth
- [ ] Create DemographicSnapshot embedded schema
- [ ] Add privacy-preserving vote association
- [ ] Write schema tests

## Schemas to Create

### User
```elixir
schema "users" do
  field :email, :string
  field :hashed_password, :string
  field :confirmed_at, :utc_datetime

  has_one :profile, UserProfile
  has_many :votes, Vote

  timestamps(type: :utc_datetime)
end
```

### UserProfile
```elixir
schema "user_profiles" do
  # Demographics - used for slicing aggregate data
  field :birth_year, :integer
  field :country, :string
  field :region, :string  # state/province
  field :gender, :string
  field :education_level, :string
  field :income_bracket, :string
  # Add more demographic fields as needed

  belongs_to :user, User, type: :binary_id

  timestamps(type: :utc_datetime)
end
```

### Privacy Model
- Votes are associated with users for:
  - Preventing duplicate votes
  - Showing user their own answers
  - Quality signals (account age, answer patterns)
- Individual vote data is NEVER exposed publicly
- Only aggregate counts by demographic slice are shown
- Consider k-anonymity: only show slices with N+ respondents

## Dependencies
### Blocked By
- T-2026-009 (need CQRS folder structure)

### Blocks
- T-2026-010 (Vote schema needs User reference)

## Notes
- Use UUIDs for all primary keys
- Consider phx.gen.auth as starting point
- Privacy is paramount - design for aggregate-only queries
- "Anonymous but accountable" - accounts required, but responses private
