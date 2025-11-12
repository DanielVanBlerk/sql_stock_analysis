-- create_views.sql

-- View for high-volatility periods
CREATE VIEW high_volatility_days AS
SELECT 
    index_name,
    date,
    (high - low) / open * 100 AS intraday_vol_pct
FROM index_data
WHERE intraday_vol_pct > 5;  -- Threshold for "high"

-- Query the view
SELECT * FROM high_volatility_days ORDER BY intraday_vol_pct DESC LIMIT 5;