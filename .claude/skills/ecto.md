---
name: ecto
description: Ecto patterns for Phoenix. Schemas, changesets, queries, and migrations.
---

# Ecto Skill

Best practices for data modeling and querying with Ecto in Phoenix.

## Schema Design

### Basic Schema

```elixir
defmodule Roughly.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "questions" do
    field :text, :string
    field :question_type, Ecto.Enum, values: [:binary, :multiple_choice, :scaled]
    field :status, Ecto.Enum, values: [:draft, :active, :archived], default: :draft

    has_many :responses, Roughly.Questions.Response
    belongs_to :created_by, Roughly.Users.User

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:text, :question_type, :status, :created_by_id])
    |> validate_required([:text, :question_type])
    |> validate_length(:text, min: 10, max: 500)
    |> foreign_key_constraint(:created_by_id)
  end
end
```

### UUID vs Integer Keys

For Roughly, use UUIDs:
- Better for distributed systems
- No sequential exposure
- Supports event sourcing

```elixir
# In schema
@primary_key {:uuid, :binary_id, autogenerate: true}
@foreign_key_type :binary_id

# In migration
create table(:questions, primary_key: false) do
  add :uuid, :binary_id, primary_key: true
  add :text, :string, null: false
  timestamps(type: :utc_datetime)
end
```

## Changeset Patterns

### Multiple Changesets

```elixir
defmodule Roughly.Questions.Question do
  # For creating new questions
  def create_changeset(question, attrs) do
    question
    |> cast(attrs, [:text, :question_type])
    |> validate_required([:text, :question_type])
    |> validate_length(:text, min: 10, max: 500)
  end

  # For updating existing questions
  def update_changeset(question, attrs) do
    question
    |> cast(attrs, [:text])
    |> validate_length(:text, min: 10, max: 500)
  end

  # For activating a question
  def activation_changeset(question) do
    question
    |> change(status: :active)
    |> validate_has_responses()
  end

  defp validate_has_responses(changeset) do
    if Enum.empty?(changeset.data.responses || []) do
      add_error(changeset, :responses, "must have at least one response")
    else
      changeset
    end
  end
end
```

### Custom Validations

```elixir
def changeset(question, attrs) do
  question
  |> cast(attrs, [:text, :question_type])
  |> validate_required([:text, :question_type])
  |> validate_no_profanity(:text)
  |> validate_unique_text()
end

defp validate_no_profanity(changeset, field) do
  validate_change(changeset, field, fn _, value ->
    if contains_profanity?(value) do
      [{field, "contains inappropriate language"}]
    else
      []
    end
  end)
end

defp validate_unique_text(changeset) do
  changeset
  |> unsafe_validate_unique(:text, Roughly.Repo)
  |> unique_constraint(:text)
end
```

## Query Composition

### Query Modules

```elixir
defmodule Roughly.Questions.Queries do
  import Ecto.Query

  alias Roughly.Questions.Question

  def base do
    from(q in Question)
  end

  def active(query \\ base()) do
    from q in query, where: q.status == :active
  end

  def by_type(query \\ base(), type) do
    from q in query, where: q.question_type == ^type
  end

  def with_responses(query \\ base()) do
    from q in query, preload: [:responses]
  end

  def search(query \\ base(), term) do
    from q in query,
      where: ilike(q.text, ^"%#{term}%")
  end

  def order_by_recent(query \\ base()) do
    from q in query, order_by: [desc: q.inserted_at]
  end

  def paginate(query \\ base(), page, per_page \\ 20) do
    offset = (page - 1) * per_page
    from q in query, limit: ^per_page, offset: ^offset
  end
end
```

### Usage

```elixir
import Roughly.Questions.Queries

# Compose queries
active()
|> by_type(:binary)
|> search("favorite")
|> with_responses()
|> order_by_recent()
|> paginate(1)
|> Repo.all()
```

## Preloading

### In Query

```elixir
from q in Question,
  preload: [:responses, :created_by]
```

### After Query

```elixir
questions
|> Repo.all()
|> Repo.preload([:responses, created_by: :profile])
```

### Nested Preloads

```elixir
from q in Question,
  preload: [responses: :votes, created_by: [:profile, :settings]]
```

## Aggregations

```elixir
# Count
from(q in Question, select: count(q.uuid))
|> Repo.one()

# Count per group
from(q in Question,
  group_by: q.question_type,
  select: {q.question_type, count(q.uuid)}
)
|> Repo.all()

# Average, sum, etc.
from(r in Response,
  where: r.question_uuid == ^question_uuid,
  select: avg(r.vote_count)
)
|> Repo.one()
```

## Migrations

### Create Table

```elixir
defmodule Roughly.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :uuid, :binary_id, primary_key: true
      add :text, :string, null: false
      add :question_type, :string, null: false
      add :status, :string, null: false, default: "draft"
      add :created_by_id, references(:users, type: :binary_id, column: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:questions, [:status])
    create index(:questions, [:question_type])
    create index(:questions, [:created_by_id])
  end
end
```

### Add Column

```elixir
def change do
  alter table(:questions) do
    add :archived_at, :utc_datetime
  end
end
```

### Create Index

```elixir
def change do
  create index(:questions, [:text], using: :gin, name: :questions_text_gin_index)
  create unique_index(:questions, [:text], where: "status = 'active'")
end
```

### Data Migration

```elixir
def up do
  # Add column first
  alter table(:questions) do
    add :slug, :string
  end

  flush()

  # Then populate
  repo().update_all(
    from(q in "questions", update: [set: [slug: fragment("lower(replace(?, ' ', '-'))", q.text)]]),
    []
  )

  # Then add constraint
  alter table(:questions) do
    modify :slug, :string, null: false
  end

  create unique_index(:questions, [:slug])
end
```

## Embedded Schemas

```elixir
defmodule Roughly.Demographics.Attributes do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :age_range, :string
    field :location, :string
    field :education_level, :string
  end

  def changeset(attrs, params) do
    attrs
    |> cast(params, [:age_range, :location, :education_level])
    |> validate_inclusion(:age_range, ["18-24", "25-34", "35-44", "45-54", "55-64", "65+"])
  end
end

# In parent schema
defmodule Roughly.Users.User do
  use Ecto.Schema

  schema "users" do
    embeds_one :demographics, Roughly.Demographics.Attributes, on_replace: :update
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [])
    |> cast_embed(:demographics)
  end
end
```

## Transactions

```elixir
# Simple transaction
Repo.transaction(fn ->
  question = Repo.insert!(question_changeset)
  Repo.insert_all(:responses, responses)
  question
end)

# Multi
alias Ecto.Multi

Multi.new()
|> Multi.insert(:question, question_changeset)
|> Multi.insert_all(:responses, Response, fn %{question: q} ->
  Enum.map(responses, &Map.put(&1, :question_uuid, q.uuid))
end)
|> Repo.transaction()
|> case do
  {:ok, %{question: question}} -> {:ok, question}
  {:error, _op, changeset, _changes} -> {:error, changeset}
end
```

## Best Practices

### Do
- Use UUIDs for primary keys
- Define multiple changesets per use case
- Compose queries with functions
- Use database constraints (not just validations)
- Preload in queries, not N+1

### Don't
- Put business logic in schemas
- Use raw SQL without escaping
- Forget indexes on foreign keys
- Use `Repo` in schema modules
- Mix concerns in changesets

## Testing

```elixir
defmodule Roughly.Questions.QuestionTest do
  use Roughly.DataCase

  alias Roughly.Questions.Question

  describe "changeset/2" do
    test "valid attributes" do
      changeset = Question.changeset(%Question{}, %{
        text: "What is your favorite color?",
        question_type: :multiple_choice
      })

      assert changeset.valid?
    end

    test "requires text" do
      changeset = Question.changeset(%Question{}, %{question_type: :binary})
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).text
    end

    test "validates text length" do
      changeset = Question.changeset(%Question{}, %{
        text: "Short",
        question_type: :binary
      })

      refute changeset.valid?
      assert "should be at least 10 character(s)" in errors_on(changeset).text
    end
  end
end
```

## Remember

- Schemas define structure
- Changesets validate and transform
- Queries are composable
- Migrations are reversible
- Transactions ensure consistency
