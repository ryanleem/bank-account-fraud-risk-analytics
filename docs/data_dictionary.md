# Data Dictionary

The main analysis uses the 32 columns from Feedzai's `Base.csv` file.

| Column | PostgreSQL Type | Notes |
|---|---|---|
| `fraud_bool` | INTEGER | Target. `1` = fraud, `0` = legitimate. |
| `income` | NUMERIC | Encoded/normalized income value from the dataset. Not treated as a literal salary amount. |
| `name_email_similarity` | NUMERIC | Similarity score between name and email. Values are close to 0-1. |
| `prev_address_months_count` | INTEGER | Months at previous address. `-1` is treated as a special/missing value in the cleaned view. |
| `current_address_months_count` | INTEGER | Months at current address. |
| `customer_age` | INTEGER | Applicant age. |
| `days_since_request` | NUMERIC | Time since the related request. Highly skewed in this dataset. |
| `intended_balcon_amount` | NUMERIC | Intended balance-related amount from the source dataset. |
| `payment_type` | TEXT | Encoded payment category such as AA, AB, AC, AD, or AE. |
| `zip_count_4w` | INTEGER | ZIP-related count over a four-week window. |
| `velocity_6h` | NUMERIC | Activity velocity over six hours. |
| `velocity_24h` | NUMERIC | Activity velocity over 24 hours. |
| `velocity_4w` | NUMERIC | Activity velocity over four weeks. |
| `bank_branch_count_8w` | INTEGER | Bank branch-related count over eight weeks. |
| `date_of_birth_distinct_emails_4w` | INTEGER | Distinct emails linked with the date of birth over four weeks. |
| `employment_status` | TEXT | Encoded employment category such as CA, CB, CC, etc. |
| `credit_risk_score` | INTEGER | Dataset-specific credit risk score. Observed range: -170 to 389. |
| `email_is_free` | INTEGER | `1` if the email provider is free, otherwise `0`. |
| `housing_status` | TEXT | Encoded housing category such as BA, BB, BC, etc. |
| `phone_home_valid` | INTEGER | `1` if home phone is valid, otherwise `0`. |
| `phone_mobile_valid` | INTEGER | `1` if mobile phone is valid, otherwise `0`. |
| `bank_months_count` | INTEGER | Months with bank relationship. `-1` is treated as a special/missing value in the cleaned view. |
| `has_other_cards` | INTEGER | `1` if applicant has other cards, otherwise `0`. |
| `proposed_credit_limit` | NUMERIC | Proposed credit limit. |
| `foreign_request` | INTEGER | `1` if request is foreign, otherwise `0`. |
| `source` | TEXT | Application source. Values found: `INTERNET` and `TELEAPP`. |
| `session_length_in_minutes` | NUMERIC | Session length in minutes. |
| `device_os` | TEXT | Device operating system. Values found: linux, macintosh, other, windows, x11. |
| `keep_alive_session` | INTEGER | Session keep-alive indicator. |
| `device_distinct_emails_8w` | INTEGER | Distinct emails connected to a device over eight weeks. `-1` is treated as a special/missing value in the cleaned view. |
| `device_fraud_count` | INTEGER | Fraud-related device count from the source dataset. |
| `month` | INTEGER | Ordered month index from 0 through 7. Used for the development/later-period split. |

## Fields Used in the Final Risk Score

The final rule uses:

- `credit_risk_score`
- `name_email_similarity`
- `device_distinct_emails_8w`
- `phone_home_valid`
- `email_is_free`
- `has_other_cards`

The score is described in `sql/07_risk_scoring.sql`.