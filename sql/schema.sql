
-- ============================================================================
-- Project: Healthcare Data Analytics
-- Stage 1: Raw Data Import and Data Quality Audit
-- Database: hospital_db
--
-- Purpose:
--   1. Verify raw dataset sizes and case identifiers.
--   2. Check patient identifiers and train/test overlap.
--   3. Validate numerical field formats.
--   4. Inspect category distributions.
--   5. Check consistency of hospital identifiers.
--
-- Raw tables:
--   train_raw: 318,438 records; includes Stay.
--   test_raw:  137,057 records; does not include Stay.
--
-- NOTE:
--   The CSV columns were imported as TEXT. The raw tables are retained
--   unchanged during the audit.
-- ============================================================================

USE hospital_db;


-- ============================================================================
-- 1. DATASET SIZE AND CASE ID CHECKS
-- ============================================================================
-- COUNT(*) counts all records.
-- COUNT(DISTINCT case_id) counts unique case identifiers.
-- Matching counts indicate no duplicate case IDs among non-NULL values,
-- provided there are no missing case IDs.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT case_id) AS unique_case_ids,
    SUM(case_id IS NULL OR TRIM(case_id) = '') AS missing_case_ids
FROM train_raw;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT case_id) AS unique_case_ids,
    SUM(case_id IS NULL OR TRIM(case_id) = '') AS missing_case_ids
FROM test_raw;


-- ============================================================================
-- 2. PATIENT AND HOSPITAL IDENTIFIER CHECKS
-- ============================================================================
-- A patient may have multiple case records.
-- Hospital_code identifies a facility in the source dataset.

SELECT
    COUNT(*) AS total_cases,
    COUNT(DISTINCT patientid) AS unique_patients,
    SUM(patientid IS NULL OR TRIM(patientid) = '') AS missing_patient_ids,
    COUNT(DISTINCT Hospital_code) AS unique_hospitals,
    SUM(Hospital_code IS NULL OR TRIM(Hospital_code) = '')
        AS missing_hospital_codes
FROM train_raw;

SELECT
    COUNT(*) AS total_cases,
    COUNT(DISTINCT patientid) AS unique_patients,
    SUM(patientid IS NULL OR TRIM(patientid) = '') AS missing_patient_ids,
    COUNT(DISTINCT Hospital_code) AS unique_hospitals,
    SUM(Hospital_code IS NULL OR TRIM(Hospital_code) = '')
        AS missing_hospital_codes
FROM test_raw;


-- ============================================================================
-- 3. CHECK FOR PATIENT ID OVERLAP BETWEEN TRAIN AND TEST
-- ============================================================================
-- This counts distinct patient IDs present in both datasets.
-- Zero overlap was observed during the initial audit.

SELECT
    COUNT(DISTINCT t.patientid) AS patients_in_both_datasets
FROM train_raw AS t
INNER JOIN test_raw AS s
    ON t.patientid = s.patientid;


-- ============================================================================
-- 4. MISSING VALUES IN TEST DATA
-- ============================================================================
-- The CSV import may represent empty cells as empty strings instead of NULL.
-- Check both conditions.
-- Initial audit found missing bed grades and patient-city codes.

SELECT
    COUNT(*) AS total_rows,
    SUM(`Bed Grade` IS NULL OR TRIM(`Bed Grade`) = '')
        AS missing_bed_grade,
    SUM(City_Code_Patient IS NULL OR TRIM(City_Code_Patient) = '')
        AS missing_city_code_patient
FROM test_raw;


-- ============================================================================
-- 5. NUMERICAL FIELD FORMAT VALIDATION
-- ============================================================================
-- REGEXP checks whether values follow expected numeric formats.
-- These checks validate format, not whether values are clinically or
-- operationally reasonable.

-- Training dataset

SELECT
    SUM(
        TRIM(`Available Extra Rooms in Hospital`) = ''
        OR `Available Extra Rooms in Hospital` NOT REGEXP '^[0-9]+$'
    ) AS invalid_extra_rooms,

    SUM(
        TRIM(Admission_Deposit) = ''
        OR Admission_Deposit NOT REGEXP '^[0-9]+([.][0-9]+)?$'
    ) AS invalid_deposits,

    SUM(
        TRIM(`Visitors with Patient`) = ''
        OR `Visitors with Patient` NOT REGEXP '^[0-9]+$'
    ) AS invalid_visitors
FROM train_raw;


-- Test dataset

SELECT
    SUM(
        TRIM(`Available Extra Rooms in Hospital`) = ''
        OR `Available Extra Rooms in Hospital` NOT REGEXP '^[0-9]+$'
    ) AS invalid_extra_rooms,

    SUM(
        TRIM(Admission_Deposit) = ''
        OR Admission_Deposit NOT REGEXP '^[0-9]+([.][0-9]+)?$'
    ) AS invalid_deposits,

    SUM(
        TRIM(`Visitors with Patient`) = ''
        OR `Visitors with Patient` NOT REGEXP '^[0-9]+$'
    ) AS invalid_visitors
FROM test_raw;


-- ============================================================================
-- 6. NUMERICAL RANGES IN TRAINING DATA
-- ============================================================================
-- MIN and MAX provide an initial range check.
-- Values still require contextual interpretation.

SELECT
    MIN(CAST(`Available Extra Rooms in Hospital` AS SIGNED))
        AS min_extra_rooms,
    MAX(CAST(`Available Extra Rooms in Hospital` AS SIGNED))
        AS max_extra_rooms,
    MIN(CAST(Admission_Deposit AS DECIMAL(12,2)))
        AS min_deposit,
    MAX(CAST(Admission_Deposit AS DECIMAL(12,2)))
        AS max_deposit,
    MIN(CAST(`Visitors with Patient` AS SIGNED))
        AS min_visitors,
    MAX(CAST(`Visitors with Patient` AS SIGNED))
        AS max_visitors
FROM train_raw;


-- ============================================================================
-- 7. CATEGORY COUNTS IN TRAINING DATA
-- ============================================================================
-- COUNT(DISTINCT ...) counts different values in each column.

SELECT COUNT(DISTINCT Department) AS department_categories
FROM train_raw;

SELECT COUNT(DISTINCT `Type of Admission`) AS admission_type_categories
FROM train_raw;

SELECT COUNT(DISTINCT `Severity of Illness`) AS severity_categories
FROM train_raw;

SELECT COUNT(DISTINCT Age) AS age_categories
FROM train_raw;

SELECT COUNT(DISTINCT Stay) AS stay_categories
FROM train_raw;


-- ============================================================================
-- 8. STAY CATEGORY DISTRIBUTION
-- ============================================================================
-- Stay is categorical, not an exact number of days.
-- This query shows how many cases belong to each stay category.

SELECT
    Stay,
    COUNT(*) AS cases
FROM train_raw
GROUP BY Stay
ORDER BY cases DESC;


-- ============================================================================
-- 9. CATEGORY COUNTS IN TEST DATA
-- ============================================================================
-- The main categories are compared with the training dataset.
-- Stay is excluded because test_raw has no Stay column.

SELECT COUNT(DISTINCT Department) AS department_categories
FROM test_raw;

SELECT COUNT(DISTINCT `Type of Admission`) AS admission_type_categories
FROM test_raw;

SELECT COUNT(DISTINCT `Severity of Illness`) AS severity_categories
FROM test_raw;

SELECT COUNT(DISTINCT Age) AS age_categories
FROM test_raw;


-- ============================================================================
-- 10. HOSPITAL AND WARD CATEGORY COUNTS
-- ============================================================================
-- These fields describe facilities and ward/bed characteristics.

SELECT COUNT(DISTINCT Hospital_code) AS hospital_codes
FROM train_raw;

SELECT COUNT(DISTINCT Hospital_type_code) AS hospital_types
FROM train_raw;

SELECT COUNT(DISTINCT City_Code_Hospital) AS hospital_cities
FROM train_raw;

SELECT COUNT(DISTINCT Hospital_region_code) AS hospital_regions
FROM train_raw;

SELECT COUNT(DISTINCT Ward_Type) AS ward_types
FROM train_raw;

SELECT COUNT(DISTINCT Ward_Facility_Code) AS ward_facility_codes
FROM train_raw;

SELECT COUNT(DISTINCT `Bed Grade`) AS bed_grades
FROM train_raw;


-- ============================================================================
-- 11. HOSPITAL IDENTIFIER CONSISTENCY
-- ============================================================================
-- Each hospital code should map to one observed hospital type, city and region.
-- HAVING filters groups after aggregation.
-- Expected audit outcome: zero rows.

SELECT
    Hospital_code,
    COUNT(DISTINCT Hospital_type_code) AS hospital_types,
    COUNT(DISTINCT City_Code_Hospital) AS hospital_cities,
    COUNT(DISTINCT Hospital_region_code) AS hospital_regions
FROM train_raw
GROUP BY Hospital_code
HAVING
    COUNT(DISTINCT Hospital_type_code) > 1
    OR COUNT(DISTINCT City_Code_Hospital) > 1
    OR COUNT(DISTINCT Hospital_region_code) > 1;


-- ============================================================================
-- END OF CURRENT AUDIT SCRIPT
-- ============================================================================
-- Next steps:
--   1. Finish remaining raw-data quality checks.
--   2. Decide which fields belong in each normalized table.
--   3. Design primary keys and foreign keys.
--   4. Create normalized tables and populate them from raw data.
--   5. Validate row counts and relationships after transformation.
-- ============================================================================
