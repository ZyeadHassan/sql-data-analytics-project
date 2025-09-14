---------------------------------
----Segmentation analysis--------
---------------------------------
/*Segment products into cost ranges and 
count how many products fall into each segment*/

WITH product_segmentation AS (
SELECT
	product_key,
	product_name,
	cost,
CASE 
	WHEN cost<100 THEN 'Below 100'
	WHEN cost>100 AND cost<500 THEN '100-500'
	WHEN cost>500 AND cost<1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_segment
FROM Gold.dim_products
)
SELECT 
	cost_segment,
	COUNT(product_key) AS total_products
FROM product_segmentation
GROUP BY cost_segment
ORDER BY total_products DESC

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_loyality AS (
SELECT 
	c.customer_id,
	SUM(s.sales_amount) AS 'total_spending',
	MIN(s.order_date) AS first_order,
	MAX(s.order_date) AS last_order,
	DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) AS lifespan
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customers c
ON s.customer_key=c.customer_key
GROUP BY customer_id
)
SELECT
	customer_types,
	COUNT(customer_id) AS total_customers
FROM (
SELECT 
	customer_id,
	total_spending,
	lifespan,
CASE
	WHEN lifespan >=12 AND total_spending >5000 THEN 'VIP'
	WHEN lifespan >=12 AND total_spending <=5000 THEN 'Regular'
	ELSE 'New'
END AS customer_types
FROM customer_loyality
)AS customer_retention
GROUP BY customer_types
ORDER BY total_customers DESC

