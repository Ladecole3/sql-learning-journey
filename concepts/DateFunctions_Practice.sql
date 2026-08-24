-- 1
SELECT
GETDATE() AS today;

-- 2
SELECT 
	OrderID,
	YEAR(OrderDate) year,
	MONTH(OrderDate) month,
	DAY(OrderDate) day
FROM
	Sales.Orders;

-- 3
SELECT 
	OrderID,
	DATENAME(month, OrderDate) month
FROM
	Sales.Orders;

-- 4
SELECT 
	OrderID,
	DATENAME(weekday, OrderDate) weekday
FROM
	Sales.Orders;

-- 5
SELECT 
	OrderID,
	DATEPART(quarter, OrderDate) Q
FROM
	Sales.Orders;

-- 6
SELECT 
	OrderID,
	DATEPART(month, CreationTime) monthNumber
FROM
	Sales.Orders;

-- 7
SELECT 
	OrderID,
	DATEPART(day, CreationTime) weekday
FROM
	Sales.Orders;

-- 8
SELECT 
	OrderID,
	OrderDate,
	DATETRUNC(month, OrderDate) firstday
FROM
	Sales.Orders;

-- 9
SELECT 
	OrderID,
	OrderDate,
	DATETRUNC(year, OrderDate) firstday
FROM
	Sales.Orders;

-- 10
SELECT 
	OrderID,
	OrderDate,
	YEAR(OrderDate) year,
	DATENAME(month,OrderDate) month,
	DATENAME(weekday, OrderDate) weekday,
	DATEPART(quarter, OrderDate) Q,
	DATETRUNC(month, OrderDate) firstday
FROM
	Sales.Orders;

-- Date Functions WITH Aggregations and Filtering

-- Orders by Month
SELECT
	MONTH(OrderDate) AS month_number,
	COUNT(OrderID) AS number_of_orders
FROM
	Sales.Orders
GROUP BY MONTH(OrderDate)
ORDER BY month_number;

-- Monthly Sales, Sorted Chronologically
SELECT
    MONTH(OrderDate) AS month_number,
    DATENAME(MONTH, OrderDate) AS month_name,
    SUM(Sales) AS total_sales
FROM Sales.Orders
GROUP BY
    MONTH(OrderDate),
    DATENAME(MONTH, OrderDate)
ORDER BY month_number;

-- Orders by Weekday
SELECT
	DATENAME(weekday, OrderDate) AS weekday_name,
	COUNT(OrderID) AS number_of_orders
FROM
	Sales.Orders
GROUP BY 
	DATEPART(weekday,OrderDate),
	DATENAME(weekday, OrderDate)
ORDER BY DATEPART(weekday,OrderDate) ;

-- First Quarter Analysis
SELECT
	MONTH(OrderDate) AS month_number,
	SUM(Quantity) AS total_quantity,
	SUM(Sales) AS total_sales
FROM Sales.Orders
WHERE DATEPART(quarter, OrderDate) = 1
GROUP BY MONTH(OrderDate)
;

-- February Orders
SELECT
	OrderID,
	OrderDate,
	CustomerID,
	Quantity,
	Sales
FROM Sales.Orders
WHERE DATENAME(month,OrderDate) = 'February'
	AND YEAR(OrderDate) = 2025;

-- Monthly Order Performance
SELECT
	DATENAME(month,OrderDate) AS month_name,
	COUNT(OrderID) number_of_orders,
	SUM(Quantity) AS total_quantity_sold,
	SUM(Sales) AS total_sales,
	AVG(Sales) AS avg_sales
FROM Sales.Orders
GROUP BY 
	MONTH(OrderDate),
	DATENAME(month,OrderDate)
;

-- Highest-Selling Month
SELECT TOP 1
	DATENAME(month,OrderDate) AS month_name,
	SUM(Sales) AS total_sales
FROM Sales.Orders
GROUP BY DATENAME(month,OrderDate)
ORDER BY total_sales DESC 
;

-- Shipping Performance
SELECT
	OrderID,
	OrderDate,
	ShipDate,
	DATEDIFF(day, OrderDate, ShipDate) AS ShippingDays
FROM Sales.Orders;

-- Average Shipping Time by Month
SELECT
	DATENAME(month, ShipDate) MonthName,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShippingDays
FROM Sales.Orders
GROUP BY 
	MONTH(Shipdate),
	DATENAME(month, ShipDate)
ORDER BY MONTH(ShipDate);

-- Delayed Orders: an order is delayed if it takes more than 7 days to ship.
SELECT
	OrderID,
	OrderDate,
	ShipDate,
	ShippingDays,
	OrderStatus
FROM (
	SELECT
	OrderID,
	OrderDate,
	ShipDate,
	DATEDIFF(day, OrderDate, ShipDate) AS ShippingDays,
	(CASE 
		WHEN DATEDIFF(day, OrderDate, ShipDate) > 7 THEN 'Delayed'
		ELSE 'On Time' END) AS OrderStatus
FROM Sales.Orders) AS TempTable
WHERE OrderStatus = 'Delayed';

-- Monthly Sales Performance
SELECT
	DATENAME(month, OrderDate) MonthName,
	COUNT(OrderID) AS TotalOrders,
	SUM(quantity) AS TotalQuantities,
	SUM(Sales) AS TotalSales,
	AVG(Sales) AS AvgSales
FROM Sales.Orders
GROUP BY 
	MONTH(Orderdate),
	DATENAME(month, OrderDate)
ORDER BY MONTH(OrderDate);

-- Order Activity by Day of the Week
SELECT
	DATENAME(weekday, OrderDate) Weekday,
	COUNT(OrderID) AS TotalOrders
FROM Sales.Orders
GROUP BY 
	DATEPART(weekday,Orderdate),
	DATENAME(weekday, OrderDate)
ORDER BY DATEPART(weekday,Orderdate);

-- Order Creation vs Order Date: identifying orders where the order record was created on a different calendar day from the actual order date.
SELECT
	OrderID,
	OrderDate,
	CreationTime,
	DATEDIFF(day,OrderDate, CreationTime) DayDifference
FROM Sales.Orders
WHERE DATEDIFF(day, OrderDate, CreationTime) <> 0;

-- Quarterly Sales Analysis

SELECT
	DATENAME(quarter, OrderDate) Quarter,
	COUNT(OrderID) AS TotalOrders,
	SUM(quantity) AS TotalQuantities,
	SUM(Sales) AS TotalSales,
	AVG(Sales) AS AvgSales
FROM Sales.Orders
GROUP BY 
	DATEPART(quarter, Orderdate),
	DATENAME(quarter, OrderDate)
ORDER BY DATEPART(quarter, Orderdate);

-- February 2025 Performance

SELECT
	DATENAME(Month, OrderDate) Month,
	COUNT(OrderID) AS TotalOrders,
	SUM(quantity) AS TotalQuantities,
	SUM(Sales) AS TotalSales,
	AVG(Sales) AS AvgSales,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShippingDays

FROM Sales.Orders
WHERE YEAR(OrderDate) = 2025
  AND MONTH(OrderDate) = 2
GROUP BY DATENAME(Month, OrderDate);

-- Orders Created Outside Business Hours: orders that were created before 8:00 AM or after 6:00 PM

SELECT
    OrderID,
    CreationTime,
    CAST(CreationTime AS TIME(0)) AS TimeOfCreation,
    DATEPART(hour, CreationTime) AS HourOfCreation
FROM Sales.Orders
WHERE DATEPART(hour, CreationTime) < 8
   OR DATEPART(hour, CreationTime) > 18;

-- Management's Monthly Performance Report

SELECT
	DATENAME(month, OrderDate) MonthName,
	COUNT(OrderID) AS TotalOrders,
	SUM(quantity) AS TotalQuantities,
	SUM(Sales) AS TotalSales,
	AVG(Sales) AS AvgSales,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShippingDays,
	COUNT(
		CASE
			WHEN DATEDIFF(day, OrderDate, ShipDate) > 7
			THEN OrderID
		END
	) AS NoOfDelayedOrders

FROM Sales.Orders

GROUP BY 
	DATEPART(month, OrderDate),
	DATENAME(month, OrderDate);



















