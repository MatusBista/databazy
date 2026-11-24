\set ON_ERROR_STOP on

CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_countries (
    dim_countries_id INT PRIMARY KEY,
    country_name VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS gold.dim_cities (
    dim_cities_id INT PRIMARY KEY,
    city_name VARCHAR(20) NOT NULL,
    dim_countries_id INT NOT NULL,
    FOREIGN KEY (dim_countries_id) REFERENCES gold.dim_countries (dim_countries_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_customers (
    dim_customers_id INT PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    postal_code VARCHAR(10),
    dim_cities_id INT,
    FOREIGN KEY (dim_cities_id) REFERENCES gold.dim_cities (dim_cities_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_suppliers (
    dim_suppliers_id INT PRIMARY KEY,
    supplier_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    postal_code VARCHAR(10),
    dim_cities_id INT,
    FOREIGN KEY (dim_cities_id) REFERENCES gold.dim_cities (dim_cities_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_categories (
    dim_categories_id INT PRIMARY KEY,
    category_name VARCHAR(25) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS gold.dim_products (
    dim_products_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    unit VARCHAR(25),
    dim_categories_id INT NOT NULL,
    dim_suppliers_id INT NOT NULL,
    FOREIGN KEY (dim_categories_id) REFERENCES gold.dim_categories (dim_categories_id),
    FOREIGN KEY (dim_suppliers_id) REFERENCES gold.dim_suppliers (dim_suppliers_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_employees (
    dim_employees_id INT PRIMARY KEY,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    birth_date DATE
);

CREATE TABLE IF NOT EXISTS gold.dim_shippers (
    dim_shippers_id INT PRIMARY KEY,
    shipper_name VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    dim_date_id INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    day_of_week_name VARCHAR(10) NOT NULL,
    week INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.fact_sales (
    fact_sales_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    dim_date_id INT NOT NULL,
    dim_customers_id INT NOT NULL,
    dim_products_id INT NOT NULL,
    dim_employees_id INT,
    dim_shippers_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (dim_date_id) REFERENCES gold.dim_date (dim_date_id),
    FOREIGN KEY (dim_customers_id) REFERENCES gold.dim_customers (dim_customers_id),
    FOREIGN KEY (dim_products_id) REFERENCES gold.dim_products (dim_products_id),
    FOREIGN KEY (dim_employees_id) REFERENCES gold.dim_employees (dim_employees_id),
    FOREIGN KEY (dim_shippers_id) REFERENCES gold.dim_shippers (dim_shippers_id)
);

BEGIN;

TRUNCATE gold.fact_sales, gold.dim_date, gold.dim_shippers, gold.dim_employees, gold.dim_products, gold.dim_categories, gold.dim_suppliers, gold.dim_customers, gold.dim_cities, gold.dim_countries;

INSERT INTO gold.dim_countries (dim_countries_id, country_name)
SELECT ROW_NUMBER() OVER (ORDER BY country), country
FROM (
    SELECT country FROM silver.customers
    UNION
    SELECT country FROM silver.suppliers
) AS countries;

INSERT INTO gold.dim_cities (dim_cities_id, city_name, dim_countries_id)
SELECT ROW_NUMBER() OVER (ORDER BY c.country, c.city), c.city, co.dim_countries_id
FROM (
    SELECT city, country FROM silver.customers
    UNION
    SELECT city, country FROM silver.suppliers
) AS c
JOIN gold.dim_countries co ON co.country_name = c.country;

INSERT INTO gold.dim_customers (dim_customers_id, customer_name, contact_name, postal_code, dim_cities_id)
SELECT cu.customer_id, cu.customer_name, cu.contact_name, cu.postal_code, ci.dim_cities_id
FROM silver.customers cu
JOIN gold.dim_countries co ON co.country_name = cu.country
JOIN gold.dim_cities ci ON ci.city_name = cu.city AND ci.dim_countries_id = co.dim_countries_id;

INSERT INTO gold.dim_suppliers (dim_suppliers_id, supplier_name, contact_name, postal_code, dim_cities_id)
SELECT s.supplier_id, s.supplier_name, s.contact_name, s.postal_code, ci.dim_cities_id
FROM silver.suppliers s
JOIN gold.dim_countries co ON co.country_name = s.country
JOIN gold.dim_cities ci ON ci.city_name = s.city AND ci.dim_countries_id = co.dim_countries_id;

INSERT INTO gold.dim_categories (dim_categories_id, category_name, description)
SELECT category_id, category_name, description
FROM silver.categories;

INSERT INTO gold.dim_products (dim_products_id, product_name, unit, dim_categories_id, dim_suppliers_id)
SELECT product_id, product_name, unit, category_id, supplier_id
FROM silver.products;

INSERT INTO gold.dim_employees (dim_employees_id, first_name, last_name, birth_date)
SELECT employee_id, first_name, last_name, birth_date
FROM silver.employees;

INSERT INTO gold.dim_shippers (dim_shippers_id, shipper_name)
SELECT shipper_id, shipper_name
FROM silver.shippers;

INSERT INTO gold.dim_date (dim_date_id, full_date, day, day_of_week, day_of_week_name, week, month, month_name, quarter, year)
SELECT TO_CHAR(d, 'YYYYMMDD')::INT,
       d,
       EXTRACT(DAY FROM d),
       EXTRACT(ISODOW FROM d),
       TO_CHAR(d, 'FMDay'),
       EXTRACT(WEEK FROM d),
       EXTRACT(MONTH FROM d),
       TO_CHAR(d, 'FMMonth'),
       EXTRACT(QUARTER FROM d),
       EXTRACT(YEAR FROM d)
FROM (
    SELECT generate_series(MIN(order_date), MAX(order_date), INTERVAL '1 day')::DATE AS d
    FROM silver.orders
) AS dates;

INSERT INTO gold.fact_sales (fact_sales_id, order_id, dim_date_id, dim_customers_id, dim_products_id, dim_employees_id, dim_shippers_id, quantity, unit_price, total_price)
SELECT od.order_detail_id,
       o.order_id,
       dd.dim_date_id,
       o.customer_id,
       od.product_id,
       o.employee_id,
       o.shipper_id,
       od.quantity,
       p.price,
       od.quantity * p.price
FROM silver.order_details od
JOIN silver.orders o ON o.order_id = od.order_id
JOIN silver.products p ON p.product_id = od.product_id
JOIN gold.dim_date dd ON dd.full_date = o.order_date;

COMMIT;
