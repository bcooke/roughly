# Data Model

The core data model for Roughly centers on Questions, Responses, and Demographics.

---

## Conceptual Model

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   Question  │       │   Response  │       │    User     │
│             │◄──────│             │───────►│             │
│  - text     │  1:N  │  - answer   │  N:1  │  - id       │
│  - options  │       │  - timestamp│       │  - demos    │
│  - category │       └─────────────┘       └─────────────┘
└─────────────┘                                    │
      │                                            │
      │                                   ┌────────▼────────┐
      │                                   │   Demographic   │
      │                                   │    Attributes   │
      │                                   │  - gender       │
      │                                   │  - age_range    │
      │                                   │  - location     │
      └───────────────────────────────────┘  - etc.
                Category linkage
```

---

## Core Entities

### Question

A poll question with defined answer options.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique identifier |
| `text` | String | The question text ("Do you like coffee?") |
| `slug` | String | URL-safe identifier ("do-you-like-coffee") |
| `question_type` | Enum | `binary`, `multiple_choice`, `scaled` |
| `answer_options` | Array | List of possible answers |
| `category` | String | Topic category (Technology, Sports, etc.) |
| `status` | Enum | `active`, `closed`, `moderated` |
| `created_at` | DateTime | When question was created |
| `methodology` | Text | Notes on how question was sourced/worded |

**Answer Option Structure:**
```elixir
%{
  id: "yes",
  label: "Yes",
  position: 1
}
```

### Response (Vote)

A single user's answer to a question.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique identifier |
| `question_id` | UUID | FK to Question |
| `user_id` | UUID | FK to User (nullable for anonymous) |
| `answer_id` | String | Which answer option was selected |
| `responded_at` | DateTime | When vote was cast |
| `demographic_snapshot` | JSONB | User's demographics at time of vote |

**Key Constraint**: One response per user per question.

### User

A contributor who can vote on questions.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique identifier |
| `email` | String | For authentication (hashed) |
| `verification_level` | Enum | `anonymous`, `email_verified`, `identity_verified` |
| `created_at` | DateTime | Registration date |
| `contribution_count` | Integer | Number of questions answered |

### Demographic Attributes

Stored on User, snapshotted with each Response.

| Attribute | Type | Values |
|-----------|------|--------|
| `gender` | Enum | `male`, `female`, `non_binary`, `prefer_not_to_say` |
| `age_range` | Enum | `under_18`, `18_24`, `25_34`, `35_44`, `45_54`, `55_64`, `65_plus` |
| `country` | String | ISO country code |
| `region` | String | State/province (US, etc.) |
| `education` | Enum | `high_school`, `some_college`, `bachelors`, `graduate` |
| `income_range` | Enum | Bands appropriate to country |

---

## Read Models (Projections)

### QuestionSummary

Denormalized view for fast question display.

| Field | Type | Description |
|-------|------|-------------|
| `question_id` | UUID | FK to Question |
| `total_votes` | Integer | Sum of all responses |
| `answer_counts` | JSONB | `{"yes": 2333, "no": 1544}` |
| `answer_percentages` | JSONB | `{"yes": 60.17, "no": 39.83}` |
| `last_vote_at` | DateTime | For "trending" calculations |
| `search_vector` | tsvector | Full-text search index |

### DemographicSlice

Vote breakdown by demographic attribute.

| Field | Type | Description |
|-------|------|-------------|
| `question_id` | UUID | FK to Question |
| `demographic_key` | String | e.g., "gender:male", "country:US" |
| `total_votes` | Integer | Votes in this slice |
| `answer_counts` | JSONB | Counts per answer option |
| `answer_percentages` | JSONB | Percentages per answer option |

**Index**: `(question_id, demographic_key)` for fast slice lookup.

### PopulationOverlap

Pre-computed cross-question analysis.

| Field | Type | Description |
|-------|------|-------------|
| `question_a_id` | UUID | First question |
| `question_b_id` | UUID | Second question |
| `filter_key` | String | Demographic filter (optional) |
| `overlap_count` | Integer | Users who answered both |
| `correlation_data` | JSONB | Cross-tabulation results |
| `computed_at` | DateTime | When last calculated |

**Note**: Expensive to compute; calculated async and cached.

---

## Event Schema

### QuestionCreated
```elixir
%{
  question_id: UUID,
  text: String,
  question_type: Atom,
  answer_options: [%{id, label, position}],
  category: String,
  created_by: UUID,
  created_at: DateTime
}
```

### VoteCast
```elixir
%{
  vote_id: UUID,
  question_id: UUID,
  user_id: UUID,
  answer_id: String,
  demographic_snapshot: %{
    gender: Atom,
    age_range: Atom,
    country: String,
    ...
  },
  voted_at: DateTime
}
```

### VoteRetracted
```elixir
%{
  vote_id: UUID,
  question_id: UUID,
  user_id: UUID,
  retracted_at: DateTime,
  reason: String  # optional
}
```

---

## Key Queries

### Get Question with Results
```sql
SELECT q.*, qs.total_votes, qs.answer_counts, qs.answer_percentages
FROM questions q
JOIN question_summaries qs ON q.id = qs.question_id
WHERE q.slug = 'do-you-like-coffee';
```

### Get Demographic Breakdown
```sql
SELECT demographic_key, answer_counts, answer_percentages
FROM demographic_slices
WHERE question_id = $1
  AND demographic_key IN ('gender:male', 'gender:female', 'country:US');
```

### Search Questions
```sql
SELECT q.*, qs.total_votes
FROM questions q
JOIN question_summaries qs ON q.id = qs.question_id
WHERE qs.search_vector @@ plainto_tsquery('english', 'coffee')
ORDER BY qs.total_votes DESC
LIMIT 20;
```

### Population Overlap Query
"What percentage of coffee drinkers exercise daily?"

```sql
-- Find users who answered both questions
WITH coffee_yes AS (
  SELECT user_id FROM responses
  WHERE question_id = $coffee_question_id AND answer_id = 'yes'
),
exercise AS (
  SELECT user_id, answer_id FROM responses
  WHERE question_id = $exercise_question_id
)
SELECT
  e.answer_id,
  COUNT(*) as count,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM coffee_yes) as percentage
FROM coffee_yes c
JOIN exercise e ON c.user_id = e.user_id
GROUP BY e.answer_id;
```

---

## Data Integrity Rules

1. **One vote per user per question**: Enforced by unique constraint
2. **Demographic snapshot immutability**: Once a vote is cast, its demographic snapshot is frozen
3. **Event ordering**: Events are ordered by timestamp within each aggregate
4. **Projection consistency**: Projections are eventually consistent with event store

---

## Privacy Considerations

- User email is hashed for storage
- Demographic data is never displayed at individual level
- Minimum threshold for slice display (e.g., 10 votes) to prevent de-anonymization
- Event redaction capability for GDPR "right to be forgotten"
