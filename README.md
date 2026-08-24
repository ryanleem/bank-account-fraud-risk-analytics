# Bank Account Fraud Risk Analytics

This is a SQL/PostgreSQL project that looks for patterns associated with fraudulent bank account applications.

I used 1,000,000 applications from the Feedzai Bank Account Fraud (BAF) dataset. The dataset is synthetic and privacy-preserving, so it can be used for fraud analysis without exposing real customer information.

The project starts with raw CSV data, loads it into PostgreSQL, checks data quality, finds higher-risk groups, builds a simple fraud risk score, tests that score on later months, and measures SQL query performance.

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

# How to Run the Project

You do not need the raw CSV inside this repository. Download the Feedzai BAF dataset separately and locate `Base.csv` on your computer before starting.

`Base.csv` contains 1,000,000 bank account applications and 32 columns. The target column is `fraud_bool`, where `0` means legitimate and `1` means fraud.

## 1. Install PostgreSQL

You need PostgreSQL and the `psql` command-line tool.

### macOS

With Homebrew:

```bash
brew install postgresql@17
brew services start postgresql@17
```

### Windows

Install PostgreSQL using the official Windows installer. During installation, remember the password you choose for the default `postgres` user.

After installation, you can use **SQL Shell (psql)** from the Start menu, or PowerShell/Command Prompt if PostgreSQL's `bin` folder is on your PATH.

A common PostgreSQL location is:

```text
C:\Program Files\PostgreSQL\17\bin
```

If `psql` is not recognized in PowerShell, either use SQL Shell (psql) or add that folder to your Windows PATH.

### Ubuntu / Debian Linux

```bash
sudo apt update
sudo apt install postgresql postgresql-client
sudo systemctl start postgresql
```

## 2. Clone the repository

### macOS / Linux / Windows PowerShell

```bash
git clone https://github.com/ryanleem/bank-account-fraud-risk-analytics.git
cd bank-account-fraud-risk-analytics
```

## 3. Create the database

### macOS / Linux

```bash
createdb bank_fraud_account
```

If your PostgreSQL setup requires a username:

```bash
createdb -U postgres bank_fraud_account
```

### Windows

In PowerShell, Command Prompt, or SQL Shell:

```powershell
createdb -U postgres bank_fraud_account
```

You may be asked for the PostgreSQL password you created during installation.

If `createdb` is not available but `psql` is, use:

```powershell
psql -U postgres -c "CREATE DATABASE bank_fraud_account;"
```

## 4. Create the staging table

Run this from the root of the cloned repository.

### macOS / Linux

```bash
psql -d bank_fraud_account -f sql/01_staging_schema.sql
```

If you need to specify the PostgreSQL user:

```bash
psql -U postgres -d bank_fraud_account -f sql/01_staging_schema.sql
```

### Windows

```powershell
psql -U postgres -d bank_fraud_account -f sql/01_staging_schema.sql
```

If you see:

```text
NOTICE: relation "raw_applications" already exists, skipping
```

that is not an error. It only means the staging table already exists.

## 5. Load `Base.csv`

The path in the command must point to the actual `Base.csv` file on your computer.

### macOS example

First locate the file if needed:

```bash
find ~/Downloads -name "Base.csv"
```

Then use the path that command returns. For example:

```bash
psql -d bank_fraud_account -c "\copy staging.raw_applications FROM '/Users/yourname/Downloads/archive/Base.csv' WITH (FORMAT csv, HEADER true)"
```

### Windows example

Use forward slashes inside the PostgreSQL file path. For example:

```powershell
psql -U postgres -d bank_fraud_account -c "\copy staging.raw_applications FROM 'C:/Users/YourName/Downloads/Base.csv' WITH (FORMAT csv, HEADER true)"
```

If the file is inside another folder, include the full path:

```powershell
psql -U postgres -d bank_fraud_account -c "\copy staging.raw_applications FROM 'C:/Users/YourName/Downloads/archive/Base.csv' WITH (FORMAT csv, HEADER true)"
```

### Linux example

```bash
psql -d bank_fraud_account -c "\copy staging.raw_applications FROM '/home/yourname/Downloads/Base.csv' WITH (FORMAT csv, HEADER true)"
```

Do **not** copy `/full/path/to/Base.csv` literally. That wording is only a placeholder for the actual location of the file on your machine.

## 6. Confirm the data loaded

Run:

```bash
psql -d bank_fraud_account -c "SELECT COUNT(*) FROM staging.raw_applications;"
```

On Windows, if you are using the `postgres` user:

```powershell
psql -U postgres -d bank_fraud_account -c "SELECT COUNT(*) FROM staging.raw_applications;"
```

The expected row count is:

```text
1000000
```

If you see 1,000,000 rows, the import worked.

## 7. Run the analysis SQL files

Run the remaining SQL files in order.

### macOS / Linux

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

### Windows

```powershell
psql -U postgres -d bank_fraud_account -f sql/02_data_quality.sql
psql -U postgres -d bank_fraud_account -f sql/03_transformations.sql
psql -U postgres -d bank_fraud_account -f sql/04_baseline_analysis.sql
psql -U postgres -d bank_fraud_account -f sql/05_fraud_patterns.sql
psql -U postgres -d bank_fraud_account -f sql/06_advanced_analysis.sql
psql -U postgres -d bank_fraud_account -f sql/07_risk_scoring.sql
psql -U postgres -d bank_fraud_account -f sql/08_rule_validation.sql
psql -U postgres -d bank_fraud_account -f sql/09_views.sql
psql -U postgres -d bank_fraud_account -f sql/10_optimization.sql
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

- SQL
- PostgreSQL 17
- Git / GitHub

## Data

I used Feedzai's `Base.csv`, which contains 1,000,000 applications and 32 columns. The raw dataset is not committed to this repository.

See [`data/README.md`](data/README.md) for more data notes and [`results/fraud_findings.md`](results/fraud_findings.md) for the full analysis results.

## Limitations

The dataset is synthetic and privacy-preserving, so the results should be treated as a portfolio analysis rather than a production banking fraud system.

The risk score is rule-based and is meant to identify higher-risk groups, not replace a full fraud detection model.
