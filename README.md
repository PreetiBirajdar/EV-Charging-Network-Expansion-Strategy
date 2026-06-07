# ⚡ EV Charging Network Expansion Strategy

## Project Overview

This case study analyzes public electric vehicle charging infrastructure in the UK to support data-driven network expansion decisions. Using Excel, SQL, and Power BI, the project evaluates charging availability, geographic coverage, rapid charging access, and potential infrastructure gaps to identify priority areas for future expansion.

## Business Problem

As electric vehicle adoption increases, public charging networks must expand strategically to improve accessibility and support future transport needs. Uneven charger distribution can lead to limited charging access in some local authorities, weaker rapid charging availability, and inefficient infrastructure planning.

This project addresses the need to identify which UK local authorities may require additional charging infrastructure and how expansion decisions can be guided by charger availability, rapid charging access, and location-based gap analysis.

## Objectives
- Assess EV charging demand across locations
- Identify underserved or high-opportunity areas
- Analyze charger utilization and infrastructure gaps
- Support location prioritization for network expansion
- Present findings through an interactive Power BI dashboard

## Data

This project uses UK public EV charging infrastructure data from GOV.UK.

The dataset was prepared in two stages:

### Raw Data
The raw data files contain separate EV charging metrics:
- `ev_total_devices.csv` — total public EV charging devices
- `ev_rapid_devices.csv` — rapid public EV charging devices
- `ev_total_per_100k.csv` — total devices per 100,000 population
- `ev_rapid_per_100k.csv` — rapid devices per 100,000 population

### Cleaned Data
The cleaned files were created for SQL analysis and Power BI dashboarding:
- `uk_ev_charging_combined_data.csv` — combined long-format dataset used for SQL analysis
- `ev_expansion_priority_powerbi.csv` — final SQL output used for Power BI dashboarding

Data source: GOV.UK Electric Vehicle Charging Infrastructure Statistics.

## Tools Used
- **Excel** – Initial data review, cleaning, validation, and preparation of raw EV charging datasets
- **SQL** – Data validation, transformation, CTEs, window functions, ranking, segmentation, trend analysis, and expansion-priority scoring
- **Power BI** – Interactive dashboard development, KPI tracking, local authority gap analysis, and visual storytelling for EV charging network expansion

## SQL Analysis

SQL was used to validate, transform, and analyze the UK EV charging infrastructure dataset before dashboard development.

The SQL analysis includes:

- Data preview and quality checks
- Missing value and duplicate checks
- Latest-period analysis
- Charger access ranking
- Rapid charger share calculation
- Underserved local authority identification
- Quartile analysis using `NTILE()`
- Ranking using `RANK()`
- Trend analysis using `LAG()`
- Expansion priority scoring using CTEs and `CASE WHEN`
- Final SQL output for Power BI dashboarding

SQL file: [`sql/uk_ev_charging_analysis.sql`](sql/uk_ev_charging_analysis.sql)

## SQL Screenshots

### Advanced SQL Query

<img width="1369" height="939" alt="Advanced SQL Query Screenshot" src="YOUR_SQL_QUERY_SCREENSHOT_URL_HERE" />

### SQLite Data Preview

<img width="1369" height="939" alt="SQLite Data Preview Screenshot" src="YOUR_SQL_DATA_PREVIEW_SCREENSHOT_URL_HERE" />

## Dashboard Preview
Dashboard screenshot will be added here.

## Key Insights
- Key insights will be added after completing the dashboard analysis.
- The analysis will highlight areas with stronger charging demand and potential infrastructure gaps.
- Utilization and geographic patterns will help identify expansion priorities.

## Recommendations
- Prioritize expansion in locations showing strong demand and limited current coverage.
- Use utilization trends to avoid overbuilding in low-demand areas.
- Monitor charging access, demand growth, and geographic equity over time.
- Incorporate dashboard findings into infrastructure planning and investment decisions.
