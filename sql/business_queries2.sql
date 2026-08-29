SELECT 
    Product,
    Category,
    COUNT(*) AS Total_Stockout_Days,
    ROUND(AVG(Price), 2) AS Avg_Price
FROM inventory_sales
WHERE Stockout_Flag = 1
GROUP BY Product, Category
ORDER BY Total_Stockout_Days DESC
LIMIT 10;