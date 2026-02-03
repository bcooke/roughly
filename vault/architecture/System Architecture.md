# System Architecture

Roughly is built on Phoenix/Elixir with event sourcing via Commanded.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      Browser                            │
│                   (LiveView Client)                     │
└─────────────────────┬───────────────────────────────────┘
                      │ WebSocket / HTTP
┌─────────────────────▼───────────────────────────────────┐
│                   Phoenix Web                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  LiveView   │  │  REST API   │  │  Static Assets  │  │
│  │   Pages     │  │  (optional) │  │                 │  │
│  └──────┬──────┘  └──────┬──────┘  └─────────────────┘  │
└─────────┼────────────────┼──────────────────────────────┘
          │                │
┌─────────▼────────────────▼──────────────────────────────┐
│                   Core Domain                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  Questions  │  │   Voting    │  │  Demographics   │  │
│  │  Aggregate  │  │  Aggregate  │  │   Aggregate     │  │
│  └──────┬──────┘  └──────┬──────┘  └───────┬─────────┘  │
└─────────┼────────────────┼─────────────────┼────────────┘
          │                │                 │
┌─────────▼────────────────▼─────────────────▼────────────┐
│                   Commanded                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  Commands   │  │   Events    │  │   Projections   │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                   PostgreSQL                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Event Store │  │ Read Models │  │    Sessions     │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Technology Choices

### Phoenix Framework
- **Why**: Elixir's concurrency model handles high vote throughput; LiveView provides real-time updates without JavaScript complexity
- **Version**: Phoenix 1.7+ with LiveView

### Commanded (Event Sourcing)
- **Why**: Every vote is an immutable event, enabling complete audit trails, temporal queries, and eventual consistency
- **Pattern**: CQRS (Command Query Responsibility Segregation)

### PostgreSQL
- **Why**: Reliable, well-supported, works well with Commanded's event store
- **Usage**: Event storage + read model projections

### LiveView
- **Why**: Real-time vote count updates, interactive filtering, minimal client-side code
- **Pattern**: Server-rendered with WebSocket push

---

## Domain Model

### Aggregates

**Question Aggregate**
- Handles: CreateQuestion, UpdateQuestion, CloseQuestion
- Emits: QuestionCreated, QuestionUpdated, QuestionClosed
- State: question text, answer options, category, status

**Vote Aggregate** (per question)
- Handles: CastVote, RetractVote
- Emits: VoteCast, VoteRetracted
- State: vote counts per answer option

**User Aggregate**
- Handles: RegisterUser, UpdateDemographics, VerifyIdentity
- Emits: UserRegistered, DemographicsUpdated, IdentityVerified
- State: demographic attributes, verification status

### Read Models (Projections)

**QuestionSummary**
- Aggregates vote counts per question
- Indexed for search
- Cached for fast homepage display

**DemographicBreakdown**
- Vote counts sliced by demographic
- Enables "Men vs Women" comparisons
- Materialized for fast queries

**PopulationOverlap**
- Cross-question analysis
- Enables "Coffee drinkers who exercise" queries
- Computationally expensive, cached aggressively

---

## Event Flow Example

```
User clicks "Vote Yes" on "Do you like coffee?"
         │
         ▼
┌─────────────────────┐
│   CastVote Command  │
│   - question_id     │
│   - user_id         │
│   - answer: "yes"   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Vote Aggregate    │
│   - Validates       │
│   - Checks not dup  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   VoteCast Event    │
│   - question_id     │
│   - user_id         │
│   - answer: "yes"   │
│   - demographics    │
│   - timestamp       │
└──────────┬──────────┘
           │
           ├─────────────────┐
           ▼                 ▼
┌─────────────────┐  ┌─────────────────┐
│ QuestionSummary │  │ Demographic     │
│   Projector     │  │   Projector     │
│ (updates count) │  │ (updates slice) │
└─────────────────┘  └─────────────────┘
           │                 │
           ▼                 ▼
┌─────────────────────────────────────┐
│         LiveView Push               │
│   (real-time count update)          │
└─────────────────────────────────────┘
```

---

## Application Structure

```
roughly/
├── lib/
│   ├── roughly/                    # Core domain
│   │   ├── questions/              # Question aggregate & events
│   │   ├── voting/                 # Vote aggregate & events
│   │   ├── users/                  # User aggregate & events
│   │   ├── demographics/           # Demographic definitions
│   │   └── projections/            # Read models
│   ├── roughly_web/                # Phoenix web layer
│   │   ├── live/                   # LiveView modules
│   │   ├── controllers/            # REST API (if needed)
│   │   ├── components/             # UI components
│   │   └── templates/              # HTML templates
│   └── roughly.ex                  # Application entry
├── config/                         # Environment configs
├── priv/
│   ├── repo/migrations/            # Read model migrations
│   └── static/                     # Static assets
└── test/                           # Tests mirror lib/ structure
```

---

## Key Design Decisions

### Event Sourcing from Day One
- **Decision**: Use Commanded for all state changes
- **Rationale**: Vote auditing is critical; event sourcing provides complete history
- **Trade-off**: More complex than simple CRUD, but worth it for this domain

### LiveView Over SPA
- **Decision**: Server-rendered LiveView instead of React/Vue
- **Rationale**: Simpler stack, real-time updates built-in, SEO-friendly
- **Trade-off**: Requires persistent WebSocket connections

### PostgreSQL for Everything
- **Decision**: Single database for events and projections
- **Rationale**: Simpler ops, transactional consistency between event store and projections
- **Trade-off**: May need to shard later for scale

### Anonymous Voting with Demographics
- **Decision**: Votes are anonymous but linked to demographic data
- **Rationale**: Privacy + useful demographic breakdowns
- **Trade-off**: Harder to detect bad-faith voting patterns

---

## Scalability Considerations

### Current (MVP)
- Single Phoenix node
- Single PostgreSQL instance
- Commanded with in-memory event handlers

### Future (Growth)
- Multiple Phoenix nodes behind load balancer
- PostgreSQL read replicas for projections
- Redis for caching hot questions
- Separate event store (EventStore DB) if needed
- Background workers for expensive projections

---

## Security Model

### Authentication
- Session-based auth for contributors
- Optional social login (future)
- Consider verified identity tiers

### Authorization
- Anyone can view questions and results
- Must be authenticated to vote
- Admin role for question moderation

### Data Protection
- Demographics stored separately from votes
- No PII in event streams
- GDPR-compliant deletion (event redaction)

---

## Integration Points

### Search
- PostgreSQL full-text search initially
- Consider Elasticsearch/Meilisearch for scale

### Analytics
- Event stream enables custom analytics
- Can replay events to build new projections

### API (Future)
- REST or GraphQL for third-party access
- Rate limited, possibly API keys
