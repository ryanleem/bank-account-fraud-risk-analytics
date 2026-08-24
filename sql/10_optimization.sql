-- PostgreSQL query optimization

CREATE INDEX IF NOT EXISTS idx_raw_applications_credit_risk
ON staging.raw_applications (credit_risk_score);

CREATE INDEX IF NOT EXISTS idx_raw_applications_month
ON staging.raw_applications (month);

-- Selective credit-risk filter
-- Measured plan: Index Only Scan
-- Measured execution time: about 6-7 ms
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM staging.raw_applications
WHERE credit_risk_score > 269;

-- Later-period filter
-- Measured plan: Parallel Index Only Scan
-- Measured execution time: about 28 ms
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM staging.raw_applications
WHERE month >= 6;

-- Broad filter for comparison
-- Measured plan: Parallel Sequential Scan
-- Measured execution time: about 67 ms
-- This condition matches more than half the table, so PostgreSQL did not need an index here.
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM staging.raw_applications
WHERE phone_home_valid = 0;