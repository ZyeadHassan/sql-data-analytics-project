---------------------------------
----Proportion analysis----------
---------------------------------

--Which categories contribute to overall sales

WITH category_sales AS (
SELECT
	P.category,
	SUM(S.sales_amount) AS total_sales
FROM Gold.fact_sales S
LEFT JOIN Gold.dim_products P
ON S.product_key=P.product_key
GROUP BY P.category
)

SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER () overall_sales,
	CONCAT(ROUND((CAST(total_sales AS float) /SUM(total_sales) OVER () )*100,2) ,'%')
FROM category_sales
ORDER BY total_sales DESC
