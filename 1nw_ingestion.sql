CREATE DATABASE northwind_elt;

\c northwind_elt

\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE TABLE IF NOT EXISTS bronze.categories (
    id INT,
    name VARCHAR(25),
    description VARCHAR(255),
    _source_file TEXT DEFAULT 'categories.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.customers (
    id INT,
    name VARCHAR(50),
    contact_name VARCHAR(50),
    address VARCHAR(60),
    city VARCHAR(20),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    _source_file TEXT DEFAULT 'customers.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.employees (
    id INT,
    last_name VARCHAR(15),
    first_name VARCHAR(15),
    birth_date DATE,
    photo VARCHAR(25),
    notes TEXT,
    _source_file TEXT DEFAULT 'employees.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.shippers (
    id INT,
    name VARCHAR(25),
    phone VARCHAR(20),
    _source_file TEXT DEFAULT 'shippers.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.suppliers (
    id INT,
    name VARCHAR(50),
    contact_name VARCHAR(50),
    address VARCHAR(60),
    city VARCHAR(20),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(20),
    _source_file TEXT DEFAULT 'suppliers.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.products (
    id INT,
    name VARCHAR(50),
    supplier_id INT,
    category_id INT,
    unit VARCHAR(25),
    price DECIMAL(10,2),
    _source_file TEXT DEFAULT 'products.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.orders (
    id INT,
    customer_id INT,
    employee_id INT,
    order_date DATE,
    shipper_id INT,
    _source_file TEXT DEFAULT 'orders.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.order_details (
    id INT,
    order_id INT,
    product_id INT,
    quantity INT,
    _source_file TEXT DEFAULT 'orderdetails.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

BEGIN;

TRUNCATE bronze.categories;
\COPY bronze.categories (id, name, description) FROM 'data/categories.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.customers;
\COPY bronze.customers (id, name, contact_name, address, city, postal_code, country) FROM 'data/customers.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.employees;
\COPY bronze.employees (id, last_name, first_name, birth_date, photo, notes) FROM 'data/employees.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.shippers;
\COPY bronze.shippers (id, name, phone) FROM 'data/shippers.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.suppliers;
\COPY bronze.suppliers (id, name, contact_name, address, city, postal_code, country, phone) FROM 'data/suppliers.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.products;
\COPY bronze.products (id, name, supplier_id, category_id, unit, price) FROM 'data/products.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.orders;
\COPY bronze.orders (id, customer_id, employee_id, order_date, shipper_id) FROM 'data/orders.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.order_details;
\COPY bronze.order_details (id, order_id, product_id, quantity) FROM 'data/orderdetails.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

COMMIT;
