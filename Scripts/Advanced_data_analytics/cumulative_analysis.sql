---------------------------------
----Cumulative analysis----------
---------------------------------

/*calculate total sales per month 
and the running total of sales over time and price's moving average */
SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
avg_price,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
SELECT 
	DATETRUNC(MONTH,order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM Gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
)t
