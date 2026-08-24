# Data

This project uses the Feedzai Bank Account Fraud (BAF) dataset.

I used `Base.csv` for the main analysis. It contains 1,000,000 synthetic, privacy-preserving bank account applications and 32 columns. The raw CSV is not committed to this repository, so anyone running the project needs to download the dataset separately.

## File Used

- Dataset: Feedzai Bank Account Fraud (BAF)
- File: `Base.csv`
- Rows: 1,000,000
- Columns: 32
- Target: `fraud_bool`
  - `0` = legitimate application
  - `1` = fraudulent application
- Time field: `month`
  - values run from 0 through 7

The BAF download also contains Variant I through Variant V. I kept this project focused on the Base dataset.

## Loading the Data

First run the staging-table script from the root of the repository.

### macOS / Linux

```bash
psql -d bank_fraud_account -f sql/01_staging_schema.sql
```

### Windows

```powershell
psql -U postgres -d bank_fraud_account -f sql/01_staging_schema.sql
```

Then load `Base.csv`. The file path must be the real location of `Base.csv` on your computer.

### macOS example

```bash
psql -d bank_fraud_account -c "\copy staging.raw_applications FROM '/Users/yourname/Downloads/Base.csv' WITH (FORMAT csv, HEADER true)"
```

If you do not know where the file is, you can search for it with:

```bash
find ~/Downloads -name "Base.csv"
```

### Windows example

Use forward slashes in the file path:

```powershell
psql -U postgres -d bank_fraud_account -c "\copy staging.raw_applications FROM 'C:/Users/YourName/Downloads/Base.csv' WITH (FORMAT csv, HEADER true)"
```

### Linux example

```bash
psql -d bank_fraud_account -c "\copy staging.raw_applications FROM '/home/yourname/Downloads/Base.csv' WITH (FORMAT csv, HEADER true)"
```

Do not type `/full/path/to/Base.csv` literally. That is only shorthand for the location of the CSV on your own computer.

## Confirm the Import

After loading the file, check the number of rows.

### macOS / Linux

```bash
psql -d bank_fraud_account -c "SELECT COUNT(*) FROM staging.raw_applications;"
```

### Windows

```powershell
psql -U postgres -d bank_fraud_account -c "SELECT COUNT(*) FROM staging.raw_applications;"
```

The expected result is:

```text
1000000
```

If the count is 1,000,000, the CSV loaded successfully.

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
