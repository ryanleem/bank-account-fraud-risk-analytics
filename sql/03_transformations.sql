-- Cleaned analysis view
-- The raw staging table stays unchanged.

CREATE OR REPLACE VIEW staging.v_applications_clean AS
SELECT
    fraud_bool,
    income,
    name_email_similarity,
    NULLIF(prev_address_months_count, -1) AS prev_address_months_count,
    current_address_months_count,
    customer_age,
    days_since_request,
    intended_balcon_amount,
    payment_type,
    zip_count_4w,
    velocity_6h,
    velocity_24h,
    velocity_4w,
    bank_branch_count_8w,
    date_of_birth_distinct_emails_4w,
    employment_status,
    credit_risk_score,
    email_is_free,
    housing_status,
    phone_home_valid,
    phone_mobile_valid,
    NULLIF(bank_months_count, -1) AS bank_months_count,
    has_other_cards,
    proposed_credit_limit,
    foreign_request,
    source,
    session_length_in_minutes,
    device_os,
    keep_alive_session,
    NULLIF(device_distinct_emails_8w, -1) AS device_distinct_emails_8w,
    device_fraud_count,
    month
FROM staging.raw_applications;

-- Check that the -1 values became NULL in the cleaned view
SELECT
    COUNT(*) FILTER (WHERE prev_address_months_count IS NULL) AS prev_address_nulls,
    COUNT(*) FILTER (WHERE bank_months_count IS NULL) AS bank_months_nulls,
    COUNT(*) FILTER (WHERE device_distinct_emails_8w IS NULL) AS device_email_nulls
FROM staging.v_applications_clean;