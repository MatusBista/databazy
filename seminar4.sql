-- Active: 1790058588830@@localhost@5433@superstore
CREATE DATABASE retail;

ALTER DATABASE retail SET datestyle = 'ISO, DMY';

CREATE TABLE retail_sales (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(10,2),
    customer_id INTEGER,
    country VARCHAR(100)
);

SELECT *
FROM retail_sales;

SELECT COUNT(*), MIN(invoice_date), MAX(invoice_date)
FROM retail_sales;

SELECT customer_id,
       invoice_no,
       invoice_date,
       quantity,
       unit_price,
       quantity * unit_price AS revenue,
       SUM(quantity * unit_price) OVER (
           PARTITION BY customer_id
           ORDER BY invoice_date
           RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
       ) AS revenue_last_14_days
FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY customer_id, invoice_date;

SELECT stock_code,
       country,
       invoice_date,
       quantity,
       ROUND(AVG(quantity) OVER (
           PARTITION BY stock_code, country
           ORDER BY invoice_date
           RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
       ), 2) AS avg_quantity_7_days
FROM retail_sales
WHERE quantity > 1
ORDER BY stock_code, country, invoice_date;

WITH orders AS (
    SELECT DISTINCT customer_id,
           invoice_no,
           invoice_date::DATE AS invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
),
next_orders AS (
    SELECT customer_id,
           invoice_no,
           invoice_date,
           LEAD(invoice_date) OVER (
               PARTITION BY customer_id
               ORDER BY invoice_date
           ) AS next_invoice_date
    FROM orders
)
SELECT customer_id,
       invoice_no,
       invoice_date,
       next_invoice_date,
       next_invoice_date - invoice_date AS days_to_next_invoice
FROM next_orders
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

WITH prices AS (
    SELECT stock_code,
           invoice_no,
           invoice_date,
           LAG(unit_price) OVER (
               PARTITION BY stock_code
               ORDER BY invoice_date
           ) AS previous_price,
           unit_price AS current_price
    FROM retail_sales
)
SELECT stock_code,
       invoice_no,
       invoice_date,
       previous_price,
       current_price,
       current_price - previous_price AS price_difference
FROM prices
WHERE previous_price IS NOT NULL
  AND current_price <> previous_price
ORDER BY invoice_date;

WITH customer_sales AS (
    SELECT customer_id,
           SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT customer_id,
       total_amount,
       NTILE(4) OVER (ORDER BY total_amount DESC) AS sales_quartile
FROM customer_sales
ORDER BY total_amount DESC;

WITH monthly_sales AS (
    SELECT country,
           DATE_TRUNC('month', invoice_date)::DATE AS month,
           SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    GROUP BY country, DATE_TRUNC('month', invoice_date)
)
SELECT country,
       month,
       total_amount,
       NTILE(4) OVER (
           PARTITION BY country
           ORDER BY total_amount DESC
       ) AS sales_quartile
FROM monthly_sales
ORDER BY country, month;

WITH numbered AS (
    SELECT customer_id,
           invoice_no,
           invoice_date,
           stock_code,
           description,
           quantity,
           unit_price,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY invoice_date
           ) AS rn
    FROM retail_sales
    WHERE customer_id IS NOT NULL
)
SELECT customer_id,
       invoice_no,
       invoice_date,
       stock_code,
       description,
       quantity,
       unit_price
FROM numbered
WHERE rn = 1
ORDER BY customer_id;

WITH ranked AS (
    SELECT invoice_no,
           stock_code,
           description,
           quantity,
           unit_price,
           quantity * unit_price AS amount,
           ROW_NUMBER() OVER (
               PARTITION BY invoice_no
               ORDER BY quantity * unit_price DESC
           ) AS row_num
    FROM retail_sales
)
SELECT invoice_no,
       stock_code,
       description,
       quantity,
       unit_price,
       amount,
       row_num
FROM ranked
WHERE row_num <= 3
ORDER BY invoice_no, row_num;

WITH customer_monthly_sales AS (
    SELECT country,
           DATE_TRUNC('month', invoice_date)::DATE AS month,
           customer_id,
           SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY country, DATE_TRUNC('month', invoice_date), customer_id
),
ranked AS (
    SELECT country,
           month,
           customer_id,
           total_amount,
           DENSE_RANK() OVER (
               PARTITION BY country, month
               ORDER BY total_amount DESC
           ) AS sales_rank
    FROM customer_monthly_sales
)
SELECT country,
       month,
       customer_id,
       total_amount,
       sales_rank
FROM ranked
WHERE sales_rank <= 5
ORDER BY country, month, sales_rank, customer_id;

WITH ranked AS (
    SELECT invoice_no,
           stock_code,
           description,
           quantity,
           unit_price,
           DENSE_RANK() OVER (
               PARTITION BY invoice_no
               ORDER BY unit_price DESC
           ) AS price_rank
    FROM retail_sales
)
SELECT invoice_no,
       stock_code,
       description,
       quantity,
       unit_price,
       price_rank
FROM ranked
WHERE price_rank <= 5
ORDER BY invoice_no, price_rank, stock_code;

WITH numbered AS (
    SELECT c.customer_name,
           o.order_id,
           o.order_date,
           ROW_NUMBER() OVER (
               PARTITION BY o.customer_id
               ORDER BY o.order_date DESC
           ) AS order_rank
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
)
SELECT customer_name,
       order_id,
       order_date
FROM numbered
WHERE order_rank <= 2
ORDER BY customer_name, order_rank;

WITH customer_profit AS (
    SELECT c.region,
           c.customer_name,
           SUM(o.profit) AS total_profit
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.region, c.customer_id, c.customer_name
)
SELECT region,
       customer_name,
       total_profit,
       RANK() OVER (
           PARTITION BY region
           ORDER BY total_profit DESC
       ) AS profit_rank,
       DENSE_RANK() OVER (
           PARTITION BY region
           ORDER BY total_profit DESC
       ) AS profit_dense_rank
FROM customer_profit
ORDER BY region, total_profit DESC;

WITH customer_sales AS (
    SELECT c.customer_name,
           SUM(o.sales) AS total_sales
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name,
       total_sales,
       NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
FROM customer_sales
ORDER BY total_sales DESC;

WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::DATE AS month,
           SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month,
       monthly_sales,
       LAG(monthly_sales, 1) OVER (ORDER BY month) AS prev_month_sales,
       LEAD(monthly_sales, 1) OVER (ORDER BY month) AS next_month_sales
FROM monthly
ORDER BY month;

WITH product_totals AS (
    SELECT p.category,
           p.product_name,
           SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT category,
       product_name,
       product_sales,
       SUM(product_sales) OVER (PARTITION BY category) AS category_total,
       ROUND(
           product_sales * 100.0 / SUM(product_sales) OVER (PARTITION BY category),
           2
       ) AS pct_of_category
FROM product_totals;

WITH order_dates AS (
    SELECT o.customer_id,
           c.customer_name,
           MAX(o.order_date) OVER (PARTITION BY o.customer_id) AS last_order_date,
           MAX(o.order_date) OVER () AS latest_order_date
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
)
SELECT DISTINCT customer_id,
       customer_name,
       last_order_date
FROM order_dates
WHERE last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY last_order_date;

WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::DATE AS month,
           SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
with_prev AS (
    SELECT month,
           monthly_sales,
           LAG(monthly_sales) OVER (ORDER BY month) AS prev_month_sales
    FROM monthly
)
SELECT month,
       monthly_sales,
       prev_month_sales,
       monthly_sales - prev_month_sales AS sales_change,
       ROUND((monthly_sales - prev_month_sales) / prev_month_sales * 100, 2) AS growth_percentage
FROM with_prev
ORDER BY month;

WITH first_purchase AS (
    SELECT customer_id,
           DATE_TRUNC('month', MIN(order_date))::DATE AS first_month
    FROM orders
    GROUP BY customer_id
)
SELECT COUNT(*) AS returning_customers
FROM first_purchase f
WHERE f.first_month = DATE '2024-06-01'
  AND EXISTS (
      SELECT 1
      FROM orders o
      WHERE o.customer_id = f.customer_id
        AND DATE_TRUNC('month', o.order_date) > f.first_month
  );
