-- Reusable fraud analysis views

CREATE OR REPLACE VIEW staging.v_application_risk_scores AS
SELECT
    *,
    (
        CASE WHEN credit_risk_score > 269 THEN 2 ELSE 0 END
        + CASE WHEN name_email_similarity <= 0.18 THEN 1 ELSE 0 END
        + CASE WHEN device_distinct_emails_8w = 2 THEN 1 ELSE 0 END
        + CASE WHEN phone_home_valid = 0 THEN 1 ELSE 0 END
        + CASE WHEN email_is_free = 1 THEN 1 ELSE 0 END
        + CASE WHEN has_other_cards = 0 THEN 1 ELSE 0 END
    ) AS risk_score,
    CASE
        WHEN (
            CASE WHEN credit_risk_score > 269 THEN 2 ELSE 0 END
            + CASE WHEN name_email_similarity <= 0.18 THEN 1 ELSE 0 END
            + CASE WHEN device_distinct_emails_8w = 2 THEN 1 ELSE 0 END
            + CASE WHEN phone_home_valid = 0 THEN 1 ELSE 0 END
            + CASE WHEN email_is_free = 1 THEN 1 ELSE 0 END
            + CASE WHEN has_other_cards = 0 THEN 1 ELSE 0 END
        ) >= 5 THEN 1
        ELSE 0
    END AS fraud_risk_flag
FROM staging.raw_applications;

CREATE OR REPLACE VIEW staging.v_fraud_risk_analysis AS
SELECT
    fraud_bool,
    month,
    credit_risk_score,
    name_email_similarity,
    device_distinct_emails_8w,
    phone_home_valid,
    email_is_free,
    has_other_cards,
    payment_type,
    employment_status,
    housing_status,
    source,
    risk_score,
    fraud_risk_flag
FROM staging.v_application_risk_scores;