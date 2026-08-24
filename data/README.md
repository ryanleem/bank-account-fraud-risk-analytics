# Data

This project uses the Feedzai Bank Account Fraud (BAF) dataset.

I used `Base.csv` for the main analysis. It contains 1,000,000 bank account applications and 32 columns.

The raw data is not committed to this repository.

## Dataset Used

- Source: Feedzai Bank Account Fraud dataset
- File used: `Base.csv`
- Rows: 1,000,000
- Target: `fraud_bool`
  - `0` = legitimate
  - `1` = fraud
- Time field: `month`, with values from 0 through 7

The dataset also includes Variant I through Variant V. I kept the main project focused on the Base dataset first.

## Local Setup

After downloading `Base.csv`, load it into the PostgreSQL table created in `sql/01_staging_schema.sql`.

The project keeps the raw table unchanged. Cleaning is done in a separate SQL view so the original values are still available.

## Important Data Note

Some columns use `-1` as a special value rather than SQL `NULL`.

The main ones I found were:

| Field | Rows Using -1 | Percent |
|---|---:|---:|
| `prev_address_months_count` | 712,920 | 71.29% |
| `bank_months_count` | 253,635 | 25.36% |
| `device_distinct_emails_8w` | 359 | 0.04% |

The cleaned view in `sql/03_transformations.sql` converts these values to `NULL` for analysis.