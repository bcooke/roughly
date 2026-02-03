# Product Vision

## What We're Building

Roughly is an encyclopedia of quantifiable human data - a Wikipedia for the world's percentages.

The site answers questions like:
- "Do you like the taste of coffee?" → 60% Yes, 40% No (3,877 votes)
- "What percentage of men prefer summer to winter?"
- "How do Patriots fans compare to the general population on [any topic]?"

## The Problem

Quantifiable human data is:
- **Siloed**: Gallup, Pew, and others keep data behind paywalls
- **Expensive**: Commissioning polls costs thousands
- **Hard to search**: No canonical place to look up "what do people think about X"
- **Not sliceable**: Even when data exists, you can't easily filter by demographics

## The Solution

A free, open, searchable database where:
1. Anyone can find polling data on any topic
2. Data is sliceable by demographics (gender, age, location, etc.)
3. Methodology is transparent
4. The community contributes questions and votes

## Core User Experience

### Search-First Homepage
Like Google: a clean search bar to find any question. Suggested searches and trending questions provide discovery.

### Question Pages
Each question has its own URL-optimized page showing:
- The question text
- Total vote count
- Answer breakdown with percentages and bar visualization
- Pie chart visualization
- **Breakdowns**: Tabs to filter by demographics (Men, Women, US, World, etc.)
- **Similar Questions**: Related questions for exploration

### Stat Ticker
A scrolling banner of interesting factoids with quick "Vote!" CTAs to drive engagement.

### Category Navigation
Browse by topic: Home, World, US, Business, Technology, Entertainment, Sports, Science

## Target Users

| User Type | What They Want |
|-----------|----------------|
| **Curious Searchers** | "I wonder what percentage of people..." |
| **Researchers** | Demographic data for papers, articles, decisions |
| **Journalists** | Quick stats to cite in stories |
| **Educators** | Teaching statistics, critical thinking |
| **Data Contributors** | Influence the database by answering questions |

## Success Metrics

- **Questions in database**: Breadth of topics covered
- **Votes per question**: Statistical significance
- **Daily active users**: Engagement
- **Search-to-result success**: Can users find what they're looking for?
- **Data quality score**: Detection of bad-faith responses

## Key Challenges

### Polling Methodology
- **Sample bias**: Who uses the site may not represent the population
- **Truthfulness**: People can lie
- **Question wording**: Phrasing affects results
- **Answer ordering**: Position bias in multiple choice

### Mitigations
- Force users to answer questions to see more data (contribution requirement)
- Sophisticated bad-faith detection (pattern analysis, speed, consistency)
- Transparent methodology documentation per question
- Consider verified human identities for voting
- Event sourcing for complete audit trail

## Privacy Model

### "Anonymous but Accountable"
A core design principle: **accounts required, but responses private**.

- **No anonymous voting**: Users must have an account to answer questions
  - Incentivizes quality responses (skin in the game)
  - Enables duplicate vote prevention
  - Allows users to view their own answer history
  - Supports quality signals (account age, answer patterns)
- **Individual answers are never public**: Only aggregate data is visible
  - Users can see what they answered, but no one else can
  - Only demographic slice aggregates are shown publicly
  - Consider k-anonymity thresholds (e.g., only show slices with 10+ responses)
- **Potential encryption**: Consider encrypting individual vote records for defense in depth
  - Users could prove their own vote if needed
  - Aggregate queries work on encrypted data or via projections
  - Protects against database breaches exposing individual responses

### Why This Matters
People want to share their honest opinions without being individually identified. The value is in the aggregate ("60% of women under 30 prefer X") not in "user@email.com chose X". Protecting individual privacy while requiring accountability creates trust.

## What Makes This Different

| Competitor | Problem | Roughly's Approach |
|------------|---------|-------------------|
| Gallup | Paywalled, expensive | Free and open |
| Pew Research | Academic, not searchable | Consumer-friendly search |
| Quora | Opinions, not data | Quantified responses |
| Reddit polls | Ephemeral, not searchable | Permanent, canonical |
| Twitter polls | Platform-locked, biased | Independent, methodology-aware |

## Guiding Principles

1. **Epistemological humility**: All data is approximate (hence "Roughly" and the ≈ symbol)
2. **Transparency**: Show methodology, confidence levels, sample sizes
3. **Accessibility**: Free forever, no premium tiers
4. **Community-driven**: Wikipedia model, not VC-backed growth
5. **Scientific rigor**: Take polling science seriously

## Long-Term Vision

Build the definitive, trusted source for "what do people think/do/prefer" - the place journalists cite, researchers reference, and curious people satisfy their wondering.

Eventually:
- Integrate better identity verification
- Explore blockchain/event sourcing for vote verification
- Consider non-profit structure
- International expansion with localized demographics
