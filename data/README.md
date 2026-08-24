# Data

This project uses the Feedzai Bank Account Fraud (BAF) dataset.

I used `Base.csv` for the main analysis. It contains 1,000,000 bank account applications and 32 columns.

The raw CSV is not committed to this repository.

## File Used

- Dataset: Feedzai Bank Account Fraud (BAF)
- File: `Base.csv`
- Rows: 1,000,000
- Target: `fraud_bool`
  - `0` = legitimate
  - `1` = fraud
- Time field: `month`
  - values run from 0 through 7

The BAF download also contains Variant I through Variant V. I kept this project focused on the Base dataset.

## Loading the Data

First run the staging-table script from the root of the repo:

```bash
psql -d bank_fraud_account -f sql/01_staging_schema.sql
```

Then load the CSV. Replace `/full/path/to/Base.csv` with the actual location of the file on your computer.

```bash
psql -d bank_fraud_account -c "\copy staging.raw_applications FROM '/full/path/to/Base.csv' WITH (FORMAT csv, HEADER true)"
```

You can confirm the load with:

```sql
SELECT COUNT(*)
FROM staging.raw_applications;
```

The expected result is:

```text
1000000
```

## Raw vs. Cleaned Data

I keep `staging.raw_applications` unchanged so it still matches the source CSV.

Cleaning is handled in `sql/03_transformations.sql`, which creates a separate view for analysis.

One issue I found was that some fields use `-1` as a special value instead of SQL `NULL`.

| Field | Rows Using -1 | Percent |
|---|---:|---:|
| `prev_address_months_count` | 712,920 | 71.29% |
| `bank_months_count` | 253,635 | 25.36% |
| `device_distinct_emails_8w` | 359 | 0.04% |

The cleaned view converts those values to `NULL` without changing the raw table.
