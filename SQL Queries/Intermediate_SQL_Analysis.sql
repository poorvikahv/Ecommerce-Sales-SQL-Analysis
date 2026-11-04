/*1. Find the second-highest revenue-generating product
Practise DENSE_RANK().*/

WITH ProductRevenue AS
(
    SELECT
        oi.product_id,
        SUM(oi.price) AS total_revenue
    FROM dbo.olist_order_items_dataset oi
    INNER JOIN dbo.olist_orders_dataset o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.product_id
),
ProductRanking AS
(
    SELECT
        product_id,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM ProductRevenue
)
SELECT
    product_id,
    total_revenue,
    revenue_rank
FROM ProductRanking
WHERE revenue_rank = 2;

/*2. Rank the top 10 customers by spending*/
WITH CustomerRevenue AS
(
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_spending
    FROM dbo.olist_customers_dataset c
    INNER JOIN dbo.olist_orders_dataset o
        ON c.customer_id = o.customer_id
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT TOP 10
    customer_unique_id,
    total_spending,
    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS customer_rank
FROM CustomerRevenue
ORDER BY total_spending DESC;

/*3. Identify repeat customers
Find customers who placed more than one order.*/
WITH CustomerOrders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM dbo.olist_customers_dataset c
    INNER JOIN dbo.olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,
    CASE
        WHEN total_orders > 1 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type
FROM CustomerOrders
ORDER BY total_orders DESC;


/*4. Calculate average spending per customer
First calculate each customer's total spending, then calculate the average across customers.*/

WITH CustomerSpending AS
(
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_spending
    FROM dbo.olist_customers_dataset c
    INNER JOIN dbo.olist_orders_dataset o
        ON c.customer_id = o.customer_id
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    AVG(total_spending) AS average_customer_spending,
    MAX(total_spending) AS highest_customer_spending,
    MIN(total_spending) AS lowest_customer_spending
FROM CustomerSpending;


/*5. Find customers spending above average*/
WITH CustomerSpending AS
(
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_spending
    FROM dbo.olist_customers_dataset c
    INNER JOIN dbo.olist_orders_dataset o
        ON c.customer_id = o.customer_id
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    total_spending
FROM CustomerSpending
WHERE total_spending >
(
    SELECT AVG(total_spending)
    FROM CustomerSpending
)
ORDER BY total_spending DESC;

/*6. Rank sellers based on revenue*/
WITH SellerRevenue AS
(
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS total_revenue
    FROM dbo.olist_order_items_dataset oi
    INNER JOIN dbo.olist_orders_dataset o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT
    seller_id,
    total_orders,
    total_revenue,
    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS seller_rank
FROM SellerRevenue
ORDER BY seller_rank;

/*7. Find sellers with more than 50 orders*/
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue
FROM dbo.olist_order_items_dataset oi
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT oi.order_id) > 50
ORDER BY total_orders DESC;

















































