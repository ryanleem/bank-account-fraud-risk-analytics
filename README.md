# Bank Account Fraud Risk Analytics

PostgreSQL project using the Feedzai Bank Account Fraud dataset to find fraud patterns, build a simple risk score, test it on later months, and check query performance on 1,000,000 applications.

## What I Did

I loaded the Base dataset into PostgreSQL and worked through the project in stages:

1. checked the raw data and target distribution
2. looked for missing and special values
3. created a cleaned SQL view
4. compared fraud rates across payment, employment, and housing groups
5. tested combinations of risk factors
6. built a point-based fraud risk score
7. tuned the score using months 0-5
8. tested the finished rule on months 6-7
9. created reusable views for analysis
10. added indexes and checked them with `EXPLAIN ANALYZE`

## Main Results

The dataset contains 1,000,000 applications and 11,029 fraud cases, giving an overall fraud rate of 1.10%.

Some groups had much higher fraud rates than the overall average. For example, applications with `payment_type = AC`, `employment_status = CA`, `housing_status = BA`, and `credit_risk_score > 269` had an 11.74% fraud rate, about 10.64 times the overall rate.

I also built a simple rule-based score:

| Condition | Points |
|---|---:|
| `credit_risk_score > 269` | +2 |
| `name_email_similarity <= 0.18` | +1 |
| `device_distinct_emails_8w = 2` | +1 |
| `phone_home_valid = 0` | +1 |
| `email_is_free = 1` | +1 |
| `has_other_cards = 0` | +1 |

Applications with a score of 5 or higher are flagged.

The fraud rate increased steadily as the score increased:

| Risk Score | Fraud Rate |
|---:|---:|
| 0 | 0.11% |
| 1 | 0.33% |
| 2 | 0.70% |
| 3 | 1.40% |
| 4 | 3.29% |
| 5 | 8.81% |
| 6 | 17.51% |
| 7 | 42.55% |

Score 7 only had 47 applications, so I would not put much weight on that number by itself.

## Later-Period Test

I used months 0-5 as the development period and months 6-7 as a later validation period.

| Metric | Development | Validation |
|---|---:|---:|
| Precision | 9.35% | 13.32% |
| Recall | 10.72% | 10.56% |
| False Positive Rate | 1.08% | 0.98% |
| Specificity | 98.92% | 99.02% |
| F1 Score | 0.0999 | 0.1178 |

The rule did not catch most fraud, so I would not describe it as a full fraud-detection system. It works better as a screening rule that finds a smaller group with a much higher fraud rate.

## Data Quality

The raw data did not use normal SQL `NULL` values for some fields. Several columns used `-1` as a special value instead.

| Field | Rows Using -1 | Percent |
|---|---:|---:|
| `prev_address_months_count` | 712,920 | 71.29% |
| `bank_months_count` | 253,635 | 25.36% |
| `device_distinct_emails_8w` | 359 | 0.04% |

I kept the raw table unchanged and created a cleaned view that converts these values to `NULL` for analysis.

## Query Performance

I added indexes for `credit_risk_score` and `month` and checked the execution plans with `EXPLAIN ANALYZE`.

| Query | Plan | Execution Time |
|---|---|---:|
| `credit_risk_score > 269` | Index Only Scan | ~6-7 ms |
| `month >= 6` | Parallel Index Only Scan | ~28 ms |
| `phone_home_valid = 0` | Parallel Sequential Scan | ~67 ms |

The last query is a useful example of why an index is not always the best choice. More than half the table matches that condition, so PostgreSQL chose a sequential scan.

## Tech Stack

- PostgreSQL 17
- SQL
- Git / GitHub

## Data

This project uses the Feedzai Bank Account Fraud (BAF) dataset. I used `Base.csv`, which contains 1,000,000 bank account applications. The raw dataset is not committed to this repository.

See [`data/README.md`](data/README.md) for setup notes.

## Repository Structure

```text
.
├── data/
│   └── README.md
├── docs/
│   ├── data_dictionary.md
│   ├── methodology.md
│   └── findings.md
├── results/
│   ├── fraud_findings.md
│   └── query_performance.md
└── sql/
    ├── 01_staging_schema.sql
    ├── 02_data_quality.sql
    ├── 03_transformations.sql
    ├── 04_baseline_analysis.sql
    ├── 05_fraud_patterns.sql
    ├── 06_advanced_analysis.sql
    ├── 07_risk_scoring.sql
    ├── 08_rule_validation.sql
    ├── 09_views.sql
    └── 10_optimization.sql
```

## Notes

The dataset is synthetic and privacy-preserving, so these results should not be treated exactly like results from a real bank production system.

I had also looked at months 6-7 earlier during exploration. I therefore treat them as a later-period validation set rather than claiming they were a perfectly untouched holdout.

More detailed results are in [`results/fraud_findings.md`](results/fraud_findings.md).