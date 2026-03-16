-- =========================================
-- SUPERSTORE BUSINESS ANALYSIS PROJECT
-- Author: Minakshi Yadav
-- Tool: SQL Server
-- =========================================

-- 1. KPI SUMMARY
-- Total Sales, Total Profit, Total Orders, Avg Order Value

SELECT ROUND(SUM(Sales),2) AS TotalSales
FROM dbo.superstore_orders;

-- Total Profit
SELECT ROUND(SUM(Profit),2) AS TotalProfit
FROM dbo.superstore_orders;

-- Total Orders
SELECT COUNT(DISTINCT order_id) AS TotalOrders
FROM dbo.superstore_orders;

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS TotalCustomers
FROM dbo.superstore_orders;

-- Average Order Value
SELECT ROUND(SUM(Sales) / COUNT(DISTINCT order_id),2) AS AvgOrderValue
FROM dbo.superstore_orders;

-- 2. CATEGORY ANALYSIS
SELECT 
    Category,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit,
    COUNT(DISTINCT order_id) AS TotalOrders
FROM dbo.superstore_orders
GROUP BY Category
ORDER BY TotalSales DESC;

-- SUB-CATEGORY ANALYSIS

SELECT 
    Sub_Category,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit,
    COUNT(DISTINCT order_id) AS TotalOrders
FROM dbo.superstore_orders
GROUP BY Sub_Category
ORDER BY TotalSales DESC;

-- 3. REGIONAL ANALYSIS
SELECT 
    Region,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit,
    COUNT(DISTINCT order_id) AS TotalOrders
FROM dbo.superstore_orders
GROUP BY Region
ORDER BY TotalSales DESC;

-- 4. PRODUCT ANALYSIS
SELECT TOP 10
    Product_Name,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit
FROM dbo.superstore_orders
GROUP BY Product_Name
ORDER BY TotalSales DESC;
-- Top 10 Products by Profit

SELECT TOP 10
    Product_Name,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit
FROM dbo.superstore_orders
GROUP BY Product_Name
ORDER BY TotalProfit DESC;
-- Loss Making Products

SELECT
    Product_Name,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit
FROM dbo.superstore_orders
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY TotalProfit ASC;

WITH ProductProfit AS (
    SELECT 
        Product_Name,
        SUM(Profit) AS TotalProfit
    FROM dbo.superstore_orders
    GROUP BY Product_Name
),

ProfitWithRunningTotal AS (
    SELECT 
        Product_Name,
        TotalProfit,
        SUM(TotalProfit) OVER (ORDER BY TotalProfit DESC) AS RunningProfit,
        SUM(TotalProfit) OVER () AS OverallProfit
    FROM ProductProfit
)

SELECT 
    Product_Name,
    TotalProfit,
    ROUND((RunningProfit * 100.0 / OverallProfit),2) AS CumulativeProfitPercent
FROM ProfitWithRunningTotal
WHERE (RunningProfit * 100.0 / OverallProfit) <= 80
ORDER BY TotalProfit DESC;

-- 5. CUSTOMER ANALYSIS
SELECT TOP 10
    Customer_Name,
    ROUND(SUM(Sales),2)  AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit,
    COUNT(DISTINCT Order_ID) AS TotalOrders
FROM dbo.superstore_orders
GROUP BY Customer_Name
ORDER BY TotalProfit DESC;
-- Customers ranked by number of orders

SELECT 
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS TotalOrders,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit
FROM dbo.superstore_orders
GROUP BY Customer_Name
ORDER BY TotalOrders DESC;
-- Customers generating overall loss

SELECT 
    Customer_Name,
    ROUND(SUM(Sales),2) AS TotalSales,
    ROUND(SUM(Profit),2) AS TotalProfit,
    COUNT(DISTINCT Order_ID) AS TotalOrders
FROM dbo.superstore_orders
GROUP BY Customer_Name
HAVING SUM(Profit) < 0
ORDER BY TotalProfit ASC;
-- Customer Segmentation

WITH CustomerSummary AS (
    SELECT 
        Customer_Name,
        SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit,
        COUNT(DISTINCT Order_ID) AS TotalOrders
    FROM dbo.superstore_orders
    GROUP BY Customer_Name
)

SELECT *,
    CASE 
        WHEN TotalProfit > 5000 THEN 'High Value'
        WHEN TotalProfit BETWEEN 1000 AND 5000 THEN 'Medium Value'
        WHEN TotalProfit BETWEEN 0 AND 1000 THEN 'Low Value'
        ELSE 'Loss Making'
    END AS CustomerSegment
FROM CustomerSummary
ORDER BY TotalProfit DESC;

SELECT 
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.superstore_orders
GROUP BY customer_name;

WITH customer_orders AS (
    SELECT 
        customer_name,
        COUNT(DISTINCT order_id) AS total_orders
    FROM dbo.superstore_orders
    GROUP BY customer_name
)

SELECT 
    customer_name,
    total_orders,
    CASE 
        WHEN total_orders BETWEEN 15 AND 25 THEN 'Low Frequency'
        WHEN total_orders BETWEEN 26 AND 35 THEN 'Medium Frequency'
        ELSE 'High Frequency'
    END AS order_frequency_category
FROM customer_orders
ORDER BY total_orders DESC;

SELECT 
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0 
    / COUNT(DISTINCT customer_id) AS repeat_customer_percentage
FROM (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM dbo.superstore_orders
    GROUP BY customer_id
) t;
SELECT 
    segment,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM dbo.superstore_orders
GROUP BY segment;

-- 6. TIME ANALYSIS
SELECT 
    YEAR(order_date) AS year,
    SUM(sales) AS total_sales
FROM dbo.superstore_orders
GROUP BY YEAR(order_date)
ORDER BY year;

SELECT 
    DATENAME(MONTH, order_date) AS month_name,
    SUM(sales) AS total_sales
FROM dbo.superstore_orders
GROUP BY 
    MONTH(order_date),
    DATENAME(MONTH, order_date)
ORDER BY 
    MONTH(order_date);

    SELECT 
    YEAR(order_date) AS year,
    DATENAME(MONTH, order_date) AS month_name,
    SUM(sales) AS total_sales
FROM dbo.superstore_orders 
GROUP BY 
    YEAR(order_date),
    MONTH(order_date),
    DATENAME(MONTH, order_date)
ORDER BY 
    YEAR(order_date),
    MONTH(order_date);

   SELECT 
    DATENAME(MONTH, order_date) AS month_name,
    ROUND(SUM(profit), 2) AS total_profit
FROM dbo.superstore_orders
GROUP BY 
    MONTH(order_date),
    DATENAME(MONTH, order_date)
ORDER BY 
    total_profit DESC;

    -- 7. PROFIT MARGIN ANALYSIS
    SELECT 
    SUM(profit) AS total_profit,
    SUM(sales) AS total_sales,
    ROUND((SUM(profit) * 100.0 / SUM(sales)), 2) AS profit_margin_percentage
FROM dbo.superstore_orders 

SELECT 
    category,
    ROUND((SUM(profit) * 100.0 / SUM(sales)), 2) AS profit_margin_percentage
FROM dbo.superstore_orders 
GROUP BY category
ORDER BY profit_margin_percentage DESC;

