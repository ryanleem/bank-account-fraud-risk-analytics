# Findings

This file gives the short version of what I found. The full tables and notes are in [`../results/fraud_findings.md`](../results/fraud_findings.md).

## Main Results

- Overall fraud rate: 1.10%
- `housing_status = BA` had a 3.75% fraud rate
- `payment_type = AC` + `employment_status = CC` + `housing_status = BA` had an 8.73% fraud rate
- Among applications with `credit_risk_score > 269`, the `AC + CA + BA` group had an 11.74% fraud rate
- That 11.74% rate was about 10.64 times the overall fraud rate

## Risk Score

The final score uses six conditions and ranges from 0 to 7.

Fraud rate increased as the score increased:

- score 0: 0.11%
- score 1: 0.33%
- score 2: 0.70%
- score 3: 1.40%
- score 4: 3.29%
- score 5: 8.81%
- score 6: 17.51%
- score 7: 42.55%

I used `risk_score >= 5` as the final flag.

## Later-Period Results

On months 6-7, the frozen rule had:

- precision: 13.32%
- recall: 10.56%
- false-positive rate: 0.98%
- specificity: 99.02%
- F1: 0.1178

The rule is better at finding a smaller, higher-risk group than at catching every fraud case.

## Data Quality

Three fields had `-1` values that needed to be handled as special/missing values in the cleaned view:

- `prev_address_months_count`: 71.29%
- `bank_months_count`: 25.36%
- `device_distinct_emails_8w`: 0.04%

## Important Limitation

I had already looked at months 6-7 earlier during exploration, so I do not describe them as a perfectly untouched holdout set.