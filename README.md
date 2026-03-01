# city_builder

A simple low-poly (but visually appealing) city-building game focused on creating a city from scratch.

## Vision
Build a clean, approachable city builder where players design infrastructure first, then grow neighborhoods and districts through zoning. The experience should be easy to learn, visually pleasing, and simulation-driven.

## Core Gameplay Loop
1. Start with undeveloped land.
2. Lay down roads and essential infrastructure.
3. Zone plots adjacent to roads.
4. Watch development occur based on population needs, supply chains, transport options, and financial systems.
5. Tune taxes, services, regulations, and trade policy to keep the economy stable and growing.

## Game Modes and Progression

### A. Creative Mode
- All tools, zones, buildings, services, and policies are unlocked from the start.
- Intended for sandbox building and rapid prototyping.

### B. Regular Mode (Progression)
- Start with only essential city-building capabilities unlocked.
- New systems unlock as the city grows, primarily via population milestones.
- Unlock logic should reflect realistic city scale.
- Example:
  - Small towns cannot unlock skyscrapers until higher population tiers are reached.

### C. Challenge Mode (Race to Population Target)
- Timed mode focused on reaching a target population as fast as possible.
- Default target: 100,000 residents (configurable in game setup).
- Clock starts at city start and stops when target population is sustained for a defined period.
- Score is based on completion time, with optional penalties for severe instability (for example, budget collapse or extreme service failure).

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
- Public transit build tools (metro lines/stations, bus routes/stops).

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
  - Mobility access (jobs/services reachable by transit or car)
  - Applicable zoning/building regulations

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
- Travel mode preferences:
  - Choose between public transit and private car based on cost, time, and availability.
- Demographic dynamics:
  - Population grows through migration and births.
  - Births increase household size and can trigger relocation demand for larger homes.

### 6. Housing Types and Capacity
- Support multiple housing types with different:
  - Unit sizes / room counts
  - Density levels (low, medium, high)
  - Parking provision
  - Affordability levels
- Households choose housing based on budget, preferences, household size, commute, and regulations.

### 7. Banking and Finance
- Banks provide household mortgages and business loans.
- People can hold savings accounts.
- Loan approval and repayment affect growth, housing access, and business expansion.

### 8. Business, Goods, and Ownership
- Businesses produce products that people can buy.
- Product ownership transfers from businesses to people at point of sale.
- People can discard owned products as trash.
- Trash collection services pick up waste and remove it from residential/commercial areas.

### 9. Supply Chains and Production Dependencies
- Product-producing businesses need input materials.
- Inputs can be:
  - Sourced from local businesses
  - Imported from outside city limits
- Advanced businesses require intermediate products from upstream businesses.
- Example chain:
  - A chair maker store buys wood from a mill.
  - The mill cuts local trees (or sources equivalent material inputs).

### 10. Circular City Economy
- The city economy should model circular internal flows of money, labor, goods, and waste.
- Local inputs and outputs should feed each other through households, firms, banks, and services.
- Economic failures should emerge when circular dependencies break (shortages, bankruptcies, unemployment, congestion).

### 11. External Market and Migration
- The simulation includes a global market outside the playable city boundary.
- The player cannot directly control the external/global economy.
- Some businesses are allowed to import from this external market.
- City businesses can also export selected outputs to the global market.
- External trade helps cover local shortages but introduces price volatility and dependency risk.
- New residents can migrate in from outside the city.
- Migration is influenced by city attractiveness factors such as:
  - Tax burden
  - Service quality
  - Crime/safety
  - Housing affordability and availability
  - Job availability and wage levels

### 12. Transportation and Parking
- Residents can commute and travel by:
  - Public transit (metro, bus, etc.)
  - Private car
- Car travel requires parking at origin and destination where applicable.
- Parking supply and pricing impact mode choice, congestion, and land use outcomes.

### 13. Tax and Fiscal Policy
- The player has full control over city taxation policy.
- Taxes can be configured on most transaction classes, including:
  - Property taxes
  - Sales taxes
  - Goods-category taxes
  - Industry-specific business taxes
  - Income taxes
  - Wealth taxes
  - Toll/road-use taxes
  - Optional taxes on other transaction types where supported by the simulation
- Progressive tax defaults (real-world aligned):
  - Income tax: progressive brackets with user-defined rates and ranges
  - Wealth tax: progressive brackets with user-defined rates and ranges
  - Property tax: can be flat or banded/progressive by value tier
- Flat tax defaults (real-world aligned):
  - Sales tax
  - Toll tax
  - Most goods and industry transaction taxes
- All tax schedules should be user-editable, with the option to switch between flat and bracketed structures where sensible.

### 14. Regulations and Incentives
- The player can enforce planning/building regulations, including:
  - Minimum parking standards
  - Maximum building height
  - Minimum building height (where applicable)
  - Energy-efficiency requirements (for example, high-efficiency homes)
- Policy incentives should support targeted housing outcomes, including:
  - Tax incentives for specific housing types (for example, high-density one-bedroom units)
  - Subsidy-like policy levers to influence development mix and affordability

### 15. Economy and Demand
- Residential demand driven by housing affordability and quality of life.
- Commercial demand driven by local spending and customer access.
- Industrial demand driven by production/logistics needs and workforce availability.
- Demand responds to credit availability, supply chain stability, import/export pricing, policy constraints, and tax burden.

### 16. Metrics and Observability
Key metrics should be recorded over time for analysis and balancing:
- Population, households, employment, unemployment
- Birth rate, migration inflow/outflow, household size distribution
- Household income distribution, savings, debt, default rates
- Business output, inventory, profitability, bankruptcy rates
- Price indices (local and imported goods)
- Import/export volumes and trade balance
- Tax revenue by category and total city budget
- Transit ridership, car usage share, congestion, parking occupancy
- Land value, rent levels, housing supply mix, and affordability
- Service quality indicators (waste collection coverage, utility reliability, crime/safety)
- Unlock progression status by population tier
- Challenge mode metrics (elapsed time, split times by milestone, best completion time)

## Initial Scope (MVP)
- Tile/plot-based map with square-tile placement.
- Road placement with basic connectivity validation.
- Residential, commercial, and industrial zoning placement.
- Basic public transit (single bus line type) and private car routing.
- Basic parking requirement for car destinations.
- Two game modes:
  - Creative mode with all core tools unlocked
  - Regular mode with population-based unlock milestones
- Challenge mode:
  - Timed race to a target population (default 100,000)
  - Tracks completion time and milestone splits
- Basic simulation tick that:
  - Spawns households
  - Tracks jobs and basic income/expenses
  - Supports basic banking records (cash, savings, simple loans)
  - Tracks simple product production and consumption
  - Supports local sourcing plus basic imports
  - Applies configurable taxes (initially: property, sales, income)
  - Simulates migration inflow from external population pool
  - Simulates births and household growth pressure
  - Converts zone demand into simple building growth
- Basic policy controls:
  - Max height limit
  - Min parking standard
  - One housing tax incentive toggle
- Metrics dashboard with core KPIs.
- Minimal but polished low-poly art style.

## Visual Direction
- Simple low-poly geometry.
- Visually appealing color palette and lighting.
- Clear readability for roads, zone boundaries, building types, traffic, transit lines, and service overlays.

## Open Design Tasks
- Define sub-zones for each primary zone.
- Define exact infrastructure categories and utility simulation depth.
- Specify citizen behavior model and decision weights.
- Define banking rules (interest rates, default handling, loan risk).
- Define product categories and production recipes.
- Define global market pricing model and import/export constraints.
- Define migration attractiveness formula and birth/family model.
- Define progression unlock table by population milestone.
- Define tax UI and rule engine (flat vs progressive schedule authoring).
- Define parking mechanics in detail (on-street, lots, private parking minimums).
- Define housing taxonomy (unit sizes, parking ratios, density bands).
- Define policy/regulation conflict resolution when multiple rules overlap.
- Establish win/lose states or sandbox progression goals.
- Select engine/framework and technical architecture.

## Repository Setup Checklist
- [x] Create `city_builder` project folder
- [x] Initialize git repository (`main`)
- [x] Connect repository to GitHub remote
- [x] Create first commit
- [x] Push `main` to GitHub
