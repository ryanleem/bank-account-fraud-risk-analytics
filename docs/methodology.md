# Methodology

## 1. Load the Raw Data

I loaded `Base.csv` into PostgreSQL and kept the original values in `staging.raw_applications`.

I did not clean the raw table directly. I wanted one place that always matched the source data.

## 2. Check the Data First

Before doing fraud analysis, I checked:

- total row count
- fraud label values
- fraud class balance
- month range
- important numeric ranges
- NULL values
- special `-1` values
- category values such as payment type, employment status, housing status, source, and device OS

The dataset had 1,000,000 rows and 11,029 fraud cases, so the overall fraud rate was 1.10%.

I also found that some fields used `-1` as a special value. I converted those values to SQL `NULL` in a separate cleaned view.

## 3. Start With Simple Fraud Rates

I first compared fraud rates across individual categories. This gave me a baseline for which groups were more or less associated with fraud.

I looked at fields such as:

- payment type
- employment status
- housing status
- credit risk score
- name and email similarity
- device email count
- phone validity
- free email use
- whether the applicant had other cards

## 4. Combine Risk Factors

After looking at one feature at a time, I grouped multiple fields together.

I used minimum group sizes with `HAVING COUNT(*)` so very small groups would not look important just from a few fraud cases.

For example, I looked at payment type + employment status + housing status, then repeated that analysis for applications with higher credit risk scores.

## 5. Tune the Credit Risk Threshold

I tested different `credit_risk_score` cutoffs and compared precision, recall, and F1.

I later repeated the tuning using only months 0-5 so the final threshold was based on the development period.

The selected cutoff was:

`credit_risk_score > 269`

## 6. Build the Risk Score

I built a simple point-based score from the strongest patterns I found.

| Condition | Points |
|---|---:|
| `credit_risk_score > 269` | +2 |
| `name_email_similarity <= 0.18` | +1 |
| `device_distinct_emails_8w = 2` | +1 |
| `phone_home_valid = 0` | +1 |
| `email_is_free = 1` | +1 |
| `has_other_cards = 0` | +1 |

I tested score thresholds from 1 through 7 on months 0-5.

A score of 5 or higher had the best F1 out of the thresholds tested, so I used `risk_score >= 5` as the final flag.

## 7. Test on Later Months

I used:

- months 0-5 for development
- months 6-7 for later-period validation

The final rule was fixed before I ran the final comparison between the two periods.

The validation results were:

- precision: 13.32%
- recall: 10.56%
- false-positive rate: 0.98%
- specificity: 99.02%
- F1: 0.1178

The rule is selective rather than broad. It misses most fraud, but the applications it flags have a much higher fraud rate than the overall dataset.

## 8. Build Reusable Views

I created views so I would not need to repeat the scoring logic in every query.

The main views are:

- `staging.v_applications_clean`
- `staging.v_application_risk_scores`
- `staging.v_fraud_risk_analysis`

## 9. Check Query Performance

I added indexes on `credit_risk_score` and `month` because those fields were used often in filters.

I used `EXPLAIN ANALYZE` to see what PostgreSQL actually did instead of assuming the indexes helped.

The tests showed examples of:

- Index Only Scan
- Parallel Index Only Scan
- Parallel Sequential Scan

This also showed that PostgreSQL will still choose a sequential scan when a filter matches a large part of the table.

## Limitation of the Validation Setup

I had already looked at months 6-7 earlier during exploration. I therefore do not call them a perfectly untouched holdout set.

I re-tuned the final rules using months 0-5 and then used months 6-7 as a later-period validation check.