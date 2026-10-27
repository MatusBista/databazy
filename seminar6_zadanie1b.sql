CREATE DATABASE chinook_dwh;

CREATE TABLE dim_customers (
    dim_customers_id INT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    company VARCHAR(80),
    email VARCHAR(60) NOT NULL
);

CREATE TABLE dim_employees (
    dim_employees_id INT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    title VARCHAR(30),
    hire_date DATE,
    city VARCHAR(40),
    country VARCHAR(40),
    manager_name VARCHAR(41)
);

CREATE TABLE dim_tracks (
    dim_tracks_id INT PRIMARY KEY,
    track_name VARCHAR(200) NOT NULL,
    composer VARCHAR(220),
    milliseconds INT NOT NULL,
    bytes INT,
    album_title VARCHAR(160) NOT NULL,
    artist_name VARCHAR(120),
    genre_name VARCHAR(120),
    media_type_name VARCHAR(120)
);

CREATE TABLE dim_playlists (
    dim_playlists_id INT PRIMARY KEY,
    name VARCHAR(120)
);

CREATE TABLE bridge_playlists_tracks (
    dim_playlists_id INT NOT NULL,
    dim_tracks_id INT NOT NULL,
    PRIMARY KEY (dim_playlists_id, dim_tracks_id),
    FOREIGN KEY (dim_playlists_id) REFERENCES dim_playlists (dim_playlists_id),
    FOREIGN KEY (dim_tracks_id) REFERENCES dim_tracks (dim_tracks_id)
);

CREATE TABLE dim_location (
    dim_location_id INT PRIMARY KEY,
    city VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    postal_code VARCHAR(10)
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
    invoice_id INT NOT NULL,
    dim_date_id INT NOT NULL,
    dim_customers_id INT NOT NULL,
    dim_employees_id INT,
    dim_tracks_id INT NOT NULL,
    dim_location_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (dim_date_id) REFERENCES dim_date (dim_date_id),
    FOREIGN KEY (dim_customers_id) REFERENCES dim_customers (dim_customers_id),
    FOREIGN KEY (dim_employees_id) REFERENCES dim_employees (dim_employees_id),
    FOREIGN KEY (dim_tracks_id) REFERENCES dim_tracks (dim_tracks_id),
    FOREIGN KEY (dim_location_id) REFERENCES dim_location (dim_location_id)
);
