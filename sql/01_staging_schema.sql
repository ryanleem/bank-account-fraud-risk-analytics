-- Raw staging table for Feedzai Base.csv

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.raw_applications (
    fraud_bool INTEGER,
    income NUMERIC,
    name_email_similarity NUMERIC,
    prev_address_months_count INTEGER,
    current_address_months_count INTEGER,
    customer_age INTEGER,
    days_since_request NUMERIC,
    intended_balcon_amount NUMERIC,
    payment_type TEXT,
    zip_count_4w INTEGER,
    velocity_6h NUMERIC,
    velocity_24h NUMERIC,
    velocity_4w NUMERIC,
    bank_branch_count_8w INTEGER,
    date_of_birth_distinct_emails_4w INTEGER,
    employment_status TEXT,
    credit_risk_score INTEGER,
    email_is_free INTEGER,
    housing_status TEXT,
    phone_home_valid INTEGER,
    phone_mobile_valid INTEGER,
    bank_months_count INTEGER,
    has_other_cards INTEGER,
    proposed_credit_limit NUMERIC,
    foreign_request INTEGER,
    source TEXT,
    session_length_in_minutes NUMERIC,
    device_os TEXT,
    keep_alive_session INTEGER,
    device_distinct_emails_8w INTEGER,
    device_fraud_count INTEGER,
    month INTEGER
);

-- Load Base.csv into this table after creating it.
-- The raw table is kept unchanged. Cleaning is handled in 03_transformations.sql.