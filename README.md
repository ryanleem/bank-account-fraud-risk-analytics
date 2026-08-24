# Bank Account Fraud Risk Analytics

PostgreSQL project using 1,000,000 bank account applications from the Feedzai Bank Account Fraud dataset.

I used SQL to check the data, find higher-risk groups, build a simple fraud risk score, test it on later months, and measure query performance.

## Main Results

The dataset contains 11,029 fraud cases out of 1,000,000 applications, for an overall fraud rate of 1.10%.

One of the strongest larger groups I found was:

`payment_type = AC` + `employment_status = CA` + `housing_status = BA` + `credit_risk_score > 269`

That group had an 11.74% fraud rate, about 10.64x the overall rate.

I also built this point-based risk score:

| Condition | Points |
|---|---:|
| `credit_risk_score > 269` | +2 |
| `name_email_similarity <= 0.18` | +1 |
| `device_distinct_emails_8w = 2` | +1 |
| `phone_home_valid = 0` | +1 |
| `email_is_free = 1` | +1 |
| `has_other_cards = 0` | +1 |

Applications with a score of 5 or higher are flagged.

The fraud rate increased as the score increased:

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

Score 7 only contained 47 applications, so I would not treat that percentage as equally reliable as the larger groups.

## Later-Period Test

I used months 0-5 as the development period and months 6-7 as a later validation period.

| Metric | Development | Validation |
|---|---:|---:|
| Precision | 9.35% | 13.32% |
| Recall | 10.72% | 10.56% |
| False Positive Rate | 1.08% | 0.98% |
| Specificity | 98.92% | 99.02% |
| F1 Score | 0.0999 | 0.1178 |

The score does not catch most fraud, so I do not treat it as a full fraud-detection system. It works better as a screening rule that finds a smaller group with a much higher fraud rate.

## Data Quality

Some columns use `-1` as a special value instead of SQL `NULL`.

| Field | Rows Using -1 | Percent |
|---|---:|---:|
| `prev_address_months_count` | 712,920 | 71.29% |
| `bank_months_count` | 253,635 | 25.36% |
| `device_distinct_emails_8w` | 359 | 0.04% |

I kept the raw staging table unchanged and created a cleaned view that converts these values to `NULL` for analysis.

## Query Performance

I added indexes on `credit_risk_score` and `month`, then checked the execution plans with `EXPLAIN ANALYZE`.

| Query | Plan | Execution Time |
|---|---|---:|
| `credit_risk_score > 269` | Index Only Scan | ~6-7 ms |
| `month >= 6` | Parallel Index Only Scan | ~28 ms |
| `phone_home_valid = 0` | Parallel Sequential Scan | ~67 ms |

The last query matches more than half of the table, so PostgreSQL chose a sequential scan instead of an index. I kept this example because it shows that adding an index does not automatically make every query faster.

## How to Run

### 1. Requirements

- PostgreSQL 17 or another recent PostgreSQL version
- `psql`
- Feedzai BAF `Base.csv`

### 2. Clone the repo

```bash
git clone https://github.com/ryanleem/bank-account-fraud-risk-analytics.git
cd bank-account-fraud-risk-analytics
```

### 3. Create a database

```bash
createdb bank_fraud_account
```

### 4. Create the staging table

```bash
psql -d bank_fraud_account -f sql/01_staging_schema.sql
```

### 5. Load `Base.csv`

Replace `/full/path/to/Base.csv` with the location of the file on your computer.

```bash
psql -d bank_fraud_account -c "\copy staging.raw_applications FROM '/full/path/to/Base.csv' WITH (FORMAT csv, HEADER true)"
```

The raw CSV is not stored in this repository.

### 6. Run the SQL files

Run the remaining files in order:

```bash
psql -d bank_fraud_account -f sql/02_data_quality.sql
psql -d bank_fraud_account -f sql/03_transformations.sql
psql -d bank_fraud_account -f sql/04_baseline_analysis.sql
psql -d bank_fraud_account -f sql/05_fraud_patterns.sql
psql -d bank_fraud_account -f sql/06_advanced_analysis.sql
psql -d bank_fraud_account -f sql/07_risk_scoring.sql
psql -d bank_fraud_account -f sql/08_rule_validation.sql
psql -d bank_fraud_account -f sql/09_views.sql
psql -d bank_fraud_account -f sql/10_optimization.sql
```

The files are numbered in the order I worked through the analysis, from raw-data checks to the final scoring views and performance tests.

## Project Files

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

## Tech Stack

- PostgreSQL 17
- SQL
- Git / GitHub

## Data

I used Feedzai's `Base.csv`, which contains 1,000,000 applications and 32 columns. The raw dataset is not committed to this repo.

See [`data/README.md`](data/README.md) for data notes and [`results/fraud_findings.md`](results/fraud_findings.md) for the full results.

## Limitations

The dataset is synthetic and privacy-preserving, so these results should not be treated the same as results from a live bank system.

I also looked at months 6-7 during earlier exploration. I later rebuilt the final rule using months 0-5 and tested it again on months 6-7, but I do not call those months a perfectly untouched holdout.
