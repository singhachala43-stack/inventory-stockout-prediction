SELECT 
    Warehouse,
    COUNT(*) AS Total_Stockout_Days,
    COUNT(DISTINCT Product) AS Products_Affected,
    ROUND(SUM(Lost_Sales), 0) AS Total_Units_Lost
FROM inventory_sales
WHERE Stockout_Flag = 1
GROUP BY Warehouse
ORDER BY Total_Stockout_Days DESC;

SELECT 
    Supplier,
    Lead_Time,
    COUNT(*) AS Total_Stockout_Days,
    COUNT(DISTINCT Product) AS Products_Affected
FROM inventory_sales
WHERE Stockout_Flag = 1
GROUP BY Supplier, Lead_Time
ORDER BY Total_Stockout_Days DESC;

SELECT 
    Product,
    Category,
    ROUND(SUM(Lost_Sales) * AVG(Price), 0) AS Revenue_At_Risk,
    SUM(Lost_Sales) AS Total_Units_Lost,
    ROUND(AVG(Price), 2) AS Avg_Price
FROM inventory_sales
GROUP BY Product, Category
ORDER BY Revenue_At_Risk DESC
LIMIT 10;