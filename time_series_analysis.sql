-- time_series_analysis.sql

-- CTE for daily returns (percentage change using LAG)
WITH daily_returns AS (
    SELECT 
        index_name,
        date,
        close,
        LAG(close) OVER (PARTITION BY index_name ORDER BY date) AS prev_close,
        (close - LAG(close) OVER (PARTITION BY index_name ORDER BY date)) / LAG(close) OVER (PARTITION BY index_name ORDER BY date) * 100 AS daily_return_pct
    FROM index_data
)
SELECT * FROM daily_returns WHERE daily_return_pct IS NOT NULL LIMIT 10;

-- Moving average (30-day) using window functions
SELECT 
    index_name,
    date,
    close,
    AVG(close) OVER (PARTITION BY index_name ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS ma_30
FROM index_data
ORDER BY index_name, date;

-- Year-over-Year (YoY) Average Close Price Growth
-- Uses CTEs for clarity, window functions for validation, and proper year logic

WITH yearly_averages AS (
    SELECT 
        index_name,
        STRFTIME('%Y', date) AS year,
        AVG(close) AS avg_close,
        COUNT(*) AS trading_days
    FROM index_data
    WHERE close IS NOT NULL
    GROUP BY index_name, STRFTIME('%Y', date)
),
yoy_growth AS (
    SELECT 
        curr.index_name,
        curr.year,
        curr.avg_close AS avg_close_current,
        prev.avg_close AS avg_close_previous,
        curr.trading_days,
        prev.trading_days AS prev_trading_days,
        ROUND(
            (curr.avg_close - prev.avg_close) / prev.avg_close * 100, 2
        ) AS yoy_growth_pct
    FROM yearly_averages curr
    LEFT JOIN yearly_averages prev
        ON curr.index_name = prev.index_name
       AND CAST(curr.year AS INTEGER) = CAST(prev.year AS INTEGER) + 1
)
SELECT 
    index_name,
    year,
    ROUND(avg_close_current, 2) AS avg_close_current,
    ROUND(avg_close_previous, 2) AS avg_close_previous,
    yoy_growth_pct,
    trading_days,
    prev_trading_days
FROM yoy_growth
WHERE yoy_growth_pct IS NOT NULL
ORDER BY index_name, year;

-- Annual Volatility (Population Standard Deviation) per Index & Year

WITH yearly_stats AS (
    SELECT 
        index_name,
        STRFTIME('%Y', date) AS year,
        close,
        AVG(close) OVER (PARTITION BY index_name, STRFTIME('%Y', date)) AS year_avg_close,
        COUNT(*) OVER (PARTITION BY index_name, STRFTIME('%Y', date)) AS days_in_year
    FROM index_data
    WHERE close IS NOT NULL
),
squared_diffs AS (
    SELECT 
        index_name,
        year,
        close,
        year_avg_close,
        days_in_year,
        (close - year_avg_close) * (close - year_avg_close) AS squared_diff
    FROM yearly_stats
),
volatility_calc AS (
    SELECT 
        index_name,
        year,
        days_in_year,
        SUM(squared_diff) AS sum_squared_diffs
    FROM squared_diffs
    GROUP BY index_name, year, days_in_year
)
SELECT 
    index_name,
    year,
    days_in_year AS trading_days,
    ROUND(sum_squared_diffs / days_in_year, 6) AS variance,
    ROUND(
        SQRT(sum_squared_diffs / days_in_year), 4
    ) AS annual_volatility
FROM volatility_calc
WHERE days_in_year > 1  -- Avoid division by 1 or 0 (e.g., incomplete years)
ORDER BY index_name, year;