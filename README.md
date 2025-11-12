# SQL Stock Market Analysis Portfolio  
Advanced Financial Analytics Using SQLite

---

Author: Daniel van Blerk  
Tech Stack: SQLite, VS Code, macOS, `indexData.csv`  

---

## Project Overview

This project demonstrates high-grade SQL skills through advanced financial queries on historical stock index data (`NYA`, `N100`, and others).  

All queries are:
- 100% SQLite-compatible (including legacy versions)
- Robust to real-world data issues (nulls, zeros, sparse dates)
- Designed for scalability and reproducibility

---

## Dataset: `indexData.csv`

| Column       | Type    | Description |
|--------------|---------|-----------|
| `index_name` | TEXT    | Stock index (e.g., `NYA`, `N100`) |
| `date`       | TEXT    | Trading date (YYYY-MM-DD) |
| `open`       | REAL    | Opening price |
| `high`       | REAL    | Daily high |
| `low`        | REAL    | Daily low |
| `close`      | REAL    | Closing price |
| `adj_close`  | REAL    | Adjusted close |
| `volume`     | INTEGER | Trading volume |

> Source: Public financial datasets (Yahoo Finance, etc.)

---

## Database Setup

```bash
# Create and import
sqlite3 stock_data.db << 'EOF'
CREATE TABLE index_data (
    index_name TEXT,
    date TEXT,
    open REAL,
    high REAL,
    low REAL,
    close REAL,
    adj_close REAL,
    volume INTEGER
);
.mode csv
.import indexData.csv index_data
EOF

### Query Year-over-Year (YoY) Growth

File: time_series_analysis.sql
Goal: Compare average closing price between current and previous year.
-- Uses CTEs, proper year offset, and NULL filtering
-- Key Insight: N100 grew +6.68% in 2021 vs 2020 (post-COVID recovery)

### Query Annual Volatility (Manual STDEV)

File: time_series_analysis.sql
Goal: Compute standard deviation of daily closes without STDEV()
-- SQLite has no STDEV() → Built from scratch using window functions
-- Population std dev: √(Σ(x - μ)² / N)
-- Key Insight: 2020 volatility: 94.35 (N100) vs ~30 in normal years → COVID crash

### NYA vs N100 Comparative Performance

File: comparative_analysis.sql
Goal: Compare average closes in overlapping years.
-- Uses INTERSECT + date JOIN + derived GROUP BY
-- Key Insight: In 2020, NYA averaged 12.5x higher than N100 (scale difference)

### High Volatility Days View

File: create_views.sql
Goal: Identify days with >5% intraday range.
-- CREATE VIEW with CTE for safety
-- Key Insight: 1987-10-19 (Black Monday): NYA intraday range = 22.45%

### Annual Returns

File: final_reporting_query.sql
Goal: Compute average daily return per year using LAG().
-- Key Insight: NYA 1987: -0.0891% avg daily return → -22.3% annualized

### SQLite Version Awareness

Function,Available?,Version,Used?
LAG(),Yes,All,Yes
LOG() / EXP(),No,< 3.38,Removed
STDEV(),No,All,Manual

### Skills Demonstrated

Advanced CTEs & Window Functions
Manual Statistical Computation
Error Diagnosis & Debugging
    database is locked
    no such function: LN
    misuse of window function
Financial Logic (returns, volatility, YoY)
SQLite Limitations & Workarounds
Clean, Commented, Reusable Code

### How To Run

# 1. Open DB
sqlite3 stock_data.db

# 2. Run any query
sqlite3 stock_data.db ".exploratory_analysis.sql"

# 3. Export
sqlite3 -header -csv stock_data.db "SELECT * FROM annual_returns;" > returns.csv