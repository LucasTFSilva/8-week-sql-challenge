-- 0. Criando view
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
--1. Qual foi o total gasto por cada cliente no restaurante?
SELECT customer_id,
    SUM(price) AS total_gasto
FROM vendas_completas
GROUP BY customer_id;
-- 2. Quantos dias cada cliente visitou o restaurante?
SELECT customer_id,
    COUNT(DISTINCT order_date) AS visitas
FROM sales
GROUP BY customer_id;
-- 3. Qual foi o primeiro item do menu comprado por cada cliente?
SELECT customer_id,
    product_name,
    MIN(order_date) AS data_pedido
FROM vendas_completas
GROUP BY customer_id;
-- 4. Qual é o item mais comprado do menu e quantas vezes ele foi comprado?
SELECT product_name,
    COUNT(*) AS vendas
FROM vendas_completas
GROUP BY product_name
ORDER BY vendas DESC
LIMIT 1;
-- 5. Which item was the most popular for each customer?
WITH rankFood AS (
    SELECT customer_id,
        product_name,
        COUNT(*) AS orders,
        RANK() OVER(
            PARTITION BY customer_id
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM vendas_completas
    GROUP BY customer_id,
        product_name
    ORDER BY customer_id
)
SELECT customer_id,
    product_name,
    orders
FROM rankFood
WHERE rnk = 1;
-- 6. Qual o primeiro item comprado pelos clientes logo após se tornarem membros?
SELECT customer_id,
    product_name,
    MIN(order_date) AS min_order_date
FROM vendas_completas
WHERE order_date >= join_date
GROUP BY customer_id;
-- 7. Qual item foi completo logo antes do cliiente se tornar membro? 
SELECT customer_id,
    product_name,
    MAX(order_date) AS max_order_date
FROM vendas_completas
WHERE order_date < join_date
GROUP BY customer_id;
-- 8. Quantas compras e quanto foi gasto por cada cliente antes de se tornarem membros?
SELECT customer_id,
    COUNT(*) AS compras,
    SUM(price) AS gasto_total
FROM vendas_completas
WHERE order_date < join_date
GROUP BY customer_id;
-- 9. Se cada R$1 gasto equivale a 10 pontos e o sushi tem um multiplicador de 2x, quantos pontos cada cliente terá?
WITH points AS(
    SELECT customer_id,
        product_name,
        price,
        CASE
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
        END AS points
    FROM vendas_completas
)
SELECT customer_id,
    SUM(points) AS points
FROM points
GROUP BY customer_id;
-- 10. Na primeira semana após o cliente se tornar assinante ele ganhou um multiplicador de 2x para todos os itens, não apenas sushi. Quantos pontos os clientes A e B tiveram ao fim de janeiro?
WITH points AS(
    SELECT customer_id,
        product_name,
        price,
        order_date,
        join_date,
        CASE
            WHEN order_date BETWEEN join_date AND DATE(join_date, "+7 days") THEN price * 20
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
        END AS points
    FROM vendas_completas
)
SELECT customer_id,
    SUM(points) AS member_points
FROM points
WHERE order_date < '2021-02-01'
GROUP BY customer_id