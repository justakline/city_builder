# city_builder

A simple low-poly (but visually appealing) city-building game focused on creating a city from scratch.

## Vision
Build a clean, approachable city builder where players design infrastructure first, then grow neighborhoods and districts through zoning. The experience should be easy to learn, visually pleasing, and simulation-driven.

## Core Gameplay Loop
1. Start with undeveloped land.
2. Lay down roads and essential infrastructure.
3. Zone plots adjacent to roads.
4. Watch development occur based on population needs and economic factors.
5. Expand infrastructure and rebalance zoning to sustain growth.

## Core Systems

### 1. Infrastructure Placement
- Road tools for building connected street networks.
- Infrastructure systems tied to roads (initial focus: utilities and service access).
- Build rules that require road access for development.

### 2. Zoning
- Place zone types on land plots connected to roads.
- Primary zones:
  - Residential
  - Commercial
  - Industrial
- Each primary zone includes multiple sub-zones (to be defined in detail during design).

### 3. Development Rules
- Zoned land develops over time if requirements are met.
- Development depends on factors such as:
  - Road/infrastructure access
  - Nearby land use compatibility
  - Population and employment demand

### 4. Household and Citizen Simulation
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

### 5. Economy and Demand
- Residential demand driven by housing affordability and quality of life.
- Commercial demand driven by local spending and customer access.
- Industrial demand driven by production/logistics needs and workforce availability.

## Initial Scope (MVP)
- Tile/plot-based map.
- Road placement with basic connectivity validation.
- Residential, commercial, and industrial zoning placement.
- Basic simulation tick that:
  - Spawns households
  - Tracks jobs and basic income/expenses
  - Converts zone demand into simple building growth
- Minimal but polished low-poly art style.

## Visual Direction
- Simple low-poly geometry.
- Visually appealing color palette and lighting.
- Clear readability for roads, zone boundaries, and building types.

## Open Design Tasks
- Define sub-zones for each primary zone.
- Define exact infrastructure categories and utility simulation depth.
- Specify citizen behavior model and decision weights.
- Establish win/lose states or sandbox progression goals.
- Select engine/framework and technical architecture.

## Repository Setup Checklist
- [x] Create `city_builder` project folder
- [x] Initialize git repository (`main`)
- [ ] Connect repository to GitHub remote
- [ ] Create first commit
