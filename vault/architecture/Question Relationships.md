# Question Relationships

This document defines the data model for question relationships in Roughly - how questions relate to each other semantically, hierarchically, and topically.

---

## Overview

Questions in Roughly don't exist in isolation. They form a graph of relationships:

- **Equivalence**: "Do you like coffee?" and "Are you a coffee drinker?" are the same question
- **Relatedness**: "Do you exercise?" is related to "How often do you run?"
- **Hierarchy**: "How often do you run?" is a sub-question of "Do you exercise?"
- **Taxonomy**: Both are tagged with "Health", "Fitness", "Exercise"

Modeling these relationships enables:
- Deduplication (don't create the same question twice)
- Discovery (find related questions)
- Navigation (browse question hierarchies)
- Aggregation (combine equivalent question results)

---

## Relationship Types

### 1. Equivalence (Same Question)

Two questions are **equivalent** if they're asking the same thing with different wording.

**Characteristics:**
- Bidirectional (if A ≡ B, then B ≡ A)
- Transitive (if A ≡ B and B ≡ C, then A ≡ C)
- High confidence required (manual verification)
- Vote data could be merged for aggregates

**Examples:**
- "Do you like coffee?" ≡ "Are you a coffee drinker?"
- "Do you exercise regularly?" ≡ "Do you work out on a regular basis?"

**Detection methods:**
- Text similarity (pg_trgm, > 0.7 similarity)
- User flagging ("These are the same question")
- ML-based semantic similarity (future)

### 2. Relatedness (Topically Similar)

Two questions are **related** if they cover similar topics or domains.

**Characteristics:**
- Bidirectional (usually)
- Scored (0-1 strength)
- Can be computed automatically
- Used for "Related Questions" suggestions

**Examples:**
- "Do you drink coffee?" ~ "Do you drink tea?" (both about beverages)
- "Do you support X policy?" ~ "Do you support Y policy?" (both political)

**Detection methods:**
- Shared tags/categories
- Co-voting patterns (same users answer both)
- Text similarity (lower threshold, 0.4-0.7)
- Demographic correlation

### 3. Hierarchy (Parent-Child)

Questions can have sub-questions that drill down into specifics.

**Characteristics:**
- Directed (parent → child)
- Tree structure (one parent per child)
- Used for navigation and categorization
- Path-based queries

**Examples:**
- "Do you exercise?" → "Do you run?" → "Do you run marathons?"
- "Do you own pets?" → "Do you own cats?" → "Do you own a Maine Coon?"

**Implementation:**
- PostgreSQL ltree extension
- Path notation: `Exercise.Running.Marathons`

### 4. Taxonomy (Tags and Categories)

Questions belong to categories and have tags.

**Characteristics:**
- Many-to-many (questions have multiple tags)
- Hierarchical categories possible
- User-assignable and system-generated
- Scored relevance

**Examples:**
- Question: "Do you exercise?" → Tags: [Health, Fitness, Lifestyle]
- Category: Sports > Fitness > Exercise

---

## Data Model

### Schema: QuestionRelationship

Stores directed relationships between questions.

```elixir
defmodule Roughly.Questions.Schemas.QuestionRelationship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "question_relationships" do
    field :relationship_type, Ecto.Enum,
      values: [:equivalent, :related, :parent_of, :prerequisite, :follow_up]
    field :strength_score, :float, default: 0.5
    field :is_verified, :boolean, default: false
    field :verification_method, :string  # "manual", "auto_text", "auto_voting"

    belongs_to :source_question, Roughly.Questions.Schemas.Question
    belongs_to :target_question, Roughly.Questions.Schemas.Question
    belongs_to :verified_by, Roughly.Users.Schemas.User

    timestamps(type: :utc_datetime)
  end

  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:relationship_type, :strength_score, :is_verified,
                    :verification_method, :source_question_id, :target_question_id])
    |> validate_required([:relationship_type, :source_question_id, :target_question_id])
    |> validate_number(:strength_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> validate_different_questions()
    |> unique_constraint([:source_question_id, :target_question_id, :relationship_type])
  end

  defp validate_different_questions(changeset) do
    source = get_field(changeset, :source_question_id)
    target = get_field(changeset, :target_question_id)

    if source == target do
      add_error(changeset, :target_question_id, "cannot be the same as source question")
    else
      changeset
    end
  end
end
```

### Schema: QuestionHierarchy

Stores hierarchical tree paths using ltree pattern.

```elixir
defmodule Roughly.Questions.Schemas.QuestionHierarchy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "question_hierarchies" do
    field :tree_path, :string  # ltree stored as string, e.g., "Health.Fitness.Exercise"
    field :hierarchy_level, :integer

    belongs_to :question, Roughly.Questions.Schemas.Question
    belongs_to :parent_question, Roughly.Questions.Schemas.Question

    timestamps(type: :utc_datetime)
  end

  def changeset(hierarchy, attrs) do
    hierarchy
    |> cast(attrs, [:tree_path, :question_id, :parent_question_id])
    |> validate_required([:tree_path, :question_id])
    |> compute_level()
    |> unique_constraint(:question_id)
  end

  defp compute_level(changeset) do
    case get_field(changeset, :tree_path) do
      nil -> changeset
      path -> put_change(changeset, :hierarchy_level, count_levels(path))
    end
  end

  defp count_levels(path), do: length(String.split(path, "."))
end
```

### Schema: QuestionTag

Tags for categorization.

```elixir
defmodule Roughly.Questions.Schemas.QuestionTag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "question_tags" do
    field :slug, :string
    field :label, :string
    field :description, :string
    field :is_system, :boolean, default: false
    field :color, :string  # For UI display

    many_to_many :questions, Roughly.Questions.Schemas.Question,
      join_through: "question_tag_assignments"

    timestamps(type: :utc_datetime)
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:slug, :label, :description, :is_system, :color])
    |> validate_required([:slug, :label])
    |> unique_constraint(:slug)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/)
  end
end
```

### Schema: QuestionTagAssignment

Junction table with relevance scoring.

```elixir
defmodule Roughly.Questions.Schemas.QuestionTagAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "question_tag_assignments" do
    field :relevance_score, :float, default: 1.0
    field :assignment_type, Ecto.Enum, values: [:manual, :auto, :suggested]

    belongs_to :question, Roughly.Questions.Schemas.Question
    belongs_to :tag, Roughly.Questions.Schemas.QuestionTag
    belongs_to :assigned_by, Roughly.Users.Schemas.User

    timestamps(type: :utc_datetime)
  end

  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:relevance_score, :assignment_type, :question_id, :tag_id, :assigned_by_id])
    |> validate_required([:question_id, :tag_id])
    |> validate_number(:relevance_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> unique_constraint([:question_id, :tag_id])
  end
end
```

### Schema: RelationshipSignals

Scoring components for relationship detection.

```elixir
defmodule Roughly.Questions.Schemas.RelationshipSignals do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "question_relationship_signals" do
    # Individual signal scores (0-1)
    field :text_similarity, :float
    field :tag_overlap_score, :float
    field :co_voting_frequency, :float
    field :demographic_correlation, :float
    field :category_similarity, :float

    # User feedback
    field :user_flagged, :boolean, default: false
    field :user_flag_count, :integer, default: 0

    # Computed composite scores
    field :equivalence_score, :float
    field :relatedness_score, :float

    field :last_computed_at, :utc_datetime

    belongs_to :source_question, Roughly.Questions.Schemas.Question
    belongs_to :target_question, Roughly.Questions.Schemas.Question

    timestamps(type: :utc_datetime)
  end

  def changeset(signals, attrs) do
    signals
    |> cast(attrs, [:text_similarity, :tag_overlap_score, :co_voting_frequency,
                    :demographic_correlation, :category_similarity, :user_flagged,
                    :user_flag_count, :source_question_id, :target_question_id])
    |> validate_required([:source_question_id, :target_question_id])
    |> compute_scores()
    |> put_change(:last_computed_at, DateTime.utc_now())
    |> unique_constraint([:source_question_id, :target_question_id])
  end

  defp compute_scores(changeset) do
    changeset
    |> compute_equivalence_score()
    |> compute_relatedness_score()
  end

  defp compute_equivalence_score(changeset) do
    # Weights: text_similarity (40%), tag_overlap (20%), co_voting (20%),
    #          category (10%), demographic (10%)
    score =
      0.40 * (get_field(changeset, :text_similarity) || 0) +
      0.20 * (get_field(changeset, :tag_overlap_score) || 0) +
      0.20 * (get_field(changeset, :co_voting_frequency) || 0) +
      0.10 * (get_field(changeset, :category_similarity) || 0) +
      0.10 * (get_field(changeset, :demographic_correlation) || 0)

    put_change(changeset, :equivalence_score, Float.round(score, 3))
  end

  defp compute_relatedness_score(changeset) do
    # Weights: text_similarity (35%), tag_overlap (30%), co_voting (20%), category (15%)
    score =
      0.35 * (get_field(changeset, :text_similarity) || 0) +
      0.30 * (get_field(changeset, :tag_overlap_score) || 0) +
      0.20 * (get_field(changeset, :co_voting_frequency) || 0) +
      0.15 * (get_field(changeset, :category_similarity) || 0)

    put_change(changeset, :relatedness_score, Float.round(score, 3))
  end
end
```

---

## Database Design

### Required Extensions

```sql
-- Enable in migration
CREATE EXTENSION IF NOT EXISTS ltree;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

### Tables and Indices

```sql
-- Relationships table
CREATE TABLE question_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  target_question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  relationship_type VARCHAR(50) NOT NULL,
  strength_score FLOAT NOT NULL DEFAULT 0.5,
  is_verified BOOLEAN DEFAULT FALSE,
  verification_method VARCHAR(50),
  verified_by_id UUID REFERENCES users(id),
  inserted_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT different_questions CHECK (source_question_id <> target_question_id),
  CONSTRAINT unique_relationship UNIQUE (source_question_id, target_question_id, relationship_type)
);

CREATE INDEX idx_relationships_source ON question_relationships(source_question_id);
CREATE INDEX idx_relationships_target ON question_relationships(target_question_id);
CREATE INDEX idx_relationships_type ON question_relationships(relationship_type);
CREATE INDEX idx_relationships_strength ON question_relationships(strength_score DESC) WHERE is_verified = TRUE;

-- Hierarchy table with ltree
CREATE TABLE question_hierarchies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID UNIQUE NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  parent_question_id UUID REFERENCES questions(id) ON DELETE SET NULL,
  tree_path ltree NOT NULL,
  hierarchy_level INT NOT NULL,
  inserted_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_hierarchy_path_gist ON question_hierarchies USING GIST(tree_path);
CREATE INDEX idx_hierarchy_parent ON question_hierarchies(parent_question_id);

-- Tags
CREATE TABLE question_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR(100) UNIQUE NOT NULL,
  label VARCHAR(255) NOT NULL,
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  color VARCHAR(7),
  inserted_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Tag assignments
CREATE TABLE question_tag_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES question_tags(id) ON DELETE CASCADE,
  relevance_score FLOAT DEFAULT 1.0,
  assignment_type VARCHAR(50) DEFAULT 'manual',
  assigned_by_id UUID REFERENCES users(id),
  inserted_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT unique_question_tag UNIQUE (question_id, tag_id)
);

CREATE INDEX idx_tag_assignments_question ON question_tag_assignments(question_id);
CREATE INDEX idx_tag_assignments_tag ON question_tag_assignments(tag_id);

-- Relationship signals for scoring
CREATE TABLE question_relationship_signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  target_question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  text_similarity FLOAT,
  tag_overlap_score FLOAT,
  co_voting_frequency FLOAT,
  demographic_correlation FLOAT,
  category_similarity FLOAT,
  user_flagged BOOLEAN DEFAULT FALSE,
  user_flag_count INT DEFAULT 0,
  equivalence_score FLOAT,
  relatedness_score FLOAT,
  last_computed_at TIMESTAMP,
  inserted_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT unique_signal UNIQUE (source_question_id, target_question_id)
);

CREATE INDEX idx_signals_equivalence ON question_relationship_signals(equivalence_score DESC);
CREATE INDEX idx_signals_relatedness ON question_relationship_signals(relatedness_score DESC);
CREATE INDEX idx_signals_source ON question_relationship_signals(source_question_id);

-- Text similarity index on questions
CREATE INDEX idx_question_text_trgm ON questions USING gin (text gin_trgm_ops);
```

---

## Queries

### Find Similar Questions (Deduplication)

```elixir
# When creating a new question, check for duplicates
def find_similar_questions(text, threshold \\ 0.6) do
  from(q in Question,
    where: fragment("similarity(?, ?) > ?", q.text, ^text, ^threshold),
    order_by: [desc: fragment("similarity(?, ?)", q.text, ^text)],
    limit: 5
  )
  |> Repo.all()
end
```

### Get Related Questions

```elixir
def get_related_questions(question_id, limit \\ 10) do
  from(rs in RelationshipSignals,
    where: rs.source_question_id == ^question_id,
    where: rs.relatedness_score > 0.4,
    join: q in Question, on: q.id == rs.target_question_id,
    order_by: [desc: rs.relatedness_score],
    limit: ^limit,
    select: %{question: q, score: rs.relatedness_score}
  )
  |> Repo.all()
end
```

### Get Question Hierarchy

```elixir
# Get all sub-questions
def get_sub_questions(question_id) do
  parent_path = get_question_path(question_id)

  from(qh in QuestionHierarchy,
    where: fragment("? <@ ?", qh.tree_path, ^parent_path),
    where: qh.question_id != ^question_id,
    join: q in Question, on: q.id == qh.question_id,
    order_by: [asc: qh.hierarchy_level],
    select: %{question: q, level: qh.hierarchy_level, path: qh.tree_path}
  )
  |> Repo.all()
end

# Get breadcrumb trail to root
def get_ancestors(question_id) do
  question_path = get_question_path(question_id)

  from(qh in QuestionHierarchy,
    where: fragment("? @> ?", qh.tree_path, ^question_path),
    where: qh.question_id != ^question_id,
    join: q in Question, on: q.id == qh.question_id,
    order_by: [asc: qh.hierarchy_level],
    select: %{question: q, level: qh.hierarchy_level}
  )
  |> Repo.all()
end
```

---

## Scoring Model

### Equivalence Detection

Questions are flagged as equivalent when:
- Text similarity > 0.7 (pg_trgm)
- AND (tag overlap > 0.5 OR co-voting > 0.3)
- AND manually verified OR user_flag_count >= 3

### Relatedness Scoring

Composite score from multiple signals:

| Signal | Weight | Source |
|--------|--------|--------|
| Text similarity | 35% | pg_trgm |
| Tag overlap | 30% | Shared tags |
| Co-voting frequency | 20% | Same users answer both |
| Category similarity | 15% | Same/similar categories |

### Score Computation

Scores are computed:
- **On question creation**: Initial text similarity check
- **Batch job (daily)**: Full signal recomputation
- **On tag assignment**: Tag overlap recalculation
- **On vote cast**: Co-voting frequency update (batched)

---

## Implementation Phases

### Phase 1: Core Structure
- Create migrations for all relationship tables
- Implement basic relationship CRUD
- Enable pg_trgm and ltree extensions

### Phase 2: Similarity Detection
- Implement text similarity queries
- Add "similar question" check on creation
- Build manual relationship flagging

### Phase 3: Hierarchies
- Implement ltree-based hierarchy
- Build breadcrumb navigation
- Add sub-question listing

### Phase 4: Automated Scoring
- Implement background job for signal computation
- Build composite scoring
- Add "Related Questions" feature

### Phase 5: User Curation
- Allow users to suggest relationships
- Implement voting on relationship accuracy
- Surface high-confidence relationships

---

## Future Considerations

### ML-Based Semantic Similarity
- Embed question text with sentence transformers
- Store embeddings in pgvector
- Cosine similarity for semantic matching

### Graph Visualization
- Build question relationship graph UI
- Interactive exploration of related questions
- Topic clusters visualization

### Cross-Question Analytics
- "How do coffee drinkers vote on exercise questions?"
- Population overlap queries
- Demographic correlation analysis
