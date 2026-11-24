\set ON_ERROR_STOP on

CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE VIEW silver.categories AS
SELECT id AS category_id,
       TRIM(name) AS category_name,
       TRIM(description) AS description
FROM bronze.categories;

CREATE OR REPLACE VIEW silver.customers AS
SELECT id AS customer_id,
       TRIM(name) AS customer_name,
       TRIM(contact_name) AS contact_name,
       TRIM(address) AS address,
       CASE WHEN TRIM(city) = 'Frankfurt a.M.' THEN 'Frankfurt' ELSE TRIM(city) END AS city,
       NULLIF(TRIM(postal_code), '') AS postal_code,
       TRIM(country) AS country
FROM bronze.customers;

CREATE OR REPLACE VIEW silver.employees AS
SELECT id AS employee_id,
       TRIM(first_name) AS first_name,
       TRIM(last_name) AS last_name,
       birth_date,
       TRIM(notes) AS notes
FROM bronze.employees;

CREATE OR REPLACE VIEW silver.shippers AS
SELECT id AS shipper_id,
       TRIM(name) AS shipper_name,
       TRIM(phone) AS phone
FROM bronze.shippers;

CREATE OR REPLACE VIEW silver.suppliers AS
SELECT id AS supplier_id,
       TRIM(name) AS supplier_name,
       TRIM(contact_name) AS contact_name,
       TRIM(address) AS address,
       CASE WHEN TRIM(city) = 'Londona' THEN 'London' ELSE TRIM(city) END AS city,
       NULLIF(TRIM(postal_code), '') AS postal_code,
       TRIM(country) AS country,
       TRIM(phone) AS phone
FROM bronze.suppliers;

CREATE OR REPLACE VIEW silver.products AS
SELECT id AS product_id,
       TRIM(name) AS product_name,
       supplier_id,
       category_id,
       TRIM(unit) AS unit,
       price
FROM bronze.products;

CREATE OR REPLACE VIEW silver.orders AS
SELECT id AS order_id,
       customer_id,
       employee_id,
       order_date,
       shipper_id
FROM bronze.orders;

CREATE OR REPLACE VIEW silver.order_details AS
SELECT id AS order_detail_id,
       order_id,
       product_id,
       quantity
FROM bronze.order_details;
