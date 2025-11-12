-- comparative_analysis.sql

-- Comparative Analysis: NYA vs N100 Average Close in Overlapping Years

WITH overlapping_years AS (
    SELECT DISTINCT STRFTIME('%Y', date) AS year
    FROM index_data WHERE index_name = 'NYA'
    INTERSECT
    SELECT DISTINCT STRFTIME('%Y', date) AS year
    FROM index_data WHERE index_name = 'N100'
),
comparative_data AS (
    SELECT 
        ny.date,
        ny.close AS ny_close,
        n100.close AS n100_close
    FROM index_data ny
    JOIN index_data n100 ON ny.date = n100.date
    WHERE ny.index_name = 'NYA' 
      AND n100.index_name = 'N100' 
      AND STRFTIME('%Y', ny.date) IN (SELECT year FROM overlapping_years)
      AND ny.close IS NOT NULL 
      AND n100.close IS NOT NULL
)
SELECT 
    STRFTIME('%Y', date) AS year,
    COUNT(*) AS overlapping_days,
    ROUND(AVG(ny_close), 2) AS ny_avg_close,
    ROUND(AVG(n100_close), 2) AS n100_avg_close,
    ROUND(
        (AVG(ny_close) - AVG(n100_close)) / AVG(n100_close) * 100, 2
    ) AS pct_diff
FROM comparative_data
GROUP BY STRFTIME('%Y', date)
HAVING overlapping_days > 30  -- Filter for meaningful overlap (e.g., >1 month)
ORDER BY year;

-- Rank days by volume (window function for ranking)
SELECT 
    index_name,
    date,
    volume,
    RANK() OVER (PARTITION BY index_name ORDER BY volume DESC) AS volume_rank
FROM index_data
WHERE volume > 0
LIMIT 10;
