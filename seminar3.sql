-- Active: 1790058588830@@localhost@5433@superstore
CREATE VIEW high_value_customers AS
SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT *
FROM high_value_customers;