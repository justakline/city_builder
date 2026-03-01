# city_builder

A simple low-poly (but visually appealing) city-building game focused on creating a city from scratch.

## Vision
Build a clean, approachable city builder where players design infrastructure first, then grow neighborhoods and districts through zoning. The experience should be easy to learn, visually pleasing, and simulation-driven.

## Core Gameplay Loop
1. Start with undeveloped land.
2. Lay down roads and essential infrastructure.
3. Zone plots adjacent to roads.
4. Watch development occur based on population needs, supply chains, and financial systems.
5. Expand infrastructure and rebalance zoning to sustain growth.

## Core Systems

### 1. Grid and Build Geometry
- The world is made from small square tiles.
- Buildings and zones can occupy one tile or many tiles.
- Large footprints do not need to be rectangular.
- Valid footprints are any contiguous combination of smaller square tiles.

### 2. Infrastructure Placement
- Road tools for building connected street networks.
- Infrastructure systems tied to roads (initial focus: utilities and service access).
- Build rules that require road access for development.

### 3. Zoning
- Place zone types on land plots connected to roads.
- Primary zones:
  - Residential
  - Commercial
  - Industrial
- Each primary zone includes multiple sub-zones (to be defined in detail during design).

### 4. Development Rules
- Zoned land develops over time if requirements are met.
- Development depends on factors such as:
  - Road/infrastructure access
  - Nearby land use compatibility
  - Population and employment demand
  - Access to required goods and materials

### 5. Household and Citizen Simulation
Residential households are composed of people with distinct:
- Life stages:
  - School age
  - Working age
  - Retirement age
- Financial budgets across categories:
  - Rent/mortgage
  - Food
  - Utilities
  - Fun
  - Health
  - Education
  - Transportation
- Spending preferences:
  - Different priorities per person/household
  - Preference-influenced decisions for where to live, work, and spend

### 6. Banking and Finance
- Banks provide household mortgages and business loans.
- People can hold savings accounts.
- Loan approval and repayment affect growth, housing access, and business expansion.

### 7. Business, Goods, and Ownership
- Businesses produce products that people can buy.
- Product ownership transfers from businesses to people at point of sale.
- People can discard owned products as trash.
- Trash collection services pick up waste and remove it from residential/commercial areas.

### 8. Supply Chains and Production Dependencies
- Product-producing businesses need input materials.
- Inputs can be:
  - Sourced from local businesses
  - Imported from outside city limits
- Advanced businesses require intermediate products from upstream businesses.
- Example chain:
  - A chair maker store buys wood from a mill.
  - The mill cuts local trees (or sources equivalent material inputs).

### 9. External Market
- The simulation includes a global market outside the playable city boundary.
- Some businesses are allowed to import from this external market.
- External trade helps cover local shortages but may have costs/risks.

### 10. Economy and Demand
- Residential demand driven by housing affordability and quality of life.
- Commercial demand driven by local spending and customer access.
- Industrial demand driven by production/logistics needs and workforce availability.
- Demand responds to credit availability, supply chain stability, and import pricing.

## Initial Scope (MVP)
- Tile/plot-based map with square-tile placement.
- Road placement with basic connectivity validation.
- Residential, commercial, and industrial zoning placement.
- Basic simulation tick that:
  - Spawns households
  - Tracks jobs and basic income/expenses
  - Supports basic banking records (cash, savings, simple loans)
  - Tracks simple product production and consumption
  - Converts zone demand into simple building growth
- Minimal but polished low-poly art style.

## Visual Direction
- Simple low-poly geometry.
- Visually appealing color palette and lighting.
- Clear readability for roads, zone boundaries, building types, and service overlays.

## Open Design Tasks
- Define sub-zones for each primary zone.
- Define exact infrastructure categories and utility simulation depth.
- Specify citizen behavior model and decision weights.
- Define banking rules (interest rates, default handling, loan risk).
- Define product categories and production recipes.
- Define global market pricing and import/export rules.
- Establish win/lose states or sandbox progression goals.
- Select engine/framework and technical architecture.

## Repository Setup Checklist
- [x] Create `city_builder` project folder
- [x] Initialize git repository (`main`)
- [x] Connect repository to GitHub remote
- [x] Create first commit
- [x] Push `main` to GitHub
