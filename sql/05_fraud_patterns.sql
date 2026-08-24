-- Multi-factor fraud pattern analysis

-- Payment type + employment status
SELECT
    payment_type,
    employment_status,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications
GROUP BY payment_type, employment_status
HAVING COUNT(*) >= 1000
ORDER BY fraud_rate_pct DESC;

-- Payment type + employment status + housing status
SELECT
    payment_type,
    employment_status,
    housing_status,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications
GROUP BY payment_type, employment_status, housing_status
HAVING COUNT(*) >= 1000
ORDER BY fraud_rate_pct DESC;

-- Same three-way grouping among applications with high credit risk
SELECT
    payment_type,
    employment_status,
    housing_status,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM staging.raw_applications
WHERE credit_risk_score > 269
GROUP BY payment_type, employment_status, housing_status
HAVING COUNT(*) >= 500
ORDER BY fraud_rate_pct DESC;