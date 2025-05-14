DROP VIEW IF EXISTS vendas_completas;
CREATE VIEW vendas_completas AS
SELECT s.customer_id,
    s.order_date,
    s.product_id,
    m.product_name,
    m.price,
    mm.join_date
FROM sales AS s
    LEFT JOIN menu AS m ON s.product_id = m.product_id
    LEFT JOIN members AS mm ON s.customer_id = mm.customer_id;
--1. What is the total amount each customer spent at the restaurant?
SELECT *
FROM vendas_completas -- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
    COUNT(DISTINCT order_date)
FROM sales
GROUP BY customer_id;
-- 3. What was the first item from the menu purchased by each customer?
TESTE