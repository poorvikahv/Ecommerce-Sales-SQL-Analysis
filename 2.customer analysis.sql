SELECT DB_NAME() AS current_database;

/*   1. Total unique customers
Find the total number of unique customers in the dataset.*/
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers,
    COUNT(customer_id) AS total_customer_records
FROM dbo.olist_customers_dataset;

/*2. Top 10 customers by total spending
Identify customers who have spent the most.*/
SELECT TOP 10
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_spending
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC;


/*3. Customers who placed multiple orders
Find customers who purchased more than once.*/
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;

/*4. Repeat customer percentage
Calculate what percentage of unique customers placed more than one order.*/
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
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        AS repeat_customers,
    CAST(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS repeat_customer_percentage
FROM CustomerOrders;

/*5. Average orders per customer
Calculate the average number of orders placed by each customer.*/
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
    AVG(total_orders * 1.0) AS average_orders_per_customer
FROM CustomerOrders;

/*6. Customer-wise average order value
Calculate the average amount spent per order by each customer.*/
WITH OrderRevenue AS
(
    SELECT
        o.order_id,
        c.customer_unique_id,
        SUM(oi.price) AS order_revenue
    FROM dbo.olist_orders_dataset o
    INNER JOIN dbo.olist_customers_dataset c
        ON o.customer_id = c.customer_id
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        o.order_id,
        c.customer_unique_id
)
SELECT
    customer_unique_id,
    COUNT(*) AS total_orders,
    SUM(order_revenue) AS total_spending,
    AVG(order_revenue) AS average_order_value
FROM OrderRevenue
GROUP BY customer_unique_id
ORDER BY average_order_value DESC;

/*7. Customers who have spent more than the average customer spending
Find customers whose total spending is above the average spending across customers.*/
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

/*8. Customer segmentation based on spending
Divide customers into three groups: High Value, Medium Value and Low Value.*/
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
    total_spending,
    CASE
        WHEN total_spending >= 1000 THEN 'High Value'
        WHEN total_spending >= 300 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM CustomerSpending
ORDER BY total_spending DESC;

/*9. Number of customers in each spending segment
Find how many customers belong to each segment.*/
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
),
CustomerSegments AS
(
    SELECT
        customer_unique_id,
        CASE
            WHEN total_spending >= 1000 THEN 'High Value'
            WHEN total_spending >= 300 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM CustomerSpending
)
SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM CustomerSegments
GROUP BY customer_segment
ORDER BY total_customers DESC;

/*10. Customer distribution by state
Find which states have the highest number of customers.*/
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM dbo.olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;

/*11. Revenue by customer state
Identify states contributing the highest product revenue.*/
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    SUM(oi.price) AS total_revenue
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

/*12. Customers with the highest number of orders
Rank customers by their purchase frequency.*/
SELECT TOP 20
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

/*13. First and last purchase date of each customer
Understand when customers first purchased and when they last purchased.*/
SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase_date,
    MAX(o.order_purchase_timestamp) AS last_purchase_date,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY last_purchase_date DESC;

/*14. Customers who purchased in multiple months
Identify customers who made purchases in more than one calendar month.*/

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT
        CONCAT(
            YEAR(o.order_purchase_timestamp), '-',
            MONTH(o.order_purchase_timestamp)
        )
    ) AS active_months,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT
    CONCAT(
        YEAR(o.order_purchase_timestamp), '-',
        MONTH(o.order_purchase_timestamp)
    )
) > 1
ORDER BY active_months DESC;

/*15. Customer review score analysis
Find the average review score associated with each customer's orders.*/
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS reviewed_orders,
    AVG(r.review_score * 1.0) AS average_review_score
FROM dbo.olist_customers_dataset c
INNER JOIN dbo.olist_orders_dataset o
    ON c.customer_id = o.customer_id
INNER JOIN dbo.olist_order_reviews_dataset r
    ON o.order_id = r.order_id
GROUP BY c.customer_unique_id
ORDER BY average_review_score DESC;


