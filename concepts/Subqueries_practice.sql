-- High-Spending Customers
SELECT
	customer_id,
	total_orders,
	total_sales
FROM 	
	(SELECT
		o.customer_id,
		COUNT(o.order_id) AS total_orders,
		SUM(od.unit_price * od.quantity) AS total_sales
	FROM orders o
	INNER JOIN order_details od
		ON o.order_id = od.order_id
	GROUP BY 
		o.customer_id) AS order_summary
WHERE total_sales > (
	SELECT
		AVG(total_sales)
    FROM (
        SELECT
            o.customer_id,
            SUM(od.unit_price * od.quantity) AS total_sales
        FROM orders o
        INNER JOIN order_details od
            ON o.order_id = od.order_id
        GROUP BY o.customer_id
    ) AS customer_summary
)
ORDER BY total_sales DESC;


-- Customers With No Purchases

SELECT
    c.customer_id
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Customers who have placed at least three orders.

SELECT
	customer_id,
	total_orders,
	total_sales
FROM 	
	(SELECT
		o.customer_id,
		COUNT(o.order_id) AS total_orders,
		SUM(od.unit_price * od.quantity) AS total_sales
	FROM orders o
	INNER JOIN order_details od
		ON o.order_id = od.order_id
	GROUP BY 
		o.customer_id) AS customer_summary
WHERE total_orders >= 3
ORDER BY total_sales DESC;


-- Largest Order Per Customer

SELECT
    customer_id,
    order_id,
    order_value,
    rank
FROM (
    SELECT
        customer_id,
        order_id,
        order_value,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY order_value DESC
        ) AS rank
    FROM (
        SELECT
            o.customer_id,
            o.order_id,
            SUM(od.unit_price * od.quantity) AS order_value
        FROM orders o
        INNER JOIN order_details od
            ON o.order_id = od.order_id
        GROUP BY
            o.customer_id,
            o.order_id
    ) AS order_summary
) AS ranked_orders
WHERE rank = 1;


-- Customers Who Bought a High-Value Product
SELECT DISTINCT
    o.customer_id
FROM orders o
JOIN order_details od
    ON o.order_id = od.order_id
WHERE od.unit_price > 50
ORDER BY o.customer_id;

-- Orders Above Their Customer's Average
SELECT
	customer_id,
	order_id,
	total_order_value
FROM 	
	(SELECT
		o.customer_id,
		o.order_id,
		SUM(od.unit_price * od.quantity) AS total_order_value
	FROM orders o
	INNER JOIN order_details od
		ON o.order_id = od.order_id
	GROUP BY 
		o.customer_id,
		o.order_id) AS order_summary
WHERE total_order_value > (
	SELECT
		AVG(total_order_value)
    FROM (
        SELECT
            o.customer_id,
			o.order_id,
            SUM(od.unit_price * od.quantity) AS total_order_value
        FROM orders o
        INNER JOIN order_details od
            ON o.order_id = od.order_id
        GROUP BY o.customer_id, o.order_id
    ) AS customer_order_summary
)
ORDER BY total_order_value DESC;

	