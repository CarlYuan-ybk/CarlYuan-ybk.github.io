#Overview

SELECT *
FROM integral-accord-433200-p6.Portfolio_Project.orders
Limit 10;

SELECT *
FROM integral-accord-433200-p6.Portfolio_Project.products
Limit 10;

#Check Missing Value

SELECT *
FROM integral-accord-433200-p6.Portfolio_Project.orders
WHERE transaction_id is NULL OR
transaction_date is NULL OR
transaction_time is NULL OR
store_id is NULL OR
store_location is NULL OR
product_id is NULL OR
transaction_qty is NULL OR
unit_price is NULL OR
Total_Bill is NULL;
--No missing value

SELECT *
FROM integral-accord-433200-p6.Portfolio_Project.products
WHERE transaction_id is NULL OR
product_id is NULL OR
product_category is NULL OR
product_type is NULL OR
product_detail is NULL OR
Size is NULL;
--No missing value

#Data types correct


------------------------------------------------------------------------------------
#A Identify the best-selling products 

SELECT 
product_category, 
product_type, 
product_detail
FROM integral-accord-433200-p6.Portfolio_Project.products;--check product related info

SELECT
  CONCAT(products.product_type,'_',products.product_detail) AS product_name, --combine product type and detail to provide more info
  ROUND(SUM(orders.Total_Bill),0) AS total_sales
FROM 
  integral-accord-433200-p6.Portfolio_Project.orders AS orders
INNER JOIN 
  integral-accord-433200-p6.Portfolio_Project.products AS products
ON 
  orders.transaction_id = products.transaction_id
GROUP BY 
  product_name
ORDER BY 
  total_sales DESC
LIMIT 10;


------------------------------------------------------------------------------------
#B Track category sales performance

SELECT transaction_date
FROM integral-accord-433200-p6.Portfolio_Project.orders;--check date format

SELECT 
DISTINCT product_category
FROM integral-accord-433200-p6.Portfolio_Project.products;--check category details

--overall category sales performance
SELECT
  products.product_category,
  ROUND(SUM(orders.Total_Bill),0) AS category_sales
FROM 
  integral-accord-433200-p6.Portfolio_Project.orders AS orders
INNER JOIN 
  integral-accord-433200-p6.Portfolio_Project.products AS products
ON 
  orders.transaction_id = products.transaction_id
GROUP BY
  products.product_category
ORDER BY 
  category_sales DESC;

--monthly sales performance
SELECT
  FORMAT_DATE('%b', transaction_date) AS month,
  ROUND(SUM(Total_Bill),0) AS monthly_sales
FROM 
  integral-accord-433200-p6.Portfolio_Project.orders
GROUP BY
  month
ORDER BY 
  monthly_sales DESC;


------------------------------------------------------------------------------------
#C Peak sales hours 

SELECT transaction_time
FROM integral-accord-433200-p6.Portfolio_Project.orders
ORDER BY transaction_time ASC;
--the earliest transaction at 6AM

SELECT transaction_time
FROM integral-accord-433200-p6.Portfolio_Project.orders
ORDER BY transaction_time DESC;
--the latest transaction at 8.59PM

SELECT
 CASE
    WHEN transaction_time >= '06:00:00' AND transaction_time < '11:00:00' THEN '6am to 11am'
    WHEN transaction_time >= '11:00:00' AND transaction_time < '16:00:00' THEN '11am to 4pm'
    WHEN transaction_time >= '16:00:00' AND transaction_time < '21:00:00' THEN '4pm to 9pm'
    ELSE 'Other'
  END AS transaction_time_period, --define time ranges and assign labels accordingly
  ROUND(SUM(Total_Bill), 0) AS total_transaction_amount
FROM 
  integral-accord-433200-p6.Portfolio_Project.orders
GROUP BY
  transaction_time_period
ORDER BY
  total_transaction_amount DESC;


------------------------------------------------------------------------------------
#D Average store daily sales

SELECT store_id, store_location
FROM integral-accord-433200-p6.Portfolio_Project.orders
GROUP BY store_id, store_location;--check if there are multiple store ids linked to the same location 

WITH store_daily_sales AS (
  SELECT
    transaction_date,
    store_location,
    SUM(Total_Bill) AS daily_total_sales
  FROM
    integral-accord-433200-p6.Portfolio_Project.orders
  GROUP BY
    store_location, transaction_date
)--calculate store daily sales
SELECT
  COUNT(DISTINCT transaction_date) AS total_days, 
  store_location,
  ROUND(SUM(daily_total_sales), 0) AS total_sales, 
  ROUND(SUM(daily_total_sales) / COUNT(DISTINCT transaction_date), 0) AS average_store_daily_sales
FROM
  store_daily_sales
GROUP BY
  store_location
ORDER BY
  average_store_daily_sales DESC;
