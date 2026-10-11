-- Active: 1790058588830@@localhost@5433@retail_sales
CREATE DATABASE retail_sales;

ALTER DATABASE retail_sales SET datestyle = 'ISO, MDY';

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR(30) NOT NULL,
    sales NUMERIC(10,2) NOT NULL,
    profit NUMERIC(10,2) NOT NULL
);

SELECT * FROM orders;

CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC(12,2);
BEGIN
    SELECT SUM(sales)
    INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Zakaznik: %, celkovy predaj: %', p_customer_id, v_total_sales;
END;
$$;

CALL get_customer_sales('C001');

CREATE OR REPLACE PROCEDURE apply_regional_discount(region_name VARCHAR, discount_rate NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - discount_rate)
    WHERE region = region_name;

    RAISE NOTICE 'Zlava % bola aplikovana pre region %', discount_rate, region_name;
END;
$$;

CALL apply_regional_discount('West', 0.10);