-- create_indexes.sql

-- Create indexes for faster queries on large data
CREATE INDEX idx_index_date ON index_data (index_name, date);
CREATE INDEX idx_date ON index_data (date);