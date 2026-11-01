-- YEARLY CUSTOMERS SALES TREND 
SELECT distinct Year,
       country,
       customer_name,
       SUM(order_value) AS total_revenue,
       (SUM(order_value)-LAG(SUM(order_value))OVER(PARTITION BY country,customer_name ORDER BY Year))/LAG(SUM(order_value))OVER(PARTITION BY country,customer_name ORDER BY Year) AS yoy_revenue_variations
FROM sales
GROUP BY 1, 2, 3
ORDER BY 1, 2;



-- SALES KPI PER CATEGORY
SELECT DISTINCT year,
       country,
       category,
       customer_name,
       SUM(order_value) AS total_sales,
       SUM(order_cost) AS total_cost,
       SUM(order_value)-SUM(order_cost) AS profit,
       COUNT(order_id) AS total_orders,
       ROUND((SUM(SUM(order_value)-SUM(order_cost))OVER(PARTITION BY country,category,customer_name ORDER BY year)/SUM(SUM(order_value)-SUM(order_cost))OVER(PARTITION BY country,category ORDER BY year))*100,0) AS pct_category
FROM sales 
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4;




-- SALES KPI PER COUNTRY
SELECT DISTINCT year,
       country,
       customer_name,
       SUM(order_value) AS total_sales,
       SUM(order_cost) AS total_cost,
       SUM(order_value)-SUM(order_cost) AS profit,
       (ROUND(SUM(SUM(order_value)-SUM(order_cost))OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(SUM(order_value)-SUM(order_cost))OVER(PARTITION BY country ORDER BY year),3))*100 AS pct_country
FROM sales
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;




-- BUSINESS INDEX
WITH n AS( 
SELECT year,
       country,
       COUNT(DISTINCT customer_name) AS customers
FROM sales
GROUP BY 1, 2
ORDER BY 1, 2
),
businessindex AS ( 
SELECT DISTINCT year,
       country,
       customer_name,
       order_value,
       ROUND(SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year),4) AS pi,
       ROUND((SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year))**2,4) as pi_2,
       ROUND((SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year))*(-LN(SUM(order_value)OVER(PARTITION BY country,customer_name ORDER BY year)/SUM(order_value)OVER(PARTITION BY country ORDER BY year))),2) AS pi_ln
FROM sales
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3
) 
SELECT n.year,
       n.country,
       n.customers,
       ROUND(SUM(businessindex.pi_2),2) AS HHI,
       ROUND(SUM(businessindex.pi_ln)/LN(n.customers),2) AS ES
FROM n LEFT JOIN businessindex ON n.country = businessindex.country 
GROUP BY 1, 2, 3
ORDER BY 1, 2;




WITH Table1 AS (
SELECT DISTINCT Year,
       country,
       category,
       customer_Name,
       SUM(order_value) AS Total_Revenue,
       SUM(order_cost) AS Total_Cost,
       SUM(order_value)-SUM(order_cost) AS Profit,
       COUNT(order_id) AS Total_orders,
       ROUND(SUM(order_value)/COUNT(order_id),0) AS Average_Order_Value
FROM sales
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4
) 
SELECT Year,
       Country,
       Category,
       Customer_Name,
       Total_Revenue,
       Total_Cost,
       Profit,
       Total_Orders,
       Average_Order_Value,
       ROUND(((SUM(Average_Order_Value)-LAG(SUM(Average_Order_Value))OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year))/LAG(SUM(Average_Order_Value))OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year))*100,2) AS AOV_YoY_Variations,
       ROUND(((SUM(Total_orders)-LAG(SUM(Total_Orders))OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year))/LAG(SUM(Total_Orders))OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year))*100,2) AS Orders_YoY_Variations,
       ROUND(((SUM(Total_Revenue)-LAG(SUM(Total_Revenue))OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year))/LAG(SUM(Total_Revenue))OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year))*100,2) AS Revenue_YoY_Variations,
       ROUND((SUM(Profit)OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year)/SUM(Profit)OVER(PARTITION BY Country ORDER BY Year))*100,2) AS Profit_per_Country,
       ROUND((SUM(Total_Orders)OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year)/SUM(Total_Orders)OVER(PARTITION BY Country ORDER BY Year))*100,2) AS Orders_per_Country,
       ROUND((SUM(Profit)OVER(PARTITION BY Country,Category,Customer_Name ORDER BY Year)/SUM(Profit)OVER(PARTITION BY Country,Category ORDER BY Year))*100,2) AS Profit_per_Category
FROM Table1 
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
ORDER BY 1, 2, 3, 4;

 

-- CUSTOMER SEGMENTATION
WITH customer_segmentation AS(
SELECT year,
       customer_name,
       country,
       category,
       SUM(order_value) AS total_revenue,
       NTILE(5)OVER(ORDER BY total_revenue) AS revenue_ntile
FROM sales 
GROUP BY 1, 2, 3, 4
ORDER BY 1
)
SELECT year,
       customer_name,
       country,
       category,
       total_revenue,
       revenue_ntile,
       CASE 
       WHEN revenue_ntile = 5 THEN 'tier 1 client'
       WHEN revenue_ntile = 4 THEN 'tier 2 client'
       WHEN revenue_ntile = 3 THEN 'tier 3 client'
       WHEN revenue_ntile = 2 THEN 'tier 4 client'
       WHEN revenue_ntile = 1 THEN 'tier 5 client'
       END AS Revenue_Segmentation          
FROM customer_segmentation
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY 1;

