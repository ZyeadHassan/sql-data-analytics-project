---------------------------------
----Performance analysis---------
---------------------------------

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and 
the previous year's sales */

WITH yearly_product_sales AS (
SELECT 
	YEAR(s.order_date) AS order_date,
	product_name,
	SUM(s.sales_amount) AS current_sales
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_products p
ON s.product_key=p.product_key
WHERE order_date IS NOT NULL
GROUP BY
	YEAR(s.order_date),
	product_name
)
SELECT 
	order_date,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name)AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS avg_diff,
CASE 
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) >0 THEN 'Above average'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) <0 THEN 'below average'
	ELSE 'avg'
END AS 'avg_change',
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) AS prev_year,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) AS prev_diff,
CASE 
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) >0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_date) <0 THEN 'Decrease'
	ELSE 'No change'
END AS 'prev_change'
FROM yearly_product_sales
ORDER BY product_name,order_date

