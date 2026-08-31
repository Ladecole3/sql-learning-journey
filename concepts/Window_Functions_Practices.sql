
-- Aggregating Using Window Functions

-- Customer Sales Contribution

SELECT 
	OrderID,
	CustomerID,
	Sales,
	SUM(Sales) OVER( PARTITION BY CustomerID) TotalSalesByCustomer
FROM Sales.Orders;

-- Monthly Sales vs Overall Sales

SELECT 
	OrderID,
	OrderDate,
	Sales,
	DATENAME(month, OrderDate),
	SUM(Sales) OVER( PARTITION BY MONTH(OrderDate)) TotalSalesByMonth,
	SUM(Sales) OVER() TotalSales
FROM Sales.Orders;


-- Customer Order Analysis
SELECT
	OrderID,
	CustomerID,
	Sales, 
	SUM(Sales) OVER( PARTITION BY CustomerID) TotalSalesPerCustomer,
	COUNT(OrderID) OVER( PARTITION BY CustomerID) TotalOrderPerCustomers,
	AVG(Sales) OVER( PARTITION BY CustomerID) AvgSalesPerCustomer
FROM Sales.Orders;

-- Ranking Window Functions

-- Top Customers by Sales

SELECT
    CustomerID,
    TotalSales,
    ROW_NUMBER() OVER(ORDER BY TotalSales DESC) AS CustomerRank
FROM (
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS CustomerSales;


/* If two salespeople have exactly the same total sales, 
they should receive the same rank.*/

SELECT
    CustomerID,
    TotalSales,
    RANK() OVER(ORDER BY TotalSales DESC) AS CustomerRank
FROM (
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS CustomerSales;

/* If two customers have the same total sales, 
they should receive the same rank, but the next customer 
should receive the next consecutive rank.*/

SELECT
    CustomerID,
    TotalSales,
    DENSE_RANK() OVER(ORDER BY TotalSales DESC) AS CustomerRank
FROM (
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS CustomerSales;


/* Calculate each customer's total sales and divide 
the customers into 4 equally sized groups based 
on their total sales performance. */

SELECT
    CustomerID,
    TotalSales,
    NTILE(4) OVER(ORDER BY TotalSales DESC) AS GroupNo
FROM (
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS CustomerSales;


-- Customer Sales Distribution

/* a. What percentage of customers have total sales less than 
or equal to each customer's sales?*/

/* b. What is each customer's relative position within the sales 
distribution, where the lowest customer is at the bottom and the 
highest customer is at the top?*/

SELECT
    CustomerID,
    TotalSales,
    CUME_DIST() OVER(ORDER BY TotalSales ASC) CumulativeDistribution,
    PERCENT_RANK() OVER(ORDER BY TotalSales ASC)  PercentileRank
FROM (
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS CustomerSales;


-- Value Window Functions

-- Compare Each Order With the Previous Order
SELECT 
*,
Sales - PreviousSale AS SalesDiff
FROM (
    SELECT
        OrderID,
        OrderDate,
        Sales,
        LAG(Sales) OVER(ORDER BY OrderDate) PreviousSale
    FROM Sales.Orders
) AS t


-- Compare Each Order With the Next Order
SELECT 
*,
NextSale - Sales AS SalesDiff
FROM (
    SELECT
        OrderID,
        OrderDate,
        Sales,
        LEAD(Sales) OVER(ORDER BY OrderDate) NextSale
    FROM Sales.Orders
) AS t


-- First Order vs Current Order

SELECT 
*,
Sales - FirstSale AS SalesDiff
FROM (
    SELECT
        OrderID,
        CustomerID,
        OrderDate,
        Sales,
        FIRST_VALUE(Sales) OVER(PARTITION BY CustomerID ORDER BY OrderDate) FirstSale
    FROM Sales.Orders
) AS t


-- Last Order vs Current Order

SELECT 
*,
Sales - LastSale AS SalesDiff
FROM (
    SELECT
        OrderID,
        CustomerID,
        OrderDate,
        Sales,
        LAST_VALUE(Sales) OVER(PARTITION BY CustomerID ORDER BY OrderDate
                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LastSale
    FROM Sales.Orders
) AS t











