CREATE DATABASE pagila_snowflake;

CREATE TABLE dim_countries (
    dim_countries_id INT PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dim_cities (
    dim_cities_id INT PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL,
    dim_countries_id INT NOT NULL,
    FOREIGN KEY (dim_countries_id) REFERENCES dim_countries (dim_countries_id)
);

CREATE TABLE dim_addresses (
    dim_addresses_id INT PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(50),
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    dim_cities_id INT NOT NULL,
    FOREIGN KEY (dim_cities_id) REFERENCES dim_cities (dim_cities_id)
);

CREATE TABLE dim_customers (
    dim_customers_id INT PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    active BOOLEAN,
    created_at DATE,
    dim_addresses_id INT NOT NULL,
    FOREIGN KEY (dim_addresses_id) REFERENCES dim_addresses (dim_addresses_id)
);

CREATE TABLE dim_stores (
    dim_stores_id INT PRIMARY KEY,
    dim_addresses_id INT NOT NULL,
    FOREIGN KEY (dim_addresses_id) REFERENCES dim_addresses (dim_addresses_id)
);

CREATE TABLE dim_staff (
    dim_staff_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(50),
    active BOOLEAN,
    dim_addresses_id INT NOT NULL,
    FOREIGN KEY (dim_addresses_id) REFERENCES dim_addresses (dim_addresses_id)
);

CREATE TABLE dim_languages (
    dim_languages_id INT PRIMARY KEY,
    language_name VARCHAR(20) NOT NULL
);

CREATE TABLE dim_films (
    dim_films_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year SMALLINT,
    rental_duration SMALLINT,
    rental_rate DECIMAL(4,2),
    length SMALLINT,
    replacement_cost DECIMAL(5,2),
    rating DOUBLE PRECISION,
    special_features TEXT,
    dim_languages_id INT NOT NULL,
    FOREIGN KEY (dim_languages_id) REFERENCES dim_languages (dim_languages_id)
);

CREATE TABLE dim_categories (
    dim_categories_id INT PRIMARY KEY,
    category_name VARCHAR(25) NOT NULL
);

CREATE TABLE bridge_films_categories (
    dim_films_id INT NOT NULL,
    dim_categories_id INT NOT NULL,
    PRIMARY KEY (dim_films_id, dim_categories_id),
    FOREIGN KEY (dim_films_id) REFERENCES dim_films (dim_films_id),
    FOREIGN KEY (dim_categories_id) REFERENCES dim_categories (dim_categories_id)
);

CREATE TABLE dim_actors (
    dim_actors_id INT PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL
);

CREATE TABLE bridge_films_actors (
    dim_films_id INT NOT NULL,
    dim_actors_id INT NOT NULL,
    PRIMARY KEY (dim_films_id, dim_actors_id),
    FOREIGN KEY (dim_films_id) REFERENCES dim_films (dim_films_id),
    FOREIGN KEY (dim_actors_id) REFERENCES dim_actors (dim_actors_id)
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

CREATE TABLE fact_rentals (
    fact_rentals_id INT PRIMARY KEY,
    rental_id INT NOT NULL,
    dim_date_id INT NOT NULL,
    dim_customers_id INT NOT NULL,
    dim_films_id INT NOT NULL,
    dim_staff_id INT NOT NULL,
    dim_stores_id INT NOT NULL,
    rental_rate DECIMAL(4,2) NOT NULL,
    rental_days INT,
    FOREIGN KEY (dim_date_id) REFERENCES dim_date (dim_date_id),
    FOREIGN KEY (dim_customers_id) REFERENCES dim_customers (dim_customers_id),
    FOREIGN KEY (dim_films_id) REFERENCES dim_films (dim_films_id),
    FOREIGN KEY (dim_staff_id) REFERENCES dim_staff (dim_staff_id),
    FOREIGN KEY (dim_stores_id) REFERENCES dim_stores (dim_stores_id)
);
