/*1. Year-wise sales performance
Find the total orders and revenue generated each year.*/

SELECT
    YEAR(o.order_purchase_timestamp) AS sales_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY sales_year;

/*2. Month-wise sales performance
Analyse revenue and order volume for every month.*/

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
ORDER BY sales_year, sales_month;

/*3. Highest revenue-generating month
Identify the month with the highest revenue.*/

SELECT TOP 1
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


/*4. Month-over-month revenue growth
Compare each month's revenue with the previous month's revenue.*/

WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS sales_month,
        SUM(oi.price) AS monthly_revenue
    FROM dbo.olist_orders_dataset o
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),
SalesGrowth AS
(
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM MonthlySales
)
SELECT
    sales_month,
    monthly_revenue,
    previous_month_revenue,
    monthly_revenue - previous_month_revenue AS revenue_difference,
    CAST(
        (monthly_revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0)
        AS DECIMAL(10,2)
    ) AS growth_percentage
FROM SalesGrowth
ORDER BY sales_month;

/*5. Month-over-month order growth
Measure whether the number of orders increased or decreased compared with the previous month.*/

WITH MonthlyOrders AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_purchase_timestamp),
            MONTH(order_purchase_timestamp),
            1
        ) AS sales_month,
        COUNT(DISTINCT order_id) AS total_orders
    FROM dbo.olist_orders_dataset
    GROUP BY
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp)
),
OrderGrowth AS
(
    SELECT
        sales_month,
        total_orders,
        LAG(total_orders) OVER (
            ORDER BY sales_month
        ) AS previous_month_orders
    FROM MonthlyOrders
)
SELECT
    sales_month,
    total_orders,
    previous_month_orders,
    total_orders - previous_month_orders AS order_difference,
    CAST(
        (total_orders - previous_month_orders) * 100.0
        / NULLIF(previous_month_orders, 0)
        AS DECIMAL(10,2)
    ) AS order_growth_percentage
FROM OrderGrowth
ORDER BY sales_month;

/*6. Cumulative revenue over time
Calculate the running total of revenue from the beginning of the dataset.*/
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS sales_month,
        SUM(oi.price) AS monthly_revenue
    FROM dbo.olist_orders_dataset o
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
)
SELECT
    sales_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM MonthlySales
ORDER BY sales_month;

/*7. Three-month moving average revenue
Smooth out short-term fluctuations to identify broader revenue trends.*/

WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS sales_month,
        SUM(oi.price) AS monthly_revenue
    FROM dbo.olist_orders_dataset o
    INNER JOIN dbo.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
)
SELECT
    sales_month,
    monthly_revenue,
    AVG(monthly_revenue) OVER (
        ORDER BY sales_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_moving_average
FROM MonthlySales
ORDER BY sales_month;

























