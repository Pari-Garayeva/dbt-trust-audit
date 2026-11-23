# ADR-001: Audit data, not only metadata

- Status: Accepted
- Date: 2026-11-23

## Context
Existing dbt quality tools (dbt-project-evaluator, dbt-score, dbt-bouncer)
inspect the project's metadata: the DAG, naming conventions, test and
documentation coverage. They can tell that a primary key has no `unique` test,
but they never look inside the tables, so they cannot tell whether the data
actually has duplicates.

The demo project shows the gap. `dbt build` reports PASS=12 ERROR=0, yet
`stg_customers` contains a duplicate `customer_id`, the join in `fct_orders`
turns 6 orders into 8 rows, and total revenue reads 285 instead of 200.
Metadata-only tools would flag the missing test (M001), but not the wrong
numbers (D001, D002).

## Decision
dbt-trust-audit runs checks in two layers:

1. **Metadata layer (M rules).** Reads `manifest.json` only. Needs no database
   connection. Finds structural problems such as missing primary-key tests,
   layer violations and hard-coded table names.
2. **Data layer (D rules).** Connects to the warehouse with read-only access and
   queries the built models. Finds problems that only show up in the data, such
   as hidden duplicates and join fan-out.

The data layer is the main difference from existing tools. The metadata layer
is still needed, because it tells the data layer where to look and explains
why an issue went unnoticed.

## Consequences
**Positive**
- Finds issues that both dbt tests and metadata linters miss.
- Can link a cause to its effect, e.g. missing test (M001), then duplicate
  (D001), then inflated revenue (D002).
- The metadata layer can still run alone, offline and fast.

**Negative**
- Data checks need a database connection. In CI this means storing warehouse
  credentials as secrets and allowing network access to the warehouse.
- Queries take time, and on Snowflake or BigQuery they cost money.
- Results depend on the data at run time, so the same code can pass today and
  fail tomorrow.
- SQL may differ between warehouses, so each adapter needs testing.
  Stage 0 supports DuckDB only.