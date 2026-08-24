-- Data quality checks

-- 1. Total rows
SELECT COUNT(*) AS total_rows
FROM staging.raw_applications;

-- 2. Fraud label distribution
SELECT
    fraud_bool,
    COUNT(*) AS row_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_dataset
FROM staging.raw_applications
GROUP BY fraud_bool
ORDER BY fraud_bool;

-- 3. Make sure the target only contains 0 and 1
SELECT DISTINCT fraud_bool
FROM staging.raw_applications
ORDER BY fraud_bool;

-- 4. Month coverage
SELECT
    MIN(month) AS min_month,
    MAX(month) AS max_month,
    COUNT(DISTINCT month) AS distinct_months
FROM staging.raw_applications;

-- 5. Important ranges
SELECT
    MIN(credit_risk_score) AS min_credit_risk_score,
    MAX(credit_risk_score) AS max_credit_risk_score,
    MIN(name_email_similarity) AS min_name_email_similarity,
    MAX(name_email_similarity) AS max_name_email_similarity,
    MIN(device_distinct_emails_8w) AS min_device_distinct_emails,
    MAX(device_distinct_emails_8w) AS max_device_distinct_emails
FROM staging.raw_applications;

-- 6. NULL checks on important fields
SELECT
    COUNT(*) FILTER (WHERE fraud_bool IS NULL) AS fraud_bool_nulls,
    COUNT(*) FILTER (WHERE income IS NULL) AS income_nulls,
    COUNT(*) FILTER (WHERE name_email_similarity IS NULL) AS name_email_similarity_nulls,
    COUNT(*) FILTER (WHERE prev_address_months_count IS NULL) AS prev_address_nulls,
    COUNT(*) FILTER (WHERE current_address_months_count IS NULL) AS current_address_nulls,
    COUNT(*) FILTER (WHERE customer_age IS NULL) AS customer_age_nulls,
    COUNT(*) FILTER (WHERE credit_risk_score IS NULL) AS credit_risk_score_nulls,
    COUNT(*) FILTER (WHERE device_distinct_emails_8w IS NULL) AS device_email_nulls,
    COUNT(*) FILTER (WHERE month IS NULL) AS month_nulls
FROM staging.raw_applications;

-- 7. The dataset uses -1 as a special value in some fields
SELECT
    COUNT(*) FILTER (WHERE prev_address_months_count = -1) AS prev_address_sentinel_rows,
    COUNT(*) FILTER (WHERE bank_months_count = -1) AS bank_months_sentinel_rows,
    COUNT(*) FILTER (WHERE device_distinct_emails_8w = -1) AS device_email_sentinel_rows
FROM staging.raw_applications;

-- 8. Sentinel percentages
SELECT
    ROUND(100.0 * COUNT(*) FILTER (WHERE prev_address_months_count = -1) / COUNT(*), 2) AS prev_address_sentinel_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE bank_months_count = -1) / COUNT(*), 2) AS bank_months_sentinel_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE device_distinct_emails_8w = -1) / COUNT(*), 2) AS device_email_sentinel_pct
FROM staging.raw_applications;

-- 9. Category checks
SELECT payment_type, COUNT(*) AS row_count
FROM staging.raw_applications
GROUP BY payment_type
ORDER BY payment_type;

SELECT employment_status, COUNT(*) AS row_count
FROM staging.raw_applications
GROUP BY employment_status
ORDER BY employment_status;

SELECT housing_status, COUNT(*) AS row_count
FROM staging.raw_applications
GROUP BY housing_status
ORDER BY housing_status;

SELECT source, COUNT(*) AS row_count
FROM staging.raw_applications
GROUP BY source
ORDER BY source;

SELECT device_os, COUNT(*) AS row_count
FROM staging.raw_applications
GROUP BY device_os
ORDER BY device_os;