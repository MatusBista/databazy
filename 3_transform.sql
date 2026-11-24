\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_time (
    time_id INT PRIMARY KEY,
    full_time TIME NOT NULL UNIQUE,
    hour INT NOT NULL,
    minute INT NOT NULL,
    second INT NOT NULL,
    am_pm CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_id INT PRIMARY KEY,
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

CREATE TABLE IF NOT EXISTS gold.dim_user (
    user_id INT PRIMARY KEY,
    gender CHAR(1) NOT NULL,
    age_group VARCHAR(20) NOT NULL,
    occupation VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS gold.dim_movie (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_year INT,
    genres VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS gold.fact_rating (
    rating_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES gold.dim_user (user_id),
    movie_id INT NOT NULL REFERENCES gold.dim_movie (movie_id),
    date_id INT NOT NULL REFERENCES gold.dim_date (date_id),
    time_id INT NOT NULL REFERENCES gold.dim_time (time_id),
    rating INT NOT NULL
);

CREATE INDEX IF NOT EXISTS fact_rating_user_id_idx ON gold.fact_rating (user_id);
CREATE INDEX IF NOT EXISTS fact_rating_movie_id_idx ON gold.fact_rating (movie_id);
CREATE INDEX IF NOT EXISTS fact_rating_date_id_idx ON gold.fact_rating (date_id);
CREATE INDEX IF NOT EXISTS fact_rating_time_id_idx ON gold.fact_rating (time_id);

BEGIN;

TRUNCATE gold.fact_rating, gold.dim_user, gold.dim_movie, gold.dim_date, gold.dim_time;

INSERT INTO gold.dim_time (time_id, full_time, hour, minute, second, am_pm)
SELECT TO_CHAR(t, 'HH24MISS')::INT,
       t,
       EXTRACT(HOUR FROM t),
       EXTRACT(MINUTE FROM t),
       EXTRACT(SECOND FROM t),
       TO_CHAR(t, 'AM')
FROM (
    SELECT generate_series(TIMESTAMP '2000-01-01 00:00:00', TIMESTAMP '2000-01-01 23:59:59', INTERVAL '1 second')::TIME AS t
) AS times;

INSERT INTO gold.dim_date (date_id, full_date, day, day_of_week, day_of_week_name, week, month, month_name, quarter, year)
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
    SELECT generate_series(MIN(rated_at)::DATE, MAX(rated_at)::DATE, INTERVAL '1 day')::DATE AS d
    FROM silver.ratings
) AS dates;

INSERT INTO gold.dim_user (user_id, gender, age_group, occupation, zip_code)
SELECT u.user_id, u.gender, a.age_group_name, o.occupation_name, u.zip_code
FROM silver.users u
JOIN silver.age_group a ON a.age_group_id = u.age_group_id
JOIN silver.occupations o ON o.occupation_id = u.occupation_id;

INSERT INTO gold.dim_movie (movie_id, title, release_year, genres)
SELECT m.movie_id,
       m.title,
       m.release_year,
       STRING_AGG(g.genre_name, ', ' ORDER BY g.genre_name)
FROM silver.movies m
LEFT JOIN silver.genres_movies gm ON gm.movie_id = m.movie_id
LEFT JOIN silver.genres g ON g.genre_id = gm.genre_id
GROUP BY m.movie_id, m.title, m.release_year;

INSERT INTO gold.fact_rating (rating_id, user_id, movie_id, date_id, time_id, rating)
SELECT r.rating_id,
       r.user_id,
       r.movie_id,
       d.date_id,
       t.time_id,
       r.rating
FROM silver.ratings r
JOIN gold.dim_date d ON d.full_date = r.rated_at::DATE
JOIN gold.dim_time t ON t.full_time = r.rated_at::TIME;

COMMIT;
