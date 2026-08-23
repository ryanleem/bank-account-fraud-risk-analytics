# Bank Account Fraud Risk Analytics

PostgreSQL project for analyzing bank account fraud, uncovering suspicious patterns, and evaluating fraud risk.

## Project Goal

Build a SQL-first fraud analytics workflow using the Feedzai Bank Account Fraud (BAF) dataset. The project will focus on data validation, fraud-pattern analysis, explainable risk rules, detection evaluation, and PostgreSQL performance optimization.

## Planned Workflow

1. Inspect and understand the source data
2. Load raw data into a staging layer
3. Run data-quality and validation checks
4. Build clean analytical tables
5. Establish baseline fraud metrics
6. Investigate higher-risk applicant patterns and interactions
7. Build an explainable SQL-based fraud risk score
8. Evaluate false positives, false negatives, precision, and recall
9. Analyze fraud-pattern changes over time
10. Create reusable views and materialized views where appropriate
11. Add indexes based on real query patterns
12. Use `EXPLAIN ANALYZE` to measure and improve query performance

## Tech Stack

- PostgreSQL
- SQL
- Git / GitHub

## Data Source

This project uses the Bank Account Fraud (BAF) dataset published by Feedzai. Dataset files are not committed to this repository. See [`data/README.md`](data/README.md) for source and setup notes.

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

## Status

In development. SQL will be added as the source data is profiled and each analytical step is completed.
