CREATE DATABASE northwind_dwh;

CREATE TABLE dim_customers (
    dim_customers_id INT PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    city VARCHAR(20),
    postal_code VARCHAR(10),
    country VARCHAR(15)
);

CREATE TABLE dim_products (
    dim_products_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    unit VARCHAR(25),
    category_name VARCHAR(25),
    category_description VARCHAR(255)
);

CREATE TABLE dim_suppliers (
    dim_suppliers_id INT PRIMARY KEY,
    supplier_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    city VARCHAR(20),
    postal_code VARCHAR(10),
    country VARCHAR(15)
);

CREATE TABLE dim_employees (
    dim_employees_id INT PRIMARY KEY,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    birth_date DATE
);

CREATE TABLE dim_shippers (
    dim_shippers_id INT PRIMARY KEY,
    shipper_name VARCHAR(25) NOT NULL
);

CREATE TABLE dim_date (
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

CREATE TABLE fact_sales (
    fact_sales_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    dim_date_id INT NOT NULL,
    dim_customers_id INT NOT NULL,
    dim_products_id INT NOT NULL,
    dim_suppliers_id INT NOT NULL,
    dim_employees_id INT,
    dim_shippers_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (dim_date_id) REFERENCES dim_date (dim_date_id),
    FOREIGN KEY (dim_customers_id) REFERENCES dim_customers (dim_customers_id),
    FOREIGN KEY (dim_products_id) REFERENCES dim_products (dim_products_id),
    FOREIGN KEY (dim_suppliers_id) REFERENCES dim_suppliers (dim_suppliers_id),
    FOREIGN KEY (dim_employees_id) REFERENCES dim_employees (dim_employees_id),
    FOREIGN KEY (dim_shippers_id) REFERENCES dim_shippers (dim_shippers_id)
);
