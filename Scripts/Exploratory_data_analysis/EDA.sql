/********************************************************************************************
    Project : Data Warehouse & analytics 
    Purpose : Data exploration queries for validating, analyzing, and understanding the 
              Gold Layer (star schema). Includes:
                  - Metadata exploration
                  - Dimension insights
                  - Date ranges & customer demographics
                  - Key business metrics
                  - Aggregations & magnitude analysis
                  - Ranking & top/bottom performers
    Notes   : These queries are for exploration and validation. They do not modify data.
********************************************************************************************/


/********************************************************************************************
    DATABASE EXPLORATION
********************************************************************************************/

-- Explore all objects in the database
SELECT * 
FROM INFORMATION_SCHEMA.TABLES;

-- Explore all columns in the database for DIM_CUSTOMERS
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DIM_CUSTOMERS';


/********************************************************************************************
    DIMENSIONS EXPLORATION
********************************************************************************************/

-- Explore countries our customers come from
SELECT DISTINCT country 
FROM Gold.dim_customers;

-- Explore categories and subcategories of products
SELECT DISTINCT category, subcategory, product_name 
FROM Gold.dim_products
ORDER BY 1, 2, 3;


/********************************************************************************************
    DATE EXPLORATION
********************************************************************************************/

-- Order dates range
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_date_range
FROM Gold.fact_sales;

-- Find the oldest and youngest customer
SELECT 
    MIN(birthdate) AS oldest_customer,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_customer,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM Gold.dim_customers;


/********************************************************************************************
    DIMENSION EXPLORATION (Detailed)
********************************************************************************************/

-- Explore customers table
SELECT * 
FROM Gold.dim_customers;

-- Explore sales fact table
SELECT * 
FROM Gold.fact_sales;

-- Find the total sales
SELECT SUM(sales_amount) AS total_sales 
FROM Gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS total_items 
FROM Gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_price 
FROM Gold.fact_sales;

-- Find the total number of orders
SELECT COUNT(order_number) AS total_orders 
FROM Gold.fact_sales;

-- Find the total number of distinct orders
SELECT COUNT(DISTINCT order_number) AS total_orders 
FROM Gold.fact_sales;

-- Find the total number of products
SELECT COUNT(DISTINCT product_name) AS total_products 
FROM Gold.dim_products;

-- Find the total number of customers
SELECT COUNT(DISTINCT customer_key) AS total_customers 
FROM Gold.dim_customers;

-- Find the total number of customers that have placed an order
SELECT COUNT(DISTINCT customer_key) AS customers_with_orders
FROM Gold.fact_sales;

-- Generate a report of all key business metrics
SELECT 'Total Sales'          AS Measure_name, SUM(sales_amount) AS Measure_value FROM Gold.fact_sales
UNION ALL 
SELECT 'Total Quantity'       AS Measure_name, SUM(quantity)     AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Average Price'        AS Measure_name, AVG(price)        AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Total no.of orders'   AS Measure_name, COUNT(DISTINCT order_number) AS Measure_value FROM Gold.fact_sales
UNION ALL 
SELECT 'Total no.of products' AS Measure_name, COUNT(DISTINCT product_name) AS Measure_value FROM Gold.dim_products
UNION ALL
SELECT 'Total no.of customers' AS Measure_name, COUNT(DISTINCT customer_key) AS Measure_value FROM Gold.dim_customers;


/********************************************************************************************
    MAGNITUDE EXPLORATION
********************************************************************************************/

-- Find total customers by country
SELECT 
    country,
    COUNT(customer_key) AS no_of_customers
FROM Gold.dim_customers
GROUP BY country
ORDER BY no_of_customers DESC;

-- Find total customers by gender
SELECT 
    gender,
    COUNT(customer_key) AS no_of_customers
FROM Gold.dim_customers
GROUP BY gender
ORDER BY no_of_customers DESC;

-- Find total products by categories
SELECT 
    category,
    COUNT(product_key) AS no_of_products
FROM Gold.dim_products
GROUP BY category
ORDER BY no_of_products DESC;

-- What is the average cost in each category?
SELECT 
    category,
    AVG(cost) AS avg_cost
FROM Gold.dim_products 
GROUP BY category
ORDER BY avg_cost DESC;

-- What is the total revenue generated for each category?
SELECT 
    p.category,
    SUM(s.sales_amount) AS total_revenue
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_products p ON p.product_key = s.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Find total revenue generated by each customer
SELECT 
    c.customer_number,
    c.first_name,
    c.last_name,
    SUM(s.sales_amount) AS total_revenue
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customers c ON c.customer_key = s.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- What is the distribution of sold items across countries?
SELECT 
    c.country,
    SUM(s.quantity) AS total_sold_items
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customers c ON c.customer_key = s.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;


/********************************************************************************************
    RANKING EXPLORATION
********************************************************************************************/

-- Which 5 products generate the highest revenue
SELECT TOP 5
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_products p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Which 5 products generate the lowest revenue
SELECT TOP 5
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_products p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Find the top 10 customers who have generated the highest revenue
SELECT *
FROM (
    SELECT 
        c.customer_number,
        c.first_name,
        c.last_name,
        SUM(s.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount) DESC) AS customer_rank
    FROM Gold.fact_sales s
    LEFT JOIN Gold.dim_customers c ON c.customer_key = s.customer_key
    GROUP BY c.customer_number, c.first_name, c.last_name
) t
WHERE customer_rank <= 10;

-- Find the bottom 5 customers who have generated the lowest revenue
SELECT *
FROM (
    SELECT 
        c.customer_number,
        c.first_name,
        c.last_name,
        SUM(s.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount)) AS customer_rank
    FROM Gold.fact_sales s
    LEFT JOIN Gold.dim_customers c ON c.customer_key = s.customer_key
    GROUP BY c.customer_number, c.first_name, c.last_name
) t
WHERE customer_rank <= 5;
