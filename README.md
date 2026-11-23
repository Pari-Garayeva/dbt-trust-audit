# dbt-trust-audit

## The problem
dbt tests only check the rules someone remembered to write. When a test is
missing, `dbt build` still reports everything green. In the demo project below,
`dbt build` passes 12 of 12 checks, yet a hidden duplicate customer fans out
`fct_orders` from 6 to 8 rows, and total revenue reads 285 instead of 200.
dbt-trust-audit looks at both the project metadata and the actual data to find
these gaps.

## Status
Work in progress — Stage 0: demo project with planted issues.

## Demo
Requirements: Python 3.10+

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install "dbt-core>=1.10,<2" dbt-duckdb duckdb

cd examples\demo_shop
dbt debug --profiles-dir .    # expect: All checks passed!
dbt seed  --profiles-dir .    # loads 3 CSV files into DuckDB
dbt build --profiles-dir .    # expect: PASS=12 WARN=0 ERROR=0
```

Everything is green. Now check the data directly:

```powershell
python -c "import duckdb; print(duckdb.connect('demo_shop.duckdb', read_only=True).sql('select order_id, count(*) from main.fct_orders group by 1 having count(*) > 1'))"
```

Expected: orders `103` and `104` each appear twice. One order should be one row.

### Planted issues

| Code | Model | Issue |
|------|-------|-------|
| M001 | `stg_customers` | No `unique` / `not_null` test on the primary key |
| M002 | `stg_payments`, `dim_customers` | Layer violation: staging reads staging, mart reads source |
| D001 | `stg_customers` | Hidden duplicate: `customer_id = 3` appears twice |
| D002 | `fct_orders` | Fan-out: the join multiplies order rows |