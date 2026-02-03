# Design Philosophy

Roughly's visual design serves the data. Every design decision supports clarity, trust, and usability.

---

## Core Principles

### 1. Data is the Hero
Charts, percentages, and vote counts are the primary content. The UI exists to present data clearly, not to draw attention to itself.

### 2. Minimal Chrome
No unnecessary decoration. White space is a feature. Every element earns its place.

### 3. Functional Color
Color has meaning. It's not decorative - it communicates:
- **Red/Orange**: Interactive elements (Vote buttons)
- **Blue**: Data visualization (pie chart segments, bar fills)
- **Green**: Section headers, category indicators
- **Gray**: Neutral UI elements, secondary text
- **White**: Background, clean canvas

### 4. Trust Through Clarity
A site about data must feel trustworthy. Clean typography, clear hierarchy, and transparent methodology build trust.

---

## Color Palette

### Base Colors
| Color | Hex | Usage |
|-------|-----|-------|
| White | `#FFFFFF` | Primary background |
| Light Gray | `#F5F5F5` | Secondary background, cards |
| Medium Gray | `#9E9E9E` | Secondary text, borders |
| Dark Gray | `#333333` | Primary text |
| Black | `#000000` | Headlines, logo |

### Functional Colors
| Color | Hex | Usage |
|-------|-----|-------|
| Action Red | `#E53935` | Vote buttons, CTAs |
| Data Blue | `#1E88E5` | Charts, progress bars, links |
| Section Green | `#4CAF50` | Section headers (Breakdowns, Similar Questions) |
| Warning Amber | `#FFA000` | Warnings, low confidence |
| Error Red | `#D32F2F` | Errors, invalid states |
| Success Green | `#388E3C` | Success confirmations |

---

## Typography

### Hierarchy
1. **Question Text**: Large, bold, black - the most prominent element
2. **Vote Count**: Accent color (green or blue), draws attention to sample size
3. **Percentages**: Bold, in-context with data visualization
4. **Body Text**: Regular weight, dark gray
5. **Labels**: Small, medium gray

### Font Choices
Sans-serif throughout for clarity:
- **Headlines**: Bold, high contrast
- **Body**: Regular weight, comfortable reading
- **Data**: Tabular/monospace numerals for alignment

---

## Layout Patterns

### Question Page Layout
```
┌─────────────────────────────────────────────┐
│ [Logo]              [Nav Categories]   [Auth]│
├─────────────────────────────────────────────┤
│ [Stat Ticker with Vote CTA]                 │
├─────────────────────────────────────────────┤
│ [Search Bar]                      [Search!] │
├─────────────────────────────────────────────┤
│                                             │
│ Question Text?            Vote Count        │
│                                             │
│ [Vote!] 1) Option A  ████████░░ 60%  ┌────┐ │
│ [Vote!] 2) Option B  ████░░░░░░ 40%  │ 🥧 │ │
│                                      └────┘ │
├─────────────────────────────────────────────┤
│ [Breakdowns]                                │
│ Men | Women | US | World                    │
├─────────────────────────────────────────────┤
│ [Similar Questions]                         │
│ Related question 1?           Vote Count    │
│ [Vote!] Options with bars and pie...        │
└─────────────────────────────────────────────┘
```

### Information Hierarchy
1. **Navigation** - Always accessible, not prominent
2. **Search** - Central, Google-style prominence
3. **Question** - The star of the page
4. **Results** - Vote buttons, percentages, chart
5. **Breakdowns** - Demographic slices
6. **Discovery** - Similar questions

---

## Component Design

### Vote Button
- Red/orange background
- White text
- Clear "Vote!" label
- Prominent but not overwhelming
- State changes: default → hover → voted

### Progress Bars
- Blue fill on light background
- Percentage label inside or adjacent
- Vote count in parentheses
- Clean edges, subtle rounding

### Pie Charts
- Two-color for binary questions (red/blue per the mockup)
- Clear segment labels
- Legends for multi-option

### Section Headers
- Green background
- White text
- Full-width bar
- Clear section delineation

---

## Responsive Considerations

### Mobile
- Stack vote options vertically
- Pie chart below or hidden
- Collapsible breakdowns
- Search remains prominent

### Desktop
- Side-by-side vote options and chart
- All breakdowns visible as tabs
- More similar questions visible

---

## Inspiration

### FiveThirtyEight
Statistical credibility, clean data presentation, trust through transparency.

### Wikipedia
Information density without clutter, neutral presentation, community feel.

### Google Search
Search-first experience, clean homepage, fast results.

---

## Logo

The ≈ (approximately equal) symbol represents:
- **Roughly** - approximate, not exact
- **Equality** - data for everyone
- **Mathematics** - statistical foundation

Paired with "APPROXIMATE.LY" or "ROUGHLY" wordmark in clean sans-serif.

---

## Anti-Patterns (What We Avoid)

- **Visual noise**: No gradients, shadows, or decoration for its own sake
- **Dark patterns**: No tricks to get votes or engagement
- **Advertising aesthetic**: No banner-ad energy
- **Social media feed**: No infinite scroll dopamine design
- **Paywalls**: No "sign up to see more" gates on data
