# Demographic Slicing

Filter question results by demographic attributes to see how different groups respond.

---

## Overview

Slicing is the killer feature. Instead of just "60% say Yes," users can see "Men: 70% Yes, Women: 52% Yes" and understand demographic differences.

## User Value

- **Insight**: See how different groups think differently
- **Context**: "Do I agree with people like me?"
- **Research**: Demographic breakdowns for analysis

---

## How It Works

### Breakdown Tabs

On each question page, tabs let users filter results:
- **All** - Default view, everyone
- **Men / Women** - Gender breakdown
- **US / World** - Geographic breakdown
- **Age groups** - Generational differences
- Custom combinations (future)

### Slice Display

Each slice shows:
- Vote count for that demographic
- Answer percentages
- Bar chart visualization
- Pie chart (same format as main view)

### Available Slices

| Category | Slices | Notes |
|----------|--------|-------|
| Gender | Male, Female, Non-binary | Self-reported |
| Age | Under 25, 25-34, 35-44, 45-54, 55+ | Ranges |
| Location | US, Europe, Asia, Other | Country-based |
| Custom | Varies | Cross-slice analysis |

---

## User Interface

### Tab Navigation

```
┌─────────────────────────────────────────────┐
│ [Breakdowns]                                │
│ Men | Women | US | World | 25-34 | 55+      │
├─────────────────────────────────────────────┤
│ Currently showing: Men (1,245 votes)        │
│                                             │
│ [Vote!] 1) Yes  ████████░░ 72%              │
│ [Vote!] 2) No   ████░░░░░░ 28%              │
└─────────────────────────────────────────────┘
```

### Comparison View (Future)

Side-by-side comparison:
```
┌──────────────────┬──────────────────┐
│      Men         │      Women       │
│  Yes: 72%        │  Yes: 52%        │
│  No:  28%        │  No:  48%        │
└──────────────────┴──────────────────┘
```

---

## Technical Notes

### Data Storage

- Demographics captured at vote time (snapshot)
- Stored in `demographic_slices` projection
- Indexed by `(question_id, demographic_key)`

### Query Pattern

```sql
SELECT answer_counts, answer_percentages
FROM demographic_slices
WHERE question_id = $1
  AND demographic_key = 'gender:male';
```

### Minimum Threshold

Slices with fewer than 10 votes are hidden to:
- Prevent statistical insignificance
- Protect user anonymity

### Projection Updates

When a vote is cast:
1. VoteCast event emitted
2. DemographicProjector receives event
3. Updates all relevant slice counters
4. LiveView pushes update to connected clients

---

## Privacy Considerations

- Demographics are never shown at individual level
- Slices require minimum vote threshold
- Users can opt out of demographic collection
- No cross-referencing that could identify individuals

---

## Related Docs

- [[Data Model]] - Demographic storage
- [[Product Vision]] - Why slicing matters
- [[Glossary]] - Demographic terminology
