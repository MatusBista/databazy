-- Active: 1790058588830@@localhost@5433@retail
CREATE DATABASE retail;

-- CSV ma datumy v tvare den.mesiac.rok (napr. 17.2.2011)
ALTER DATABASE retail SET datestyle = 'ISO, DMY';

CREATE TABLE retail_sales (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(10,2),
    customer_id INTEGER,
    country VARCHAR(100)
);

SELECT *
FROM retail_sales;

SELECT COUNT(*), MIN(invoice_date), MAX(invoice_date)
FROM retail_sales;


