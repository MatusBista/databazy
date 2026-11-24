\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE VIEW silver.ratings AS
SELECT CAST(id AS INT) AS rating_id,
       CAST(user_id AS INT) AS user_id,
       CAST(movie_id AS INT) AS movie_id,
       CAST(rating AS INT) AS rating,
       CAST(rated_at AS TIMESTAMP) AS rated_at
FROM bronze.ratings;

CREATE OR REPLACE VIEW silver.users AS
SELECT CAST(id AS INT) AS user_id,
       CAST(age AS INT) AS age_group_id,
       CAST(TRIM(gender) AS CHAR(1)) AS gender,
       CAST(occupation_id AS INT) AS occupation_id,
       TRIM(zip_code) AS zip_code
FROM bronze.users;

CREATE OR REPLACE VIEW silver.movies AS
SELECT CAST(id AS INT) AS movie_id,
       TRIM(title) AS title,
       CAST(release_year AS INT) AS release_year
FROM bronze.movies;

CREATE OR REPLACE VIEW silver.occupations AS
SELECT CAST(id AS INT) AS occupation_id,
       TRIM(name) AS occupation_name
FROM bronze.occupations;

CREATE OR REPLACE VIEW silver.age_group AS
SELECT CAST(id AS INT) AS age_group_id,
       TRIM(name) AS age_group_name
FROM bronze.age_group;

CREATE OR REPLACE VIEW silver.genres AS
SELECT CAST(id AS INT) AS genre_id,
       TRIM(name) AS genre_name
FROM bronze.genres;

CREATE OR REPLACE VIEW silver.genres_movies AS
SELECT CAST(id AS INT) AS genre_movie_id,
       CAST(movie_id AS INT) AS movie_id,
       CAST(genre_id AS INT) AS genre_id
FROM bronze.genres_movies;
