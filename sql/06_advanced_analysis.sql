-- Lift analysis

-- Compare high-risk category combinations with the overall fraud rate
WITH overall AS (
    SELECT
        1.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*) AS overall_fraud_rate
    FROM staging.raw_applications
),
segments AS (
    SELECT
        payment_type,
        employment_status,
        housing_status,
        COUNT(*) AS total_applications,
        SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
        1.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*) AS segment_fraud_rate
    FROM staging.raw_applications
    WHERE credit_risk_score > 269
    GROUP BY payment_type, employment_status, housing_status
    HAVING COUNT(*) >= 500
)
SELECT
    payment_type,
    employment_status,
    housing_status,
    total_applications,
    fraud_applications,
    ROUND(100.0 * segment_fraud_rate, 2) AS fraud_rate_pct,
    ROUND(segment_fraud_rate / overall_fraud_rate, 2) AS lift_vs_overall
FROM segments
CROSS JOIN overall
ORDER BY lift_vs_overall DESC;

-- Compare each final risk-score bucket with the overall fraud rate
WITH overall AS (
    SELECT
        1.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*) AS overall_fraud_rate
    FROM staging.v_application_risk_scores
),
score_summary AS (
    SELECT
        risk_score,
        COUNT(*) AS total_applications,
        SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
        1.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*) AS score_fraud_rate
    FROM staging.v_application_risk_scores
    GROUP BY risk_score
)
SELECT
    risk_score,
    total_applications,
    fraud_applications,
    ROUND(100.0 * score_fraud_rate, 2) AS fraud_rate_pct,
    ROUND(score_fraud_rate / overall_fraud_rate, 2) AS lift_vs_overall
FROM score_summary
CROSS JOIN overall
ORDER BY risk_score;