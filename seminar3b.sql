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

WITH category_sales AS (
    SELECT product_category,
           SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT product_category, total_sales
FROM category_sales
ORDER BY total_sales DESC;

WITH product_sales AS (
    SELECT product_category,
           product_name,
           SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT product_category,
           product_name,
           total_product_sales,
           RANK() OVER (PARTITION BY product_category ORDER BY total_product_sales DESC) AS category_rank
    FROM product_sales
)
SELECT product_category, product_name, total_product_sales, category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY product_category, category_rank;