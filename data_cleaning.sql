-- data_cleaning.sql

-- Handle nulls - Remove fully null rows (e.g., 1967-02-23)
DELETE FROM index_data
WHERE open IS NULL AND high IS NULL AND low IS NULL AND close IS NULL AND adj_close IS NULL AND volume IS NULL;

-- Check for duplicates using CTE
WITH duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY index_name, date ORDER BY date) AS row_num
    FROM index_data
)
DELETE FROM index_data
WHERE (index_name, date) IN (
    SELECT index_name, date
    FROM duplicates
    WHERE row_num > 1
);

-- Assign missing values
UPDATE index_data
SET close = COALESCE(close, (SELECT LAG(close) OVER (PARTITION BY index_name ORDER BY date) FROM index_data AS sub WHERE sub.rowid = index_data.rowid))
WHERE close IS NULL;

-- Ensure data integrity (e.g., volume >= 0)
UPDATE index_data SET volume = 0 WHERE volume < 0 OR volume IS NULL;

-- Verify cleaning
SELECT * FROM index_data WHERE open IS NULL;  -- Should be empty