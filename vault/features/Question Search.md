# Question Search

The primary way users find questions in Roughly.

---

## Overview

Search is the core user experience. Users type natural language queries and find relevant questions with their polling data.

## User Value

- **Discovery**: "I wonder what percentage of people..." → instant answer
- **Exploration**: Search results lead to related questions
- **SEO**: Long-tail queries drive organic traffic

---

## How It Works

### Search Flow

1. User types query in search bar (e.g., "coffee")
2. System searches question text and categories
3. Results show matching questions with vote counts
4. User clicks to view full question page

### Search Bar Behavior

- **Prominent placement**: Center of homepage, Google-style
- **Autocomplete**: Suggests popular questions as user types
- **Recent searches**: Shows user's search history
- **Trending**: Popular questions shown before typing

### Results Display

Each result shows:
- Question text (highlighted match)
- Total vote count
- Top answer with percentage
- Category tag

### Ranking Factors

1. **Relevance**: Text match quality
2. **Popularity**: Total vote count
3. **Recency**: Recently active questions
4. **Quality**: Sample size, response diversity

---

## Technical Notes

### Search Implementation

- PostgreSQL full-text search via `tsvector`
- Indexed on question text, category, tags
- Optional: Elasticsearch for advanced features

### Search Index Fields

| Field | Weight | Notes |
|-------|--------|-------|
| `question_text` | A | Primary match field |
| `category` | B | Topic filtering |
| `tags` | B | Related terms |
| `answer_options` | C | Match on answer text |

### Query Processing

1. Normalize input (lowercase, stemming)
2. Generate tsquery
3. Execute against index
4. Rank by relevance × popularity
5. Return paginated results

---

## Related Docs

- [[Product Vision]] - Overall product goals
- [[System Architecture]] - Technical implementation
- [[Data Model]] - Question schema
