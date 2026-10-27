CREATE DATABASE movielens_dwh;

CREATE TABLE dim_users (
    dim_users_id INT PRIMARY KEY,
    age_group VARCHAR(45),
    gender CHAR(1),
    zip_code VARCHAR(255),
    occupation VARCHAR(255)
);

CREATE TABLE dim_movies (
    dim_movies_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_year INT
);

CREATE TABLE dim_genres (
    dim_genres_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE bridge_movies_genres (
    dim_movies_id INT NOT NULL,
    dim_genres_id INT NOT NULL,
    PRIMARY KEY (dim_movies_id, dim_genres_id),
    FOREIGN KEY (dim_movies_id) REFERENCES dim_movies (dim_movies_id),
    FOREIGN KEY (dim_genres_id) REFERENCES dim_genres (dim_genres_id)
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

CREATE TABLE dim_time (
    dim_time_id INT PRIMARY KEY,
    full_time TIME NOT NULL UNIQUE,
    hour INT NOT NULL,
    minute INT NOT NULL,
    am_pm CHAR(2) NOT NULL
);

CREATE TABLE dim_tags (
    dim_tags_id INT PRIMARY KEY,
    tags VARCHAR(4000),
    created_at TIMESTAMP
);

CREATE TABLE fact_ratings (
    fact_ratings_id INT PRIMARY KEY,
    dim_users_id INT NOT NULL,
    dim_movies_id INT NOT NULL,
    dim_date_id INT NOT NULL,
    dim_time_id INT NOT NULL,
    dim_tags_id INT,
    rating INT NOT NULL,
    FOREIGN KEY (dim_users_id) REFERENCES dim_users (dim_users_id),
    FOREIGN KEY (dim_movies_id) REFERENCES dim_movies (dim_movies_id),
    FOREIGN KEY (dim_date_id) REFERENCES dim_date (dim_date_id),
    FOREIGN KEY (dim_time_id) REFERENCES dim_time (dim_time_id),
    FOREIGN KEY (dim_tags_id) REFERENCES dim_tags (dim_tags_id)
);
