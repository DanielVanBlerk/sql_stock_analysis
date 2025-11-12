-- final_reporting_query.sql

-- Comprehensive report using multiple CTEs

WITH cleaned_data AS (
    SELECT *
    FROM index_data
    WHERE close IS NOT NULL
      AND date IS NOT NULL
),
daily_returns AS (
    SELECT 
        index_name,
        date,
        STRFTIME('%Y', date) AS year,
        close,
        LAG(close) OVER (
            PARTITION BY index_name, STRFTIME('%Y', date) 
            ORDER BY date
        ) AS prev_close,
        CASE 
            WHEN LAG(close) OVER (
                PARTITION BY index_name, STRFTIME('%Y', date) 
                ORDER BY date
            ) IS NULL OR LAG(close) OVER (
                PARTITION BY index_name, STRFTIME('%Y', date) 
                ORDER BY date
            ) = 0 THEN NULL
            ELSE ROUND(
                (close - LAG(close) OVER (
                    PARTITION BY index_name, STRFTIME('%Y', date) 
                    ORDER BY date
                )) 
                / LAG(close) OVER (
                    PARTITION BY index_name, STRFTIME('%Y', date) 
                    ORDER BY date
                ) * 100, 4
            )
        END AS daily_return_pct
    FROM cleaned_data
),
annual_returns AS (
    SELECT 
        index_name,
        year,
        COUNT(*) AS trading_days,
        ROUND(AVG(daily_return_pct), 4) AS avg_daily_return_pct
    FROM daily_returns
    WHERE daily_return_pct IS NOT NULL
    GROUP BY index_name, year
    HAVING trading_days > 100
)
SELECT 
    index_name,
    year,
    trading_days,
    avg_daily_return_pct
FROM annual_returns
ORDER BY index_name, year;