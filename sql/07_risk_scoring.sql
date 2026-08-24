-- Final rule-based risk score
-- Rules were selected using development months 0-5.

WITH scored_applications AS (
    SELECT
        fraud_bool,
        month,
        (
            CASE WHEN credit_risk_score > 269 THEN 2 ELSE 0 END
            + CASE WHEN name_email_similarity <= 0.18 THEN 1 ELSE 0 END
            + CASE WHEN device_distinct_emails_8w = 2 THEN 1 ELSE 0 END
            + CASE WHEN phone_home_valid = 0 THEN 1 ELSE 0 END
            + CASE WHEN email_is_free = 1 THEN 1 ELSE 0 END
            + CASE WHEN has_other_cards = 0 THEN 1 ELSE 0 END
        ) AS risk_score
    FROM staging.raw_applications
)
SELECT
    risk_score,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_applications,
    ROUND(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS fraud_rate_pct
FROM scored_applications
GROUP BY risk_score
ORDER BY risk_score;

-- Final flag: risk_score >= 5