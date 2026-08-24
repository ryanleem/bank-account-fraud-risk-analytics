-- Development vs later-period validation
-- Development: months 0-5
-- Validation: months 6-7
-- Final flag: risk_score >= 5

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
),
confusion AS (
    SELECT
        CASE
            WHEN month <= 5 THEN 'Development'
            ELSE 'Validation'
        END AS dataset_split,
        SUM(CASE WHEN risk_score >= 5 AND fraud_bool = 1 THEN 1 ELSE 0 END) AS true_positives,
        SUM(CASE WHEN risk_score >= 5 AND fraud_bool = 0 THEN 1 ELSE 0 END) AS false_positives,
        SUM(CASE WHEN risk_score < 5 AND fraud_bool = 1 THEN 1 ELSE 0 END) AS false_negatives,
        SUM(CASE WHEN risk_score < 5 AND fraud_bool = 0 THEN 1 ELSE 0 END) AS true_negatives
    FROM scored_applications
    GROUP BY
        CASE
            WHEN month <= 5 THEN 'Development'
            ELSE 'Validation'
        END
)
SELECT
    dataset_split,
    true_positives,
    false_positives,
    false_negatives,
    true_negatives,
    ROUND(100.0 * true_positives / NULLIF(true_positives + false_positives, 0), 2) AS precision_pct,
    ROUND(100.0 * true_positives / NULLIF(true_positives + false_negatives, 0), 2) AS recall_pct,
    ROUND(100.0 * false_positives / NULLIF(false_positives + true_negatives, 0), 2) AS false_positive_rate_pct,
    ROUND(100.0 * true_negatives / NULLIF(true_negatives + false_positives, 0), 2) AS specificity_pct,
    ROUND(
        2.0
        * (1.0 * true_positives / NULLIF(true_positives + false_positives, 0))
        * (1.0 * true_positives / NULLIF(true_positives + false_negatives, 0))
        / NULLIF(
            (1.0 * true_positives / NULLIF(true_positives + false_positives, 0))
            + (1.0 * true_positives / NULLIF(true_positives + false_negatives, 0)),
            0
        ),
        4
    ) AS f1_score
FROM confusion
ORDER BY dataset_split;