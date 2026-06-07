-- ============================================================
-- UK EV Charging Network Expansion Strategy
-- SQL Analysis
-- Dataset: GOV.UK Electric Vehicle Charging Infrastructure Statistics
-- Project Goal:
-- Identify UK local authorities with EV charging infrastructure gaps
-- and create an expansion priority model for future charger rollout.
-- ============================================================


-- 1. Preview the dataset
SELECT *
FROM uk_ev_charging_combined_long
LIMIT 10;


-- 2. Count total rows
SELECT
    COUNT(*) AS total_rows
FROM uk_ev_charging_combined_long;


-- 3. Count unique local authorities
SELECT
    COUNT(DISTINCT local_authority_code) AS total_local_authorities
FROM uk_ev_charging_combined_long;


-- 4. Check available reporting periods
SELECT DISTINCT
    reporting_period
FROM uk_ev_charging_combined_long
ORDER BY reporting_period;


-- 5. Basic dataset summary
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT local_authority_name) AS total_local_authorities,
    MIN(reporting_period) AS first_period,
    MAX(reporting_period) AS latest_period
FROM uk_ev_charging_combined_long;


-- 6. Check missing values
SELECT
    SUM(CASE WHEN local_authority_code IS NULL THEN 1 ELSE 0 END) AS missing_local_authority_code,
    SUM(CASE WHEN local_authority_name IS NULL THEN 1 ELSE 0 END) AS missing_local_authority_name,
    SUM(CASE WHEN reporting_period IS NULL THEN 1 ELSE 0 END) AS missing_reporting_period,
    SUM(CASE WHEN total_devices IS NULL THEN 1 ELSE 0 END) AS missing_total_devices,
    SUM(CASE WHEN rapid_devices IS NULL THEN 1 ELSE 0 END) AS missing_rapid_devices,
    SUM(CASE WHEN devices_per_100k IS NULL THEN 1 ELSE 0 END) AS missing_devices_per_100k,
    SUM(CASE WHEN rapid_devices_per_100k IS NULL THEN 1 ELSE 0 END) AS missing_rapid_devices_per_100k
FROM uk_ev_charging_combined_long;


-- 7. Check duplicate records
SELECT
    local_authority_code,
    reporting_period,
    COUNT(*) AS record_count
FROM uk_ev_charging_combined_long
GROUP BY
    local_authority_code,
    reporting_period
HAVING COUNT(*) > 1;


-- 8. Latest reporting period data
SELECT *
FROM uk_ev_charging_combined_long
WHERE reporting_period = (
    SELECT MAX(reporting_period)
    FROM uk_ev_charging_combined_long
);


-- 9. Total charging devices by latest period
SELECT
    SUM(total_devices) AS total_public_charging_devices,
    SUM(rapid_devices) AS total_rapid_charging_devices
FROM uk_ev_charging_combined_long
WHERE reporting_period = (
    SELECT MAX(reporting_period)
    FROM uk_ev_charging_combined_long
);


-- 10. Top 10 local authorities by total public chargers
SELECT
    local_authority_name,
    total_devices,
    rapid_devices
FROM uk_ev_charging_combined_long
WHERE reporting_period = (
    SELECT MAX(reporting_period)
    FROM uk_ev_charging_combined_long
)
ORDER BY total_devices DESC
LIMIT 10;


-- 11. Bottom 10 local authorities by total public chargers
SELECT
    local_authority_name,
    total_devices,
    rapid_devices
FROM uk_ev_charging_combined_long
WHERE reporting_period = (
    SELECT MAX(reporting_period)
    FROM uk_ev_charging_combined_long
)
ORDER BY total_devices ASC
LIMIT 10;


-- ============================================================
-- INTERMEDIATE SQL QUERIES
-- Purpose: Create KPIs, rankings, categories, and comparisons
-- ============================================================


-- 12. Create latest-period view for easier analysis
DROP VIEW IF EXISTS ev_latest_period;

CREATE VIEW ev_latest_period AS
SELECT *
FROM uk_ev_charging_combined_long
WHERE reporting_period = (
    SELECT MAX(reporting_period)
    FROM uk_ev_charging_combined_long
);


-- 13. Calculate rapid charger share
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    ROUND(
        rapid_devices * 100.0 / NULLIF(total_devices, 0),
        2
    ) AS rapid_charger_share_pct
FROM ev_latest_period
ORDER BY rapid_charger_share_pct DESC;


-- 14. Identify local authorities with low charging access
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    devices_per_100k,
    rapid_devices_per_100k
FROM ev_latest_period
WHERE devices_per_100k < 50
ORDER BY devices_per_100k ASC;


-- 15. Identify local authorities with weak rapid charging access
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    devices_per_100k,
    rapid_devices_per_100k,
    rapid_charger_share_pct
FROM ev_latest_period
WHERE rapid_devices_per_100k < 10
ORDER BY rapid_devices_per_100k ASC;


-- 16. Create charger access category
SELECT
    local_authority_name,
    total_devices,
    devices_per_100k,
    CASE
        WHEN devices_per_100k < 25 THEN 'Very Low Access'
        WHEN devices_per_100k < 50 THEN 'Low Access'
        WHEN devices_per_100k < 75 THEN 'Moderate Access'
        ELSE 'Strong Access'
    END AS charger_access_category
FROM ev_latest_period
ORDER BY devices_per_100k ASC;


-- 17. Create rapid charger access category
SELECT
    local_authority_name,
    rapid_devices,
    rapid_devices_per_100k,
    CASE
        WHEN rapid_devices_per_100k < 5 THEN 'Very Low Rapid Access'
        WHEN rapid_devices_per_100k < 10 THEN 'Low Rapid Access'
        WHEN rapid_devices_per_100k < 15 THEN 'Moderate Rapid Access'
        ELSE 'Strong Rapid Access'
    END AS rapid_access_category
FROM ev_latest_period
ORDER BY rapid_devices_per_100k ASC;


-- 18. Top 10 local authorities by chargers per 100k population
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    devices_per_100k,
    rapid_devices_per_100k
FROM ev_latest_period
ORDER BY devices_per_100k DESC
LIMIT 10;


-- 19. Bottom 10 local authorities by chargers per 100k population
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    devices_per_100k,
    rapid_devices_per_100k
FROM ev_latest_period
ORDER BY devices_per_100k ASC
LIMIT 10;


-- 20. Local authorities with high total chargers but low rapid charger share
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    rapid_charger_share_pct
FROM ev_latest_period
WHERE total_devices >= 100
  AND rapid_charger_share_pct < 15
ORDER BY rapid_charger_share_pct ASC;


-- 21. Compare total chargers vs rapid chargers
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    total_devices - rapid_devices AS non_rapid_devices,
    ROUND(
        rapid_devices * 100.0 / NULLIF(total_devices, 0),
        2
    ) AS rapid_charger_share_pct
FROM ev_latest_period
ORDER BY total_devices DESC;


-- 22. Average charger access across all local authorities
SELECT
    ROUND(AVG(devices_per_100k), 2) AS avg_devices_per_100k,
    ROUND(AVG(rapid_devices_per_100k), 2) AS avg_rapid_devices_per_100k,
    ROUND(AVG(rapid_charger_share_pct), 2) AS avg_rapid_charger_share_pct
FROM ev_latest_period;


-- 23. Above-average vs below-average charger access
WITH avg_access AS (
    SELECT
        AVG(devices_per_100k) AS avg_devices_per_100k
    FROM ev_latest_period
)

SELECT
    e.local_authority_name,
    e.devices_per_100k,
    ROUND(a.avg_devices_per_100k, 2) AS national_avg_devices_per_100k,
    CASE
        WHEN e.devices_per_100k >= a.avg_devices_per_100k THEN 'Above Average'
        ELSE 'Below Average'
    END AS access_vs_average
FROM ev_latest_period e
CROSS JOIN avg_access a
ORDER BY e.devices_per_100k ASC;


-- ============================================================
-- ADVANCED SQL QUERIES
-- Purpose: Use window functions, CTEs, trend analysis, and scoring
-- ============================================================


-- 24. Rank local authorities nationally by charger access
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    devices_per_100k,
    RANK() OVER (
        ORDER BY devices_per_100k DESC
    ) AS national_access_rank
FROM ev_latest_period
ORDER BY national_access_rank;


-- 25. Rank local authorities nationally by rapid charger access
SELECT
    local_authority_name,
    rapid_devices,
    rapid_devices_per_100k,
    RANK() OVER (
        ORDER BY rapid_devices_per_100k DESC
    ) AS national_rapid_access_rank
FROM ev_latest_period
ORDER BY national_rapid_access_rank;


-- 26. Quartile analysis using NTILE
WITH access_quartiles AS (
    SELECT
        local_authority_name,
        total_devices,
        rapid_devices,
        devices_per_100k,
        rapid_devices_per_100k,
        NTILE(4) OVER (
            ORDER BY devices_per_100k
        ) AS access_quartile
    FROM ev_latest_period
)

SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    devices_per_100k,
    rapid_devices_per_100k,
    access_quartile,
    CASE
        WHEN access_quartile = 1 THEN 'Most Underserved'
        WHEN access_quartile = 2 THEN 'Below Average Access'
        WHEN access_quartile = 3 THEN 'Moderate Access'
        ELSE 'Strong Access'
    END AS access_category
FROM access_quartiles
ORDER BY devices_per_100k ASC;


-- 27. Rapid charging quartile analysis
WITH rapid_quartiles AS (
    SELECT
        local_authority_name,
        rapid_devices,
        rapid_devices_per_100k,
        NTILE(4) OVER (
            ORDER BY rapid_devices_per_100k
        ) AS rapid_access_quartile
    FROM ev_latest_period
)

SELECT
    local_authority_name,
    rapid_devices,
    rapid_devices_per_100k,
    rapid_access_quartile,
    CASE
        WHEN rapid_access_quartile = 1 THEN 'Most Underserved for Rapid Charging'
        WHEN rapid_access_quartile = 2 THEN 'Below Average Rapid Access'
        WHEN rapid_access_quartile = 3 THEN 'Moderate Rapid Access'
        ELSE 'Strong Rapid Access'
    END AS rapid_access_category
FROM rapid_quartiles
ORDER BY rapid_devices_per_100k ASC;


-- 28. Quarter-over-quarter growth using LAG
WITH growth AS (
    SELECT
        local_authority_code,
        local_authority_name,
        reporting_period,
        total_devices,
        LAG(total_devices) OVER (
            PARTITION BY local_authority_code
            ORDER BY reporting_period
        ) AS previous_period_devices
    FROM uk_ev_charging_combined_long
)

SELECT
    local_authority_name,
    reporting_period,
    total_devices,
    previous_period_devices,
    total_devices - previous_period_devices AS device_growth,
    ROUND(
        (total_devices - previous_period_devices) * 100.0
        / NULLIF(previous_period_devices, 0),
        2
    ) AS growth_rate_pct
FROM growth
WHERE previous_period_devices IS NOT NULL
ORDER BY growth_rate_pct DESC;


-- 29. Identify local authorities with declining charger count
WITH growth AS (
    SELECT
        local_authority_code,
        local_authority_name,
        reporting_period,
        total_devices,
        LAG(total_devices) OVER (
            PARTITION BY local_authority_code
            ORDER BY reporting_period
        ) AS previous_period_devices
    FROM uk_ev_charging_combined_long
)

SELECT
    local_authority_name,
    reporting_period,
    total_devices,
    previous_period_devices,
    total_devices - previous_period_devices AS device_change
FROM growth
WHERE previous_period_devices IS NOT NULL
  AND total_devices < previous_period_devices
ORDER BY device_change ASC;


-- 30. Compare latest period vs first period
WITH first_latest AS (
    SELECT
        local_authority_code,
        local_authority_name,

        MAX(CASE
            WHEN reporting_period = (
                SELECT MIN(reporting_period)
                FROM uk_ev_charging_combined_long
            )
            THEN total_devices
        END) AS first_period_devices,

        MAX(CASE
            WHEN reporting_period = (
                SELECT MAX(reporting_period)
                FROM uk_ev_charging_combined_long
            )
            THEN total_devices
        END) AS latest_period_devices

    FROM uk_ev_charging_combined_long
    GROUP BY
        local_authority_code,
        local_authority_name
)

SELECT
    local_authority_name,
    first_period_devices,
    latest_period_devices,
    latest_period_devices - first_period_devices AS total_device_growth,
    ROUND(
        (latest_period_devices - first_period_devices) * 100.0
        / NULLIF(first_period_devices, 0),
        2
    ) AS total_growth_pct
FROM first_latest
WHERE first_period_devices IS NOT NULL
  AND latest_period_devices IS NOT NULL
ORDER BY total_growth_pct DESC;


-- 31. Rolling average of charger access over time
WITH rolling_avg AS (
    SELECT
        local_authority_code,
        local_authority_name,
        reporting_period,
        devices_per_100k,
        ROUND(
            AVG(devices_per_100k) OVER (
                PARTITION BY local_authority_code
                ORDER BY reporting_period
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ),
            2
        ) AS rolling_avg_devices_per_100k
    FROM uk_ev_charging_combined_long
)

SELECT *
FROM rolling_avg
ORDER BY local_authority_name, reporting_period;


-- 32. Create expansion priority scoring model
DROP VIEW IF EXISTS ev_expansion_priority;

CREATE VIEW ev_expansion_priority AS
WITH scored AS (
    SELECT
        local_authority_code,
        local_authority_name,
        reporting_period,
        total_devices,
        rapid_devices,
        devices_per_100k,
        rapid_devices_per_100k,
        rapid_charger_share_pct,

        CASE
            WHEN devices_per_100k < 25 THEN 40
            WHEN devices_per_100k < 50 THEN 30
            WHEN devices_per_100k < 75 THEN 20
            ELSE 10
        END AS access_gap_score,

        CASE
            WHEN rapid_devices_per_100k < 5 THEN 30
            WHEN rapid_devices_per_100k < 10 THEN 20
            WHEN rapid_devices_per_100k < 15 THEN 10
            ELSE 5
        END AS rapid_gap_score,

        CASE
            WHEN total_devices < 25 THEN 30
            WHEN total_devices < 50 THEN 20
            WHEN total_devices < 100 THEN 10
            ELSE 5
        END AS infrastructure_gap_score

    FROM ev_latest_period
)

SELECT
    *,
    access_gap_score + rapid_gap_score + infrastructure_gap_score AS expansion_priority_score,
    CASE
        WHEN access_gap_score + rapid_gap_score + infrastructure_gap_score >= 80 THEN 'High Priority'
        WHEN access_gap_score + rapid_gap_score + infrastructure_gap_score >= 55 THEN 'Medium Priority'
        ELSE 'Low Priority'
    END AS expansion_priority_category
FROM scored;


-- 33. View highest-priority expansion areas
SELECT
    local_authority_name,
    total_devices,
    rapid_devices,
    devices_per_100k,
    rapid_devices_per_100k,
    rapid_charger_share_pct,
    expansion_priority_score,
    expansion_priority_category
FROM ev_expansion_priority
ORDER BY expansion_priority_score DESC
LIMIT 20;


-- 34. Count priority categories
SELECT
    expansion_priority_category,
    COUNT(*) AS local_authority_count
FROM ev_expansion_priority
GROUP BY expansion_priority_category
ORDER BY local_authority_count DESC;


-- 35. Final Power BI output
SELECT *
FROM ev_expansion_priority
ORDER BY expansion_priority_score DESC;
