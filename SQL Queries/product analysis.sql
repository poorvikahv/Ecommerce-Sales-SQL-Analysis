/*1. Total number of products*/
SELECT
    COUNT(DISTINCT product_id) AS total_products
FROM dbo.olist_products_dataset;

/*2. Top 10 best-selling products*/

SELECT TOP 10
    p.product_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.order_item_id * 0 + 1) AS total_items_sold,
    SUM(oi.price) AS total_revenue
FROM dbo.olist_products_dataset p
INNER JOIN dbo.olist_order_items_dataset oi
    ON p.product_id = oi.product_id
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_id
ORDER BY total_items_sold DESC;


/*3. Top 10 products by revenue*/
SELECT TOP 10
    p.product_id,
    SUM(oi.price) AS total_revenue,
    COUNT(*) AS total_items_sold
FROM dbo.olist_products_dataset p
INNER JOIN dbo.olist_order_items_dataset oi
    ON p.product_id = oi.product_id
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_id
ORDER BY total_revenue DESC;


/*4. Product category-wise revenue*/
SELECT
    COALESCE(t.product_category_name_english,
             p.product_category_name) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    SUM(oi.price) AS total_revenue
FROM dbo.olist_products_dataset p
INNER JOIN dbo.olist_order_items_dataset oi
    ON p.product_id = oi.product_id
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    COALESCE(t.product_category_name_english,
             p.product_category_name)
ORDER BY total_revenue DESC;

/*5. Top 10 best-selling product categories*/
SELECT TOP 10
    COALESCE(t.product_category_name_english,
             p.product_category_name) AS product_category,
    COUNT(*) AS total_items_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM dbo.products p
INNER JOIN dbo.order_items oi
    ON p.product_id = oi.product_id
INNER JOIN dbo.orders o
    ON oi.order_id = o.order_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    COALESCE(t.product_category_name_english,
             p.product_category_name)
ORDER BY total_items_sold DESC;


/*5. Top 10 best-selling product categories*/
SELECT TOP 10
    COALESCE(t.product_category_name_english,
             p.product_category_name) AS product_category,
    COUNT(*) AS total_items_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM dbo.olist_products_dataset p
INNER JOIN dbo.olist_order_items_dataset oi
    ON p.product_id = oi.product_id
INNER JOIN dbo.olist_orders_dataset o
    ON oi.order_id = o.order_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    COALESCE(t.product_category_name_english,
             p.product_category_name)
ORDER BY total_items_sold DESC;



/*6. Average product price by category*/

SELECT
    COALESCE(t.product_category_name_english,
             p.product_category_name) AS product_category,
    AVG(oi.price) AS average_product_price,
    MIN(oi.price) AS minimum_price,
    MAX(oi.price) AS maximum_price
FROM dbo.olist_products_dataset p
INNER JOIN dbo.olist_order_items_dataset oi
    ON p.product_id = oi.product_id
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(t.product_category_name_english,
             p.product_category_name)
ORDER BY average_product_price DESC;


/*7. Products with the highest average selling price*/
SELECT TOP 20
    p.product_id,
    AVG(oi.price) AS average_selling_price,
    COUNT(*) AS total_items_sold
FROM dbo.olist_products_dataset p
INNER JOIN dbo.olist_order_items_dataset oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY average_selling_price DESC;


