# Data Contribution

How polling data enters the Roughly system.

---

## Overview

Roughly's value depends on data quality and quantity. Users contribute by voting on questions, and the system manages data integrity.

## User Value

- **Participation**: Be part of the data
- **Curiosity satisfaction**: Answer to see results
- **Community building**: Grow the database together

---

## Contribution Flow

### Vote Flow

1. User views question page
2. Clicks "Vote!" on their answer
3. System validates vote
4. Vote recorded with demographic snapshot
5. Results update in real-time
6. User sees updated percentages

### Give-to-Get Model

To prevent pure consumers, users must contribute:
- **Initial access**: Answer N questions to unlock viewing
- **Ongoing access**: Maintain contribution ratio
- **Enforcement**: Soft (encouragement) vs hard (blocking)

---

## Vote Mechanics

### Voting Requirements

- Must be logged in (or session-identified)
- One vote per question per user
- Can change vote (retract and re-vote)
- Demographics captured at vote time

### Vote Button States

| State | Display | Behavior |
|-------|---------|----------|
| Available | "Vote!" (red) | Click to vote |
| Voted | "Voted ✓" (green) | Shows selected answer |
| Changing | "Change" | Retract and re-select |
| Disabled | Grayed out | Already voted, can't change |

### Demographic Capture

On first vote (or profile update), capture:
- Gender
- Age range
- Location (country, optionally region)
- Other attributes (optional)

---

## Data Quality

### Bad-Faith Detection

Detect and filter suspicious voting patterns:

| Signal | Detection | Action |
|--------|-----------|--------|
| Speed voting | < 2 seconds per question | Flag for review |
| Pattern voting | All same answer | Weight reduction |
| Inconsistency | Contradictory demographics | Verification prompt |
| Bot behavior | No session variation | Block |

### Quality Scoring

Questions and users have quality scores:
- **Sample size**: More votes = higher confidence
- **Response diversity**: Varied demographics = better
- **Consistency**: User voting patterns
- **Verification level**: Identity confidence

### Moderation

- Community flagging of bad questions
- Admin review queue
- Question status: active, under_review, closed

---

## Question Submission

### User-Submitted Questions (Future)

1. User proposes question
2. System validates format
3. Enters moderation queue
4. Admin approves/rejects
5. Goes live for voting

### Question Standards

- Clear, unambiguous wording
- Exhaustive answer options
- No leading/biased phrasing
- Appropriate category

---

## Event Sourcing

Every contribution is an event:

```elixir
# Vote cast
%VoteCast{
  vote_id: UUID,
  question_id: UUID,
  user_id: UUID,
  answer_id: "yes",
  demographic_snapshot: %{...},
  voted_at: DateTime
}

# Vote retracted
%VoteRetracted{
  vote_id: UUID,
  retracted_at: DateTime
}
```

Benefits:
- Complete audit trail
- Vote history reconstructable
- Temporal queries possible

---

## Contribution Incentives

### Gamification (Light)

- Contribution count displayed
- "Top contributor" badges
- Streak tracking

### Access Tiers

| Tier | Requirement | Access |
|------|-------------|--------|
| Guest | None | View top questions |
| Contributor | 10+ votes | Full search access |
| Power User | 100+ votes | Advanced filters |
| Verified | Identity check | Full data exports |

---

## Related Docs

- [[Product Vision]] - Why contributions matter
- [[System Architecture]] - Event sourcing details
- [[Glossary]] - Contribution terminology
