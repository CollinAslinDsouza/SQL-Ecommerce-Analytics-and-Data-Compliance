-- Total Revenue generated over the period of time
-- Revenue = Quantity * Price
-- Quantity is present in order details table
-- Price is present in products table

SELECT SUM(OD.quantity*P.price) AS total_revenue
FROM orderdetails AS OD
INNER JOIN products AS P ON OD.productid = P.productid;

-- Revenue Excluding Returned Orders
SELECT SUM(OD.quantity*P.price) AS `Revenue Excluding Returns`
FROM orders O
INNER JOIN orderdetails OD on O.OrderID = OD.OrderID
INNER JOIN products P ON OD.ProductID = P.ProductID
WHERE IsReturned = 0;

-- Total Revenue per Year / Month
SELECT YEAR(OrderDate) AS `Year`, 
		MONTH(OrderDate) AS `Month`,
        SUM(OD.Quantity * P.Price) AS `Monthly Revenue`
FROM orders O
INNER JOIN orderdetails OD on O.OrderID = OD.OrderID
INNER JOIN products P ON OD.ProductID = P.ProductID
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;

-- Revenue by Product / Category
SELECT Category, ProductName,
		SUM(OD.Quantity* P.Price) AS Revenue_By_Product
FROM orderdetails OD
INNER JOIN products P ON OD.ProductID = P.ProductID
GROUP BY Category, ProductName
ORDER BY Category, Revenue_By_Product DESC;

-- What is the average order value (AOV) across all orders?
-- AOV = TOtal Order Value / Number of orders
SELECT AVG(Total_OrderValue) AS AOV
FROM (SELECT O.OrderID, SUM(OD.Quantity * P.Price) AS Total_OrderValue
		FROM orders O
		JOIN orderdetails OD ON OD.OrderID = O.OrderID
		JOIN products P on P.ProductID = OD.ProductID
		GROUP BY O.OrderID
		ORDER BY O.OrderID) AS T;

-- AOV per Year / Month
SELECT YEAR(OrderDate) AS `Year`, 
		MONTH(OrderDate) AS `Month`, 
        AVG(Total_OrderValue) AS AOV
FROM (SELECT O.OrderID, O.OrderDate, SUM(OD.Quantity * P.Price) AS Total_OrderValue
		FROM orders O
		JOIN orderdetails OD ON OD.OrderID = O.OrderID
		JOIN products P on P.ProductID = OD.ProductID
		GROUP BY O.OrderID
		ORDER BY O.OrderID) AS T
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;


-- What is the average order size by region?
SELECT RegionName, AVG(Total_order_size) AS AOS
FROM (SELECT O.OrderID, C.RegionID, SUM(OD.Quantity) AS Total_order_size
		FROM orders O
		JOIN customers C ON C.CustomerID = O.CustomerID
		JOIN orderdetails OD ON OD.OrderID = O.OrderID
		GROUP BY O.OrderID, C.RegionID) AS T 
JOIN Regions R ON R.RegionID = T.RegionID
GROUP BY RegionName
ORDER BY AOS DESC;


-- Who are the top 10 customers by total revenue spent?
SELECT C.customerID, C.CustomerName, SUM(OD.Quantity * P.Price) AS TotalRevenue
FROM Customers C
JOIN Orders O on O.CustomerID = C.CustomerID
JOIN orderdetails OD ON OD.OrderID = O.OrderID
JOIN products P ON P.ProductID = OD.ProductID
GROUP BY C.CustomerID
ORDER BY TotalRevenue DESC 
LIMIT 10;

-- What is the repeat customer rate? Repeat customer = Repeat Customers / Total Customers
WITH OrderNumbersTable AS(
	SELECT CustomerID, COUNT(OrderID) AS NumberOfOrders
	FROM Orders 
	GROUP BY CustomerID
    )
SELECT ROUND(COUNT(CASE WHEN NumberOfOrders > 1 THEN CustomerID END) /
		COUNT(NumberOfOrders),2) AS `Repeat Order Rate`
from OrderNumbersTable;

-- What is the average time between two consecutive orders for the same customer Region-wise?
WITH RankOrders AS (
    SELECT 
        O.CustomerID, 
        O.OrderDate, 
        C.RegionID,
        ROW_NUMBER() OVER (PARTITION BY O.CustomerID ORDER BY O.OrderDate) AS rn
    FROM Orders O
    JOIN Customers C ON C.CustomerID = O.CustomerID
),
OrderPairs AS (
    SELECT 
        curr.CustomerID, 
        curr.RegionID, 
        DATEDIFF(curr.OrderDate, prev.OrderDate) AS DaysBetween
    FROM RankOrders curr
    JOIN RankOrders prev 
        ON curr.CustomerID = prev.CustomerID 
       AND curr.rn = prev.rn + 1
),
RegionName AS (
    SELECT 
        OP.CustomerID, 
        R.RegionName,
        OP.DaysBetween
    FROM OrderPairs OP
    JOIN Regions R ON R.RegionID = OP.RegionID
)
SELECT 
    RegionName, 
    ROUND(AVG(DaysBetween), 2) AS AvgDaysBetween
FROM RegionName
GROUP BY RegionName
ORDER BY AvgDaysBetween;

-- Customer Segment (based on total spend)
-- Platinum: Total Spend > 1500
-- Gold: 1000–1500
-- Silver: 500–999
-- Bronze: < 500

WITH CustomerSpend AS(
	SELECT O.CustomerId, SUM(OD.Quantity*P.Price) AS TotalSpend
	FROM orders O
	JOIN orderdetails OD ON OD.OrderId = O.OrderId
	JOIN products P ON P.ProductId = OD.ProductId
	GROUP BY O. CustomerId
)
SELECT CustomerName,
	CASE
		WHEN TotaLSpend > 1500 THEN "PLatinum"
		WHEN TotalSpend BETWEEN 1000 AND 1500 THEN "Gold"
		WHEN TotalSpend BETWEEN 500 AND 999 THEN "Silver"
		WHEN TotalSpend < 500 THEN "Bronze"
	END AS Segment
FROM CustomerSpend CS 
JOIN customers C ON C.CustomerID = CS.CustomerID;


-- What is the customer lifetime value (CLV)?
SELECT C.CustomerId, C.CustomerName, SUM(OD.Quantity*p.Price) AS CLV FROM customers C
JOIN orders O ON O.CustomerId = C.CustomerId
JOIN orderdetails OD ON OD.OrderId = O.OrderId
JOIN Products P ON P.Productid = OD.ProductId
GROUP BY C. CustomerId, C.CustomerName
ORDER BY CLV DESC;

-- Product & Order Insights
-- What are the top 10 most sold products (by quantity)?
SELECT P.ProductId, ProductName, SUM(OD.Quantity) AS TotalQty
FROM orderdetails OD
JOIN Products P ON P. ProductId = OD.ProductId
GROUP BY P.ProductId, ProductName
ORDER BY TotalQty DESC
LIMIT 10;

-- What are the top 10 most sold products (by revenue)?
SELECT P.ProductId, ProductName, SUM(OD.Quantity* P.Price) AS TotalRevenue
FROM orderdetails OD
JOIN Products P ON P. ProductId = OD.ProductId
GROUP BY P.ProductId, ProductName
ORDER BY TotalRevenue DESC
LIMIT 10;


-- Which products have the highest return rate?
WITH Sold AS(
	SELECT ProductID, SUM(Quantity) AS TotalQty
    FROM orderdetails
    GROUP BY ProductID
),
Returned AS(
	SELECT ProductId, SUM(Quantity) AS TotalQtyReturned
	FROM orderdetails OD
	JOIN orders O ON O.OrderId = OD.OrderId
	WHERE isReturned = 1
	GROUP BY ProductID 
)
SELECT ProductName, ROUND((TotalQtyReturned / TotalQty),2) AS ReturnRate
FROM Products P 
JOIN Sold S ON S.ProductID = P.ProductID 
JOIN Returned R ON R.ProductID = P.ProductID
ORDER BY ReturnRate DESC
LIMIT 10;

-- Return Rate by Category
WITH Sold AS(
	SELECT Category, SUM(Quantity) AS TotalQty
    FROM orderdetails OD
    JOIN products P ON P.ProductID = OD.ProductID 
    GROUP BY Category
),
Returned AS(
	SELECT Category, SUM(Quantity) AS TotalQtyReturned
	FROM orderdetails OD
    JOIN orders O ON O.OrderID = OD.OrderID
	JOIN products P ON P.ProductId = OD.ProductId
	WHERE isReturned = 1
	GROUP BY Category 
)
SELECT S.Category, ROUND((TotalQtyReturned / TotalQty),2) AS ReturnRate
FROM Sold S 
JOIN Returned R ON R.Category = S.Category
ORDER BY ReturnRate DESC
LIMIT 10;

-- What is the average price of products per region?
SELECT RegionName, ROUND(SUM(OD.Quantity*P.Price) / SUM(OD.Quantity), 2) AS AvgPrice
FROM orders O
JOIN Customers C ON C.CustomerId = O.CustomerId
JOIN Regions R ON R.RegionId = C.RegionId
JOIN Orderdetails OD ON OD.OrderId = O.OrderId
JOIN Products P ON P.ProductId = OD.OrderId
GROUP BY RegionName
ORDER BY AvgPrice DESC;

-- What is the sales trend for each product category?
SELECT DATE_FORMAT(OrderDate, "%Y-%m") AS Period, Category, SUM(OD.Quantity*P.price) AS Revenue
FROM Orders O
JOIN Orderdetails OD ON OD.Orderid = O.Orderid
JOIN Products P ON P.ProductId = OD.ProductId
GROUP BY Period, Category
ORDER BY Period, Category, Revenue DESC;

-- Temporal Trends
-- What are the monthly sales trends over the past year?
SELECT YEAR(OrderDate) AS `Year`,
		MONTH(OrderDate) AS `Month`, 
        SUM(OD.Quantity*P.Price) AS Revenue
FROM Orders O
JOIN OrderDetails OD ON OD.OrderId = O.OrderId
JOIN Products P ON P.ProductId = OD. ProductId
WHERE OrderDate >= '2024-04-01'
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;


-- How does the average order value (AOV) change by month or week?
SELECT DATE_FORMAT(OrderDate, "%Y-%m") AS Period,
		ROUND(SUM(OD.Quantity*P.Price) / COUNT(DISTINCT O.OrderId), 2) AS AOV
FROM Orders O
JOIN OrderDetails OD ON OD.OrderId = O.OrderId
JOIN Products P ON P.ProductId = OD.ProductId
GROUP BY Period
ORDER BY Period;

-- Regional Insights
-- Which regions have the highest order volume and which have the lowest?
SELECT RegionName, COUNT(OrderId) AS OrderVolume
FROM Orders O
JOIN Customers C ON C.CustomerId = O.CustomerId
JOIN Regions R ON R.RegionID = C.RegionID
GROUP BY RegionName
ORDER BY OrderVolume DESC;

-- What is the revenue per region and how does it compare across different regions?
SELECT RegionName, SUM(OD.Quantity* P.Price) AS TotalRevenue
FROM Orders O
JOIN Customers C ON C.CustomerId = O.CustomerId
JOIN Regions R ON R.RegionID = C.RegionID
JOIN Orderdetails OD ON OD.OrderID = O.OrderID
JOIN Products P ON P.ProductId = OD.ProductID
GROUP BY RegionName
ORDER BY TotalRevenue DESC;

-- Return & Refund Insights
-- What is the overall return rate by product category?
SELECT Category,
		ROUND (SUM(CASE WHEN IsReturned = 1 THEN 1 ELSE 0 END) / COUNT(O.OrderId), 2) AS ReturnRate
FROM orders O
JOIN Orderdetails OD ON OD.OrderId = O.OrderId
JOIN Products P ON P.ProductId = OD. ProductId
GROUP BY Category
ORDER BY ReturnRate DESC;

-- What is the overall return rate by region?
SELECT RegionName,
		ROUND (SUM(CASE WHEN IsReturned = 1 THEN 1 ELSE 0 END) / COUNT(O.OrderId), 2) AS ReturnRate
FROM orders O
JOIN customers C ON C.CustomerID = O.CustomerID
JOIN Regions R ON R.RegionID = C.RegionID
GROUP BY RegionName
ORDER BY ReturnRate DESC;

-- Which customers are making frequent returns?
SELECT C.CustomerID, CustomerName, COUNT(O.OrderID) AS ReturnCount
FROM Orders O
JOIN Customers C ON C.CustomerId = O.CustomerId
WHERE IsReturned = 1
GROUP BY C. CustomerID, CustomerName
ORDER BY ReturnCount DESC
LIMIT 10;
