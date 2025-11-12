-- exploratory_analysis.sql

-- Overall summary per index
SELECT 
    index_name,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    COUNT(*) AS total_days,
    AVG(close) AS avg_close,
    MAX(high) - MIN(low) AS max_range
FROM index_data
GROUP BY index_name;

-- Yearly aggregates using STRFTIME (advanced date functions)
SELECT 
    index_name,
    STRFTIME('%Y', date) AS year,
    AVG(volume) AS avg_volume,
    SUM(volume) AS total_volume
FROM index_data
GROUP BY index_name, year
ORDER BY index_name, year;
