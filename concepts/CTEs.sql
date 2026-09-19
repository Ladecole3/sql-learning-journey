
-- Customer Sales Performance
WITH CustomerSales AS (
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders 
    GROUP BY CustomerID
)

SELECT
    CustomerID,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) CustomerRank
FROM CustomerSales

-- Monthly Sales Report
WITH MonthlySalesSummary AS (
    SELECT
        MONTH(Orderdate) MonthNumber,
        DATENAME(month, Orderdate) MonthName,
        COUNT(OrderID) NumberOfOrders,
        SUM(Quantity) TotalQty,
        SUM(Sales) TotalSales,
        AVG(Sales) AvglSales
    FROM Sales.Orders
    GROUP BY
        YEAR(Orderdate),
        MONTH(Orderdate),
        DATENAME(month, Orderdate)
    )

SELECT
    *,
    RANK() OVER (ORDER BY TotalSales DESC) SalesRank
FROM MonthlySalesSummary
ORDER BY MonthNumber;


-- Customer Performance Classification
WITH CustomerSummary AS(
    SELECT
        CustomerID,
        COUNT(OrderID) TotalOrders,
        SUM(Quantity) TotalQty,
        SUM(Sales) TotalSales,
        AVG(Sales) AvgOrderValue
    FROM Sales.Orders
    GROUP BY CustomerID
)
, CustRankSeg AS(
    SELECT
        CustomerID,
        RANK() OVER (ORDER BY TotalSales DESC) SalesRank,
        CASE WHEN TotalSales >= 100 THEN 'High value'
             WHEN TotalSales BETWEEN 50 AND 99 THEN 'Medium Value'
             ELSE 'Low Value' 
             END AS CustomerCategory
    FROM CustomerSummary
)

SELECT 
    cs.CustomerID,
    cs.TotalOrders,
    cs.TotalQty,
    cs.TotalSales,
    cs.AvgOrderValue,
    crs.SalesRank,
    crs.CustomerCategory
FROM CustomerSummary cs
INNER JOIN CustRankSeg  crs
    ON cs.CustomerID = crs.CustomerID
WHERE CustomerCategory IN ('High value', 'Medium Value')
ORDER BY TotalSales DESC;


-- Customer Purchase Trend

WITH CustPrevOrderSales AS (
    SELECT
        OrderID,
        CustomerID,
        Orderdate,
        Sales,
        LAG(Sales) OVER( PARTITION BY CustomerID ORDER BY Orderdate) PreviousOrderSale

    FROM Sales.Orders
)

SELECT
    *,
    Sales - PreviousOrderSale AS SalesDifference,
    CASE WHEN PreviousOrderSale IS NULL THEN 'First Order'
         WHEN Sales > PreviousOrderSale THEN 'Increased'
         WHEN Sales < PreviousOrderSale THEN 'Decreased'
         ELSE THEN 'Equal'
         END AS SalesTrend
FROM CustPrevOrderSales
ORDER BY 
    CustomerID,
    Orderdate

/*Customer Repeat-Purchase : Order count, first/most recent order dates, 
days between, total sales, and New vs. Returning status per customer*/

WITH CustomerOrderHistory AS (
    SELECT
        CustomerID,
        COUNT(OrderID) TotalOrders,
        MIN(Orderdate) FirstOrderDate,
        MAX(Orderdate) LastOrderDate,
        SUM(Sales) TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
    
), CustomerAnalysis AS (
    SELECT
        *,
        DATEDIFF(day, FirstOrderDate, LastOrderDate) DaysAsCustomer,
        CASE WHEN TotalOrders = 1 THEN 'New Customer'
             WHEN TotalOrders > 1 THEN 'Returning Customer'
             END AS CustomerType
    FROM CustomerOrderHistory
)

SELECT
    *
FROM CustomerAnalysis
WHERE CustomerType = 'Returning Customer'
ORDER BY DaysAsCustomer DESC;






