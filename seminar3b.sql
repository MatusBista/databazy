-- Active: 1790058588830@@localhost@5433@datacraftinglab_db
WITH daily_sales AS (
    SELECT sale_date,
           SUM(total_amount) AS total_daily_sales
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT sale_date, total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;