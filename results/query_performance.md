# Query Performance

I used PostgreSQL `EXPLAIN ANALYZE` on the 1,000,000-row Base dataset to see which query plans PostgreSQL actually chose.

## Results

| Query | Access Path | Execution Time |
|---|---|---:|
| `credit_risk_score > 269` | Index Only Scan | ~6-7 ms |
| `month >= 6` | Parallel Index Only Scan | ~28 ms |
| `phone_home_valid = 0` | Parallel Sequential Scan | ~67 ms |

## Credit Risk Query

I created an index on `credit_risk_score` and tested:

```sql
SELECT COUNT(*)
FROM staging.raw_applications
WHERE credit_risk_score > 269;
```

PostgreSQL used:

`Index Only Scan using idx_raw_applications_credit_risk`

The query returned 33,640 matching rows and had `Heap Fetches: 0`, which means PostgreSQL could answer the count directly from the index.

The measured execution time was around 6-7 ms.

## Month Query

I also created an index on `month` and tested:

```sql
SELECT COUNT(*)
FROM staging.raw_applications
WHERE month >= 6;
```

PostgreSQL used a `Parallel Index Only Scan` with zero heap fetches.

The measured execution time was about 28 ms.

## Broad Phone Filter

I tested this query without adding an index just to see what PostgreSQL would choose:

```sql
SELECT COUNT(*)
FROM staging.raw_applications
WHERE phone_home_valid = 0;
```

PostgreSQL chose a `Parallel Seq Scan` and finished in about 67 ms.

This condition matches more than half of the dataset, so a sequential scan makes sense here. This was a good example of why adding an index to every column is not automatically better.