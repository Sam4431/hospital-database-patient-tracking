
-- =========================================================================
-- STAGE 2: QUERY DEVELOPMENT
-- Project: Healthcare Data Analytics
-- Run after Stage 1 has successfully created and populated the tables.
-- =========================================================================


-- =========================================================================
-- BUSINESS QUESTION 1:
-- Which departments have the highest estimated average length of stay?
-- Note: Stay is categorical, so midpoints are used as estimates.
-- =========================================================================

SELECT
    d.Department_Name,
    COUNT(a.case_id) AS total_admissions,
    ROUND(
        AVG(
            CASE a.Stay
                WHEN '0-10' THEN 5
                WHEN '11-20' THEN 15
                WHEN '21-30' THEN 25
                WHEN '31-40' THEN 35
                WHEN '41-50' THEN 45
                WHEN '51-60' THEN 55
                WHEN '61-70' THEN 65
                WHEN '71-80' THEN 75
                WHEN '81-90' THEN 85
                WHEN '91-100' THEN 95
                WHEN 'More than 100 Days' THEN 105
                ELSE NULL
            END
        ),
        2
    ) AS estimated_avg_length_of_stay_days
FROM admissions a
JOIN departments d
    ON a.department_id = d.department_id
GROUP BY d.Department_Name
ORDER BY estimated_avg_length_of_stay_days DESC;


-- =========================================================================
-- BUSINESS QUESTION 2:
-- How does the severity distribution vary by facility?
-- Note: This query does not calculate 30-day readmissions.
-- =========================================================================

SELECT
    f.Hospital_code,
    f.Hospital_type_code,
    f.Hospital_region_code,
    a.`Severity of Illness`,
    COUNT(a.case_id) AS total_admissions,
    ROUND(
        COUNT(a.case_id) * 100.0
        / SUM(COUNT(a.case_id)) OVER (
            PARTITION BY f.Hospital_code
        ),
        2
    ) AS percentage_share_at_facility
FROM admissions a
JOIN facilities f
    ON a.Hospital_code = f.Hospital_code
GROUP BY
    f.Hospital_code,
    f.Hospital_type_code,
    f.Hospital_region_code,
    a.`Severity of Illness`
ORDER BY
    f.Hospital_code,
    total_admissions DESC;


-- =========================================================================
-- BUSINESS QUESTION 3:
-- Which age groups account for the highest proportion of emergency admissions?
-- =========================================================================

SELECT
    p.Age AS age_group,
    SUM(
        CASE
            WHEN a.`Type of Admission` = 'Emergency' THEN 1
            ELSE 0
        END
    ) AS emergency_admissions,
    COUNT(a.case_id) AS total_admissions_in_group,
    ROUND(
        SUM(
            CASE
                WHEN a.`Type of Admission` = 'Emergency' THEN 1
                ELSE 0
            END
        ) * 100.0
        / (
            SELECT COUNT(*)
            FROM admissions
            WHERE `Type of Admission` = 'Emergency'
        ),
        2
    ) AS share_of_all_emergencies_pct,
    ROUND(
        SUM(
            CASE
                WHEN a.`Type of Admission` = 'Emergency' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(a.case_id),
        2
    ) AS emergency_rate_within_group_pct
FROM admissions a
JOIN patients p
    ON a.patientid = p.patientid
GROUP BY p.Age
ORDER BY emergency_admissions DESC;


-- =========================================================================
-- BUSINESS QUESTION 4:
-- How do admission volume, room availability, and estimated stay duration
-- vary by facility?
-- Note: These metrics do not measure actual bed occupancy.
-- =========================================================================

SELECT
    f.Hospital_code,
    f.Hospital_type_code,
    f.Hospital_region_code,
    COUNT(a.case_id) AS total_admissions,
    ROUND(
        AVG(a.`Available Extra Rooms in Hospital`),
        2
    ) AS avg_available_extra_rooms,
    ROUND(
        AVG(a.Bed_Grade),
        2
    ) AS avg_bed_grade,
    ROUND(
        AVG(
            CASE a.Stay
                WHEN '0-10' THEN 5
                WHEN '11-20' THEN 15
                WHEN '21-30' THEN 25
                WHEN '31-40' THEN 35
                WHEN '41-50' THEN 45
                WHEN '51-60' THEN 55
                WHEN '61-70' THEN 65
                WHEN '71-80' THEN 75
                WHEN '81-90' THEN 85
                WHEN '91-100' THEN 95
                WHEN 'More than 100 Days' THEN 105
                ELSE NULL
            END
        ),
        2
    ) AS estimated_avg_length_of_stay_days
FROM admissions a
JOIN facilities f
    ON a.Hospital_code = f.Hospital_code
GROUP BY
    f.Hospital_code,
    f.Hospital_type_code,
    f.Hospital_region_code
ORDER BY total_admissions DESC;


-- =========================================================================
-- END OF STAGE 2
-- =========================================================================
