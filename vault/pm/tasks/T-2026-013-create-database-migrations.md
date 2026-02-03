---
type: task
id: T-2026-013
story:
epic:
status: completed
priority: p1
created: 2026-02-03
updated: 2026-02-03
---

# Task: Create Database Migrations for Projections

## Task Details
**Task ID**: T-2026-013
**Status**: Backlog
**Priority**: P1
**Branch**: feat/T-2026-013-create-database-migrations
**Created**: 2026-02-03

## Description

Create Ecto migrations for the projection schemas created in T-2026-012. The aggregates store their state in EventStore, but the projections need PostgreSQL tables for querying.

## Checklist
- [x] Create questions table migration
- [x] Create votes table migration
- [x] Create users table migration
- [x] Add projection_versions table (for Commanded.Projections.Ecto)
- [x] Run migrations and verify
- [ ] Write seed data for development (deferred - not needed yet)

## Migrations Needed

### Questions Table
```elixir
create table(:questions, primary_key: false) do
  add :uuid, :binary_id, primary_key: true
  add :text, :string, null: false
  add :slug, :string
  add :question_type, :string, null: false
  add :status, :string, default: "active"
  add :options, {:array, :string}, default: []
  add :category, :string
  add :created_by, :binary_id

  timestamps(type: :utc_datetime)
end

create unique_index(:questions, [:slug])
```

### Votes Table
```elixir
create table(:votes, primary_key: false) do
  add :uuid, :binary_id, primary_key: true
  add :question_uuid, :binary_id, null: false
  add :user_uuid, :binary_id, null: false
  add :option_id, :string, null: false
  add :status, :string, default: "active"

  timestamps(type: :utc_datetime)
end

create unique_index(:votes, [:question_uuid, :user_uuid], name: :votes_question_user_unique)
create index(:votes, [:question_uuid])
create index(:votes, [:user_uuid])
```

### Users Table
```elixir
create table(:users, primary_key: false) do
  add :uuid, :binary_id, primary_key: true
  add :email, :string, null: false
  add :password_hash, :string
  add :display_name, :string
  add :birth_year, :integer
  add :country, :string
  add :region, :string
  add :gender, :string
  add :status, :string, default: "active"

  timestamps(type: :utc_datetime)
end

create unique_index(:users, [:email])
```

### Projection Versions Table
Required by `commanded_ecto_projections` for tracking projection state.

## Dependencies
### Blocked By
- T-2026-012 (projection schemas) - COMPLETED

### Blocks
- Feature implementation (need tables to query)

## Notes
- Follow TDD: write migration tests if applicable
- Ensure all indexes support expected query patterns
- Consider adding full-text search indexes later
