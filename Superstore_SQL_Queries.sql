-- ============================================================
-- SUPERSTORE SALES ANALYSIS — SQL QUERIES
-- Author: Sudhir Kumar | Data Analyst
-- Dataset: Superstore Sales
-- ============================================================

-- ── 1. OVERALL KPI SUMMARY ──────────────────────────────────
SELECT 
    ROUND(SUM(Sales), 2)                          AS Total_Revenue,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    ROUND((SUM(Profit)/SUM(Sales))*100, 2)        AS Profit_Margin_Pct,
    COUNT(DISTINCT `Order ID`)                    AS Total_Orders,
    COUNT(DISTINCT `Customer ID`)                 AS Total_Customers,
    COUNT(DISTINCT `Product ID`)                  AS Total_Products,
    ROUND(SUM(Sales)/COUNT(DISTINCT `Order ID`),2) AS Avg_Order_Value
FROM superstore;

-- ── 2. MONTHLY REVENUE TREND ────────────────────────────────
SELECT 
    YEAR(`Order Date`)                            AS Year,
    MONTH(`Order Date`)                           AS Month_Num,
    DATE_FORMAT(`Order Date`, '%b %Y')            AS Month,
    ROUND(SUM(Sales), 2)                          AS Monthly_Revenue,
    ROUND(SUM(Profit), 2)                         AS Monthly_Profit,
    COUNT(DISTINCT `Order ID`)                    AS Orders,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct
FROM superstore
GROUP BY YEAR(`Order Date`), MONTH(`Order Date`), DATE_FORMAT(`Order Date`, '%b %Y')
ORDER BY Year, Month_Num;

-- ── 3. MONTH-OVER-MONTH GROWTH (Window Function) ────────────
SELECT 
    Month,
    Monthly_Revenue,
    LAG(Monthly_Revenue) OVER (ORDER BY Year, Month_Num) AS Prev_Month_Revenue,
    ROUND(
        (Monthly_Revenue - LAG(Monthly_Revenue) OVER (ORDER BY Year, Month_Num))
        / LAG(Monthly_Revenue) OVER (ORDER BY Year, Month_Num) * 100, 1
    ) AS MoM_Growth_Pct
FROM (
    SELECT 
        YEAR(`Order Date`) AS Year,
        MONTH(`Order Date`) AS Month_Num,
        DATE_FORMAT(`Order Date`, '%b %Y') AS Month,
        ROUND(SUM(Sales), 2) AS Monthly_Revenue
    FROM superstore
    GROUP BY YEAR(`Order Date`), MONTH(`Order Date`), DATE_FORMAT(`Order Date`, '%b %Y')
) monthly_data
ORDER BY Year, Month_Num;

-- ── 4. SALES & PROFIT BY CATEGORY ───────────────────────────
SELECT 
    Category,
    ROUND(SUM(Sales), 2)                          AS Total_Sales,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    COUNT(DISTINCT `Order ID`)                    AS Total_Orders,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct,
    RANK() OVER (ORDER BY SUM(Sales) DESC)        AS Revenue_Rank
FROM superstore
GROUP BY Category
ORDER BY Total_Sales DESC;

-- ── 5. TOP 10 SUB-CATEGORIES BY REVENUE ─────────────────────
SELECT 
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2)                          AS Total_Sales,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct,
    SUM(Quantity)                                 AS Units_Sold,
    DENSE_RANK() OVER (ORDER BY SUM(Sales) DESC)  AS Revenue_Rank
FROM superstore
GROUP BY Category, `Sub-Category`
ORDER BY Total_Sales DESC
LIMIT 10;

-- ── 6. REGIONAL PERFORMANCE ─────────────────────────────────
SELECT 
    Region,
    ROUND(SUM(Sales), 2)                          AS Total_Revenue,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    COUNT(DISTINCT `Order ID`)                    AS Total_Orders,
    COUNT(DISTINCT `Customer ID`)                 AS Unique_Customers,
    ROUND(SUM(Sales)/COUNT(DISTINCT `Order ID`),2) AS Avg_Order_Value,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct
FROM superstore
GROUP BY Region
ORDER BY Total_Revenue DESC;

-- ── 7. TOP 10 CUSTOMERS BY REVENUE ──────────────────────────
SELECT 
    `Customer Name`,
    Segment,
    Region,
    COUNT(DISTINCT `Order ID`)                    AS Total_Orders,
    ROUND(SUM(Sales), 2)                          AS Total_Revenue,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct,
    DENSE_RANK() OVER (ORDER BY SUM(Sales) DESC)  AS Revenue_Rank
FROM superstore
GROUP BY `Customer Name`, Segment, Region
ORDER BY Total_Revenue DESC
LIMIT 10;

-- ── 8. CUSTOMER SEGMENT ANALYSIS ────────────────────────────
SELECT 
    Segment,
    ROUND(SUM(Sales), 2)                          AS Total_Revenue,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    COUNT(DISTINCT `Customer ID`)                 AS Customers,
    COUNT(DISTINCT `Order ID`)                    AS Orders,
    ROUND(SUM(Sales)/COUNT(DISTINCT `Customer ID`),2) AS Revenue_Per_Customer,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct
FROM superstore
GROUP BY Segment
ORDER BY Total_Revenue DESC;

-- ── 9. SHIPPING MODE ANALYSIS ───────────────────────────────
SELECT 
    `Ship Mode`,
    COUNT(DISTINCT `Order ID`)                    AS Total_Orders,
    ROUND(SUM(Sales), 2)                          AS Total_Revenue,
    ROUND(AVG(Sales), 2)                          AS Avg_Order_Value,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    ROUND(
        DATEDIFF(`Ship Date`, `Order Date`)
    , 0)                                          AS Note_Delivery_Days
FROM superstore
GROUP BY `Ship Mode`
ORDER BY Total_Revenue DESC;

-- ── 10. DISCOUNT IMPACT ANALYSIS ────────────────────────────
SELECT 
    CASE 
        WHEN Discount = 0    THEN 'No Discount'
        WHEN Discount <= 0.1 THEN '1-10% Discount'
        WHEN Discount <= 0.2 THEN '11-20% Discount'
        WHEN Discount <= 0.3 THEN '21-30% Discount'
        ELSE '31%+ Discount'
    END AS Discount_Band,
    COUNT(*)                                      AS Orders,
    ROUND(SUM(Sales), 2)                          AS Total_Sales,
    ROUND(AVG(Profit), 2)                         AS Avg_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct
FROM superstore
GROUP BY Discount_Band
ORDER BY MIN(Discount);

-- ── 11. YEAR-OVER-YEAR COMPARISON ───────────────────────────
SELECT 
    YEAR(`Order Date`)                            AS Year,
    ROUND(SUM(Sales), 2)                          AS Annual_Revenue,
    ROUND(SUM(Profit), 2)                         AS Annual_Profit,
    COUNT(DISTINCT `Order ID`)                    AS Total_Orders,
    ROUND(SUM(Profit)/SUM(Sales)*100, 1)          AS Profit_Margin_Pct,
    ROUND(
        (SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY YEAR(`Order Date`)))
        / LAG(SUM(Sales)) OVER (ORDER BY YEAR(`Order Date`)) * 100, 1
    ) AS YoY_Growth_Pct
FROM superstore
GROUP BY YEAR(`Order Date`)
ORDER BY Year;

-- ── 12. LOSS-MAKING PRODUCTS ────────────────────────────────
SELECT 
    `Product Name`,
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2)                          AS Total_Sales,
    ROUND(SUM(Profit), 2)                         AS Total_Profit,
    COUNT(*)                                      AS Times_Ordered
FROM superstore
GROUP BY `Product Name`, Category, `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC
LIMIT 10;
