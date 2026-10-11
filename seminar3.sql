-- Active: 1790058588830@@localhost@5433@superstore
CREATE VIEW high_value_customers AS
SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT *
FROM high_value_customers;

CREATE VIEW regional_monthly_sales AS
SELECT c.region,
       DATE_TRUNC('month', o.order_date)::date AS month,
       SUM(o.sales) AS monthly_sales
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region, DATE_TRUNC('month', o.order_date)
ORDER BY c.region, month;

SELECT *
FROM regional_monthly_sales
WHERE region = 'West';