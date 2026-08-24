# Fraud Analytics Findings

## Overview

This project looks at 1,000,000 bank account applications from the Feedzai Bank Account Fraud dataset.

Out of the 1,000,000 applications:

- 11,029 were fraud
- 988,971 were legitimate
- Overall fraud rate: 1.10%

Fraud only makes up a small part of the dataset, so accuracy by itself would not be very useful. A model could call almost everything legitimate and still look accurate.

Instead, I focused more on:

- which groups had higher fraud rates
- how much fraud was concentrated in those groups
- precision
- recall
- false-positive rate
- F1 score

---

## 1. Basic Fraud Patterns

I started by looking at individual categories to see if certain groups had noticeably different fraud rates.

### Payment Type

| Payment Type | Applications | Fraud Cases | Fraud Rate |
|---|---:|---:|---:|
| AC | 252,071 | 4,209 | 1.67% |
| AB | 370,554 | 4,169 | 1.13% |
| AD | 118,837 | 1,286 | 1.08% |
| AA | 258,249 | 1,364 | 0.53% |
| AE | 289 | 1 | 0.35% |

`AC` had the highest fraud rate out of the major payment types.

### Employment Status

| Employment Status | Applications | Fraud Cases | Fraud Rate |
|---|---:|---:|---:|
| CC | 37,758 | 932 | 2.47% |
| CG | 453 | 7 | 1.55% |
| CA | 730,252 | 8,899 | 1.22% |
| CB | 138,288 | 953 | 0.69% |
| CD | 26,522 | 100 | 0.38% |
| CE | 22,693 | 53 | 0.23% |
| CF | 44,034 | 85 | 0.19% |

`CC` had the highest fraud rate among the larger groups.

### Housing Status

| Housing Status | Applications | Fraud Cases | Fraud Rate |
|---|---:|---:|---:|
| BA | 169,675 | 6,357 | 3.75% |
| BD | 26,161 | 226 | 0.86% |
| BC | 372,143 | 2,288 | 0.61% |
| BB | 260,965 | 1,568 | 0.60% |
| BF | 1,669 | 7 | 0.42% |
| BG | 252 | 1 | 0.40% |
| BE | 169,135 | 582 | 0.34% |

The biggest thing that stood out here was `BA`.

Its fraud rate was 3.75%, compared with the overall dataset rate of only 1.10%.

---

## 2. Combining Multiple Risk Factors

Looking at one variable at a time was useful, but the more interesting results showed up when I combined multiple features.

I grouped applications by:

- payment type
- employment status
- housing status

I only kept groups with at least 1,000 applications so very small groups would not dominate the results.

| Payment | Employment | Housing | Applications | Fraud Cases | Fraud Rate |
|---|---|---|---:|---:|---:|
| AC | CC | BA | 2,221 | 194 | 8.73% |
| AB | CC | BA | 3,597 | 227 | 6.31% |
| AC | CA | BA | 35,447 | 2,118 | 5.98% |
| AD | CA | BA | 14,681 | 601 | 4.09% |
| AB | CA | BA | 52,504 | 2,009 | 3.83% |

The strongest group was:

`AC + CC + BA`

That group had an 8.73% fraud rate.

For comparison, the overall fraud rate was only 1.10%.

Fraud was much more concentrated when several higher-risk characteristics appeared together.

---

## 3. High Credit-Risk Groups

I also found that higher `credit_risk_score` values were associated with higher fraud rates.

Using development months 0-5, I tested different thresholds and found that:

`credit_risk_score > 269`

gave the best F1 score out of the thresholds I tested.

I then looked at category combinations only among applications above that threshold.

| Payment | Employment | Housing | Applications | Fraud Cases | Fraud Rate | Lift |
|---|---|---|---:|---:|---:|---:|
| AC | CA | BA | 4,132 | 485 | 11.74% | 10.64x |
| AD | CA | BA | 2,016 | 145 | 7.19% | 6.52x |
| AB | CA | BA | 7,607 | 529 | 6.95% | 6.31x |
| AC | CA | BB | 1,007 | 43 | 4.27% | 3.87x |
| AA | CA | BA | 2,138 | 81 | 3.79% | 3.44x |

The strongest group here was:

`AC + CA + BA`

with a fraud rate of 11.74%.

That is about 10.6 times the overall fraud rate.

---

## 4. Building a Simple Fraud Risk Score

After looking at the patterns, I built a rule-based score.

I wanted it to stay simple and easy to explain instead of turning it into a black-box model.

### Scoring Rules

| Condition | Points |
|---|---:|
| `credit_risk_score > 269` | +2 |
| `name_email_similarity <= 0.18` | +1 |
| `device_distinct_emails_8w = 2` | +1 |
| `phone_home_valid = 0` | +1 |
| `email_is_free = 1` | +1 |
| `has_other_cards = 0` | +1 |

Applications with a total score of 5 or higher are flagged as higher risk.

---

## 5. Fraud Rate by Risk Score

One of the clearest results in the project was how fraud rate changed as the score increased.

| Risk Score | Applications | Fraud Cases | Fraud Rate | Lift |
|---:|---:|---:|---:|---:|
| 0 | 44,470 | 50 | 0.11% | 0.10x |
| 1 | 204,192 | 684 | 0.33% | 0.30x |
| 2 | 377,554 | 2,651 | 0.70% | 0.64x |
| 3 | 288,585 | 4,046 | 1.40% | 1.27x |
| 4 | 73,567 | 2,420 | 3.29% | 2.98x |
| 5 | 10,003 | 881 | 8.81% | 7.99x |
| 6 | 1,582 | 277 | 17.51% | 15.88x |
| 7 | 47 | 20 | 42.55% | 38.58x |

The important part is the overall pattern:

higher score = higher fraud rate.

For example:

- score 2: 0.70%
- score 4: 3.29%
- score 5: 8.81%
- score 6: 17.51%

Score 7 had a very high fraud rate, but there were only 47 applications in that group, so I would not put too much weight on that number by itself.

---

## 6. Testing the Score on Later Months

I used months 0-5 as the development period and months 6-7 as a later validation period.

The final score was rebuilt using only months 0-5, then tested on months 6-7.

| Metric | Development | Validation |
|---|---:|---:|
| True Positives | 874 | 304 |
| False Positives | 8,476 | 1,978 |
| False Negatives | 7,277 | 2,574 |
| True Negatives | 778,362 | 200,155 |
| Precision | 9.35% | 13.32% |
| Recall | 10.72% | 10.56% |
| False Positive Rate | 1.08% | 0.98% |
| Specificity | 98.92% | 99.02% |
| F1 Score | 0.0999 | 0.1178 |

The main thing I cared about here was whether the rule completely fell apart on the later period.

It did not.

Recall stayed almost the same:

- 10.72% in development
- 10.56% in validation

Precision actually improved:

- 9.35% in development
- 13.32% in validation

The false-positive rate also stayed around 1%.

This means the rule is fairly selective.

It does not catch most fraud, so I would not describe it as a complete fraud-detection system.

It works better as a screening rule that finds a smaller group of applications with much higher fraud concentration.

---

## 7. Data Quality

I also checked the raw data before using it for analysis.

One thing I found was that several columns used `-1` as a special or missing value instead of using SQL `NULL`.

| Field | Rows Using -1 | Percent |
|---|---:|---:|
| `prev_address_months_count` | 712,920 | 71.29% |
| `bank_months_count` | 253,635 | 25.36% |
| `device_distinct_emails_8w` | 359 | 0.04% |

I created a cleaned SQL view that converts those `-1` values into `NULL`.

I kept the original staging table unchanged so the raw data is still preserved.

---

## Main Takeaways

The biggest things I found were:

1. Fraud only made up about 1.10% of applications.
2. Some categories had much higher fraud rates than others.
3. Combining multiple risk factors exposed groups with much higher fraud concentration.
4. Some high-risk groups had fraud rates more than 10 times the overall average.
5. The rule-based score had a clear relationship with actual fraud rate.
6. Scores of 5 and 6 were especially useful for finding higher-risk applications.
7. The score stayed fairly consistent when I tested it on later months.

---

## Limitations

This dataset is synthetic and privacy-preserving, so it should not be treated exactly like raw production banking data.

The score is also rule-based. It is not meant to replace a real fraud model.

I had already looked at months 6-7 earlier while exploring the dataset, so I would describe them as a later-period validation set rather than a perfectly untouched holdout set.

The results also show associations, not causation. A feature being linked with a higher fraud rate does not mean that feature causes fraud.