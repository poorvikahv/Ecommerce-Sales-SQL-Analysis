/*1. Total orders, customers and order status*/

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN order_status = 'shipped' THEN 1 ELSE 0 END) AS shipped_orders,
    SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) AS unavailable_orders
FROM dbo.olist_orders_dataset;


/*2. Total revenue
We'll calculate revenue using product prices from the order items table. For now, we'll count only delivered orders.*/

SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(oi.price) AS total_revenue,
    SUM(oi.freight_value) AS total_freight
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


/* 3. Average Order Value (AOV)
AOV is the average product revenue earned per delivered order.*/

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    CAST(
        SUM(oi.price) / COUNT(DISTINCT o.order_id)
        AS DECIMAL(12,2)
    ) AS average_order_value
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

/*4. Monthly revenue analysis
This helps identify which months generated the highest revenue. */

SELECT
    YEAR(o.order_purchase_timestamp) AS sales_year,
    MONTH(o.order_purchase_timestamp) AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS monthly_revenue
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    sales_year,
    sales_month;

    /* 5. Order status distribution
Understand how many orders fall into each status.*/

SELECT
    order_status,
    COUNT(*) AS total_orders,
    CAST(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM dbo.olist_orders_dataset)
        AS DECIMAL(5,2)
    ) AS percentage
FROM dbo.olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

/*6. Payment method analysis
Find the most commonly used payment methods. */

/*SELECT
    payment_type,
    COUNT(*) AS payment_records,
    SUM(payment_value) AS total_payment_value,
    AVG(payment_value) AS average_payment_value
FROM dbo.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_payment_value DESC;*/

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    SUM(CAST(payment_value AS DECIMAL(18,2))) AS total_payment_value,
    AVG(CAST(payment_value AS DECIMAL(18,2))) AS average_payment_value
FROM dbo.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_payment_value DESC;

/*  Delivery performance
Compare actual delivery dates with estimated delivery dates.*/

SELECT
    COUNT(*) AS delivered_orders,
    SUM(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS on_time_deliveries,
    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS late_deliveries
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


  /* 8. Average delivery time*/

  SELECT
    AVG(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

  /* 9. Top 10 highest-revenue months*/

  SELECT TOP 10
    YEAR(o.order_purchase_timestamp) AS sales_year,
    MONTH(o.order_purchase_timestamp) AS sales_month,
    SUM(oi.price) AS monthly_revenue
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY monthly_revenue DESC;

/* 10. Revenue by customer state*/
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_customers_dataset c
    ON o.customer_id = c.customer_id
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;