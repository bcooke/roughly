# Glossary

Key terminology for the Roughly project.

---

## Core Concepts

### Question
A poll asking for human opinion or self-reported data. Questions have defined answer options and accumulate responses over time.

**Example**: "Do you like the taste of coffee?"

### Response
A single user's answer to a question. Responses are anonymous but linked to demographic data.

### Answer Option
One possible response to a question. For "Do you like coffee?", the options are "Yes" and "No".

### Vote
Synonym for Response. When a user "votes" on a question, they submit a response.

---

## Demographics & Populations

### Demographic
A categorical attribute describing a user: gender, age range, location, etc.

**Examples**: Male, 25-34, United States, College-educated

### Demographic Category
A grouping of related demographics: "Gender" contains Male, Female, Non-binary, etc.

### Population
Any group of people defined by demographic criteria. Populations can be:
- **Universal**: All respondents
- **Filtered**: All male respondents, all US respondents
- **Intersected**: All male respondents in the US aged 25-34

### Slice
A filtered view of question results for a specific population. "Men" is a slice of the overall results.

---

## Data Concepts

### Breakdown
The demographic tabs on a question page that let users slice results. The mockup shows: Men, Women, US, World.

### Population Overlap
When a user has answered multiple questions, their responses can be combined to answer compound questions.

**Example**: If users answer both "Do you drink coffee?" and "Do you exercise daily?", we can calculate "What percentage of coffee drinkers exercise daily?"

### Factoid
A derived statistic presented as a statement.

**Example**: "72.3% of Americans don't like Lebron James"

### Stat Ticker
The scrolling banner of factoids that appears on the homepage, showing interesting statistics with quick vote CTAs.

---

## Question Types

### Binary Question
Yes/No question with two answer options.

**Example**: "Do you like the taste of coffee?" → Yes / No

### Multiple Choice Question
Question with 3+ predefined answer options.

**Example**: "What's your favorite season?" → Spring / Summer / Fall / Winter

### Scaled Question
Question answered on a numeric scale.

**Example**: "Rate your coffee preference 1-10" → 1, 2, 3... 10

---

## Quality & Trust

### Sample Size
The number of responses to a question. Larger samples provide more statistically significant results.

### Confidence Level
A statistical measure of how reliable the results are given the sample size.

### Bad-Faith Response
A response submitted without genuine intent - random clicking, trolling, or manipulation.

### Methodology
The documented approach for how a question was asked, who was sampled, and any known biases.

---

## Site Structure

### Question Page
The canonical URL for a single question, showing all results and breakdowns.

**URL pattern**: `roughly.io/q/do-you-like-the-taste-of-coffee`

### Category
A topic grouping for questions: Technology, Sports, Entertainment, etc.

### Similar Questions
Related questions shown on a question page to encourage exploration.

---

## User Concepts

### Contributor
A user who answers questions, adding to the database.

### Contribution Requirement
The rule that users must answer questions to access more data - "give to get".

### Identity Verification
(Future) Confirming that a user is a real, unique human to prevent vote manipulation.

---

## Technical Terms

### Event Sourcing
An architecture pattern where every change (vote, edit) is stored as an immutable event. Enables complete audit trails.

### Aggregate
In event sourcing, an entity that processes commands and emits events. Questions and Users are aggregates.

### Projection
A read-optimized view built by replaying events. The vote counts displayed are projections.
