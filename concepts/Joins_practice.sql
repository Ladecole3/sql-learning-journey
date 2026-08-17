-- Total value of each order
-- One row in my final result = one order
SELECT 
	o.order_id,
	o.customer_id,
	o.order_date,
	SUM(od.quantity) AS total_quantity,
	SUM(od.quantity * od.unit_price) AS order_value
	
FROM orders o
INNER JOIN order_details od
	ON o.order_id = od.order_id
GROUP BY 
	o.order_id,
	o.customer_id,
	o.order_date
ODER BY order_value DESC
;


-- Total Value of ALL orders per customer
-- One row in my final result = one customer
SELECT 
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(od.quantity) AS total_items_purchased,
    SUM(od.quantity * od.unit_price) AS total_order_value    
FROM orders o
INNER JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY o.customer_id
ORDER BY total_order_value DESC;


-- High value orders > $1000
-- One row in my final result = one order
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(od.quantity * od.unit_price) AS order_value    
FROM orders o
INNER JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY 
    o.order_id,
    o.customer_id,
    o.order_date
HAVING SUM(od.quantity * od.unit_price) > 1000
ORDER BY order_value DESC;


-- Late Shipement
-- One row in my final result = one order
SELECT 
    o.order_id, 
    o.customer_id, 
    o.order_date, 
    o.required_date, 
    o.shipped_date, 
    SUM(od.quantity) AS total_quantity,
	(o.shipped_date - o.required_date) AS no_days_late
FROM orders o 
INNER JOIN order_details od 
    ON o.order_id = od.order_id 
WHERE o.shipped_date > o.required_date 
GROUP BY 
    o.order_id, 
    o.customer_id, 
    o.order_date, 
    o.required_date, 
    o.shipped_date
ORDER BY (o.shipped_date - o.required_date) DESC;


-- Orders with no details
-- One row in my final result = one order
SELECT 
    o.order_id, 
    o.customer_id, 
    o.order_date
FROM orders o 
LEFT JOIN order_details od 
    ON o.order_id = od.order_id 
WHERE od.order_id IS NULL;

--Missing Product Information
-- -- One row in my final result = one order
SELECT 
    od.order_id, 
    od.product_id, 
    od.quantity
FROM order_details od 
LEFT JOIN orders o 
    ON od.order_id = o.order_id 
WHERE o.order_id IS NULL;

-- Order Coverage
-- Final result = one summary row
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT CASE
        WHEN od.order_id IS NOT NULL
        THEN o.order_id
    END) AS orders_with_details,

    COUNT(DISTINCT CASE
        WHEN od.order_id IS NULL
        THEN o.order_id
    END) AS orders_without_details

FROM orders o
LEFT JOIN order_details od
    ON o.order_id = od.order_id;


-- Top 10 orders with the most products
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(od.quantity) AS total_quantity    
FROM orders o
INNER JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY 
    o.order_id,
    o.customer_id,
    o.order_date
ORDER BY total_quantity DESC
LIMIT 10;


-- Orders where freight is more than 10% of total order value
SELECT 
    o.order_id,
    o.freight,
    SUM(od.quantity * od.unit_price) AS total_order_value,
    ROUND((o.freight / SUM(od.quantity * od.unit_price)) * 100, 2)
        AS freight_percentage
FROM orders o
INNER JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY 
    o.order_id,
    o.freight
HAVING (o.freight / SUM(od.quantity * od.unit_price)) * 100 > 10
ORDER BY freight_percentage DESC;

-- CL




















-- Shipment Status
-- final result = summary table

SELECT 
    CASE
        WHEN shipped_date IS NULL THEN 'Not Shipped'
        WHEN shipped_date < required_date THEN 'Early'
        WHEN shipped_date = required_date THEN 'On Time'
        WHEN shipped_date > required_date THEN 'Late'
    END AS shipping_status,
    COUNT(DISTINCT order_id)
FROM orders
GROUP BY 
    CASE
        WHEN shipped_date IS NULL THEN 'Not Shipped'
        WHEN shipped_date < required_date THEN 'Early'
        WHEN shipped_date = required_date THEN 'On Time'
        WHEN shipped_date > required_date THEN 'Late'
    END;