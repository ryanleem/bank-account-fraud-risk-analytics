-- Baseline fraud analysis

-- Overall fraud rate
SELECT
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications;

-- Fraud rate by month
SELECT
    month,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications
GROUP BY month
ORDER BY month;

-- Fraud rate by payment type
SELECT
    payment_type,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications
GROUP BY payment_type
ORDER BY fraud_rate_pct DESC;

-- Fraud rate by employment status
SELECT
    employment_status,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications
GROUP BY employment_status
ORDER BY fraud_rate_pct DESC;

-- Fraud rate by housing status
SELECT
    housing_status,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications
GROUP BY housing_status
ORDER BY fraud_rate_pct DESC;