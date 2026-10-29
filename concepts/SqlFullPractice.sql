
-- PART 1 - BUSINESS FUNDAMENTALS

-- Product Catalog: Active products with price > 0 — return name, product number, color, list price, subcategory, category

SELECT
	p.Name AS ProductName,
	p.ProductNumber,
	p.Color,
	p.ListPrice,
	ps.Name AS ProductSubcategory,
	pc.Name AS ProductCategory

FROM Production.Product AS p

JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID

JOIN Production.ProductCategory AS pc
    ON ps.ProductCategoryID = pc.ProductCategoryID

WHERE p.ListPrice > 0;


-- Product Pricing: Products priced above the average list price — return name, product number, list price

SELECT
	Name AS ProductName,
	ProductNumber,
	ListPrice
FROM Production.Product
WHERE ListPrice > (
					SELECT AVG(ListPrice)
					FROM Production.Product
					);


-- Customer Overview: Count of customers grouped by customer type
SELECT 
	pp.PersonType AS CustomerType,
	COUNT(DISTINCT CustomerID) AS NumberOfCustomers
FROM Sales.Customer sc
JOIN Person.Person pp
	ON sc.CustomerID = pp.BusinessEntityID
GROUP BY pp.PersonType;

-- Product Categories: Count of products per category, sorted highest to lowest

SELECT
	pc.Name AS ProductCategory,
	COUNT(p.ProductID) AS NumberOfProducts
	
FROM Production.Product AS p

JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID

JOIN Production.ProductCategory AS pc
    ON ps.ProductCategoryID = pc.ProductCategoryID

GROUP BY pc.Name
ORDER BY NumberOfProducts DESC;

/* Price Classification: Products labeled Budget (<$100), 
Mid-Range ($100–$500), or Premium (>$500) — return name, list price, classification*/

SELECT
	Name AS ProductName,
	ListPrice,
	(CASE WHEN ListPrice >500 THEN 'Premium'
		  WHEN ListPrice BETWEEN 100 AND 500 THEN 'Mid-Range'
		  ELSE 'Budget' 
		  END ) AS Classification
	
FROM Production.Product
WHERE ListPrice > 0;


-- PART 2 — SALES & CUSTOMERS

-- Customer Spending: Total sales per customer, sorted highest to lowest — return customer ID, name, total sales

SELECT
	c.CustomerID,
	CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
	ROUND(SUM(sod.LineTotal), 2) AS TotalSales

FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.Customer c
	ON soh.CustomerID = c.CustomerID
JOIN Person.Person p
	ON c.CustomerID = p.BusinessEntityID

GROUP BY c.CustomerID, p.Firstname,p.LastName
ORDER BY TotalSales DESC;

-- High-Value Customers: Customers with total spending > $10,000 — return name, total spending

SELECT
	CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
	ROUND(SUM(sod.LineTotal), 2) AS TotalSpending

FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.Customer c
	ON soh.CustomerID = c.CustomerID
JOIN Person.Person p
	ON c.CustomerID = p.BusinessEntityID

GROUP BY c.CustomerID, p.Firstname, p.LastName
HAVING SUM(sod.LineTotal) > 10000
ORDER BY TotalSpending DESC;

-- Sales by Product Category: Total sales per category, ranked highest to lowest revenue

SELECT
	pc.Name AS ProductCategory,
	ROUND(SUM(sod.LineTotal), 2) AS TotalSales

FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc
    ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Sales.SalesOrderDetail sod
	ON sod.ProductID = p.ProductID

GROUP BY pc.Name
ORDER BY TotalSales DESC;

-- Sales by Year: Total sales and order count per year — return year, total sales, order count

SELECT
	YEAR(soh.OrderDate) AS Year,
	ROUND(SUM(sod.LineTotal), 2) AS TotalSales,
	COUNT(DISTINCT soh.SalesOrderID) AS OrderCount

FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID

GROUP BY YEAR(soh.OrderDate)
ORDER BY Year;


-- Top Products: Top 10 products by total sales — return name, total quantity sold, total sales

SELECT TOP 10
	p.Name AS ProductName,
	SUM(sod.OrderQty) AS TotalQty,
	ROUND(SUM(sod.LineTotal), 2) AS TotalSales

FROM Production.Product AS p
JOIN Sales.SalesOrderDetail sod
	ON p.ProductID = sod.ProductID

GROUP BY 
	p.ProductID, 
	p.Name
ORDER BY 
	TotalSales DESC;

-- PART 3 - DATES & TIMES ANALYSIS

-- Monthly Sales: Total sales and order count by year and month — return year, month, total sales, order count

SELECT
    YEAR(soh.OrderDate) AS Year,
    DATENAME(MONTH, soh.OrderDate) AS Month,
    ROUND(SUM(sod.LineTotal), 2) AS TotalSales,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount

FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh
    ON sod.SalesOrderID = soh.SalesOrderID

GROUP BY
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate),
    DATENAME(MONTH, soh.OrderDate)

ORDER BY
    Year,
    MONTH(soh.OrderDate);

-- Order Processing: Average days between order date and ship date, grouped by year

SELECT
	YEAR(OrderDate) AS Year,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShippingDays
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY Year;

/* Orders with days-to-ship, flagged On Time (≤7 days) or Delayed (>7 days) — 
	return order ID, order date, ship date, days taken, Shipping status*/

SELECT
    SalesOrderID,
    OrderDate,
    ShipDate,
    DATEDIFF(day, OrderDate, ShipDate) AS ShippingDays,
    CASE 
        WHEN DATEDIFF(day, OrderDate, ShipDate) > 7 THEN 'Delayed'
        ELSE 'On-Time'
    END AS ShippingStatus
FROM Sales.SalesOrderHeader
WHERE DATEDIFF(day, OrderDate, ShipDate) > 7;

-- Weekend Orders: Count of orders by day of the week

SELECT
    DATENAME(Weekday, OrderDate) Weekday,
	COUNT(DISTINCT SalesOrderID) AS OrderCount

FROM Sales.SalesOrderHeader

GROUP BY 
	DATEPART(Weekday,OrderDate),
	DATENAME(Weekday, OrderDate)

ORDER BY DATEPART(Weekday,OrderDate);


-- PART 4 - SUBQUERY THINKING

/* Category Price Outliers: Products priced above the average list price 
within their own category — return category, product, list price */

SELECT
	ProductCategory,
	ProductName,
	ListPrice
FROM (
	SELECT
		pc.Name AS ProductCategory,
		p.Name AS ProductName,
		p.ListPrice,
		AVG(ListPrice) OVER( PARTITION BY pc.ProductCategoryID )  AS ProductAvgPrice
	FROM Production.Product AS p
	JOIN Production.ProductSubcategory AS ps
		ON p.ProductSubcategoryID = ps.ProductSubcategoryID
	JOIN Production.ProductCategory AS pc
		ON ps.ProductCategoryID = pc.ProductCategoryID
	) CategorySummary
WHERE ListPrice > ProductAvgPrice;

/*  Above-Average Order Frequency: Customers with more orders than the 
	average per customer — return customer ID, name, order count */
SELECT
    *
FROM (
    SELECT
        soh.CustomerID,
        CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
        COUNT(SalesOrderID) AS OrderCount
    FROM Sales.SalesOrderHeader soh
    JOIN Person.Person p
        ON soh.CustomerID = p.BusinessEntityID
    GROUP BY 
        soh.CustomerID,
        p.FirstName,
        p.LastName
) t
WHERE OrderCount > (
    SELECT AVG(OrderCount)
    FROM (
        SELECT
            CustomerID,
            COUNT(SalesOrderID) AS OrderCount
        FROM Sales.SalesOrderHeader
        GROUP BY CustomerID
    ) t2
);

-- Never Purchased: Customers with zero orders — return customer ID, name
SELECT
    c.CustomerID,
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName
FROM Sales.Customer c
LEFT JOIN Person.Person p
    ON c.CustomerID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh
    ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL;

-- Top Product Per Category: Highest-priced product in each category — return category, product, list price
SELECT
	Productcategory,
	ProductName,
	ListPrice
FROM (
	SELECT
		pc.Name AS ProductCategory,
		p.Name AS  ProductName,
		p.ListPrice AS ListPrice,
		MAX(ListPrice) OVER(PARTITION BY pc.Name) MaxPricePerCategory
	FROM Production.Product AS p
	JOIN Production.ProductSubcategory AS ps
		ON p.ProductSubcategoryID = ps.ProductSubcategoryID
	JOIN Production.ProductCategory AS pc
		ON ps.ProductCategoryID = pc.ProductCategoryID
		) t 
WHERE ListPrice = MaxPricePerCategory;

-- PART 5 - ADVANCED JOINS AND BUSINESS LOGIC

-- Salesperson Performance: Total sales and order count per salesperson, sorted by sales descending

SELECT
	soh.SalesPersonID AS SalesPerson,
	SUM(sod.LineTotal) AS TotalSales,
	COUNT(DISTINCT soh.SalesOrderID) AS OrderCount
FROM Sales.SalesPerson sp
JOIN Sales.SalesOrderHeader soh
	ON sp.BusinessEntityID = soh.SalesPersonID
JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesPersonID
ORDER BY TotalSales DESC;
	

-- Territory Performance: Total sales by territory and country/region, highlighting the top-performing territory
SELECT
	st.Name AS Territory,
	st.CountryRegionCode AS CountryRegionCode,
	SUM(sod.LineTotal) AS TotalSales

FROM Sales.SalesTerritory st
JOIN Sales.SalesOrderHeader soh
	ON st.TerritoryID = soh.TerritoryID
JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID = sod.SalesOrderID

GROUP BY 
	st.Name,
	st.CountryRegionCode
ORDER BY TotalSales DESC;

-- Customer's Most Recent Order: Latest order per customer — return customer, order ID, order date, order total
SELECT
	*
FROM (
		SELECT
			CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
			sod.SalesOrderID AS OrderID,
			soh.OrderDate AS OrderDate,
			SUM(sod.LineTotal) AS OrderTotal,
			MAX(soh.OrderDate) OVER(PARTITION BY c.CustomerID) LatestOrderDate
		FROM Sales.SalesOrderDetail sod
		JOIN Sales.SalesOrderHeader soh
			ON sod.SalesOrderID = soh.SalesOrderID
		JOIN Sales.Customer c
			ON soh.CustomerID = c.CustomerID
		JOIN Person.Person p
			ON c.CustomerID = p.BusinessEntityID

		GROUP BY
			c.CustomerID,
			p.FirstName,
			p.LastName,
			sod.SalesOrderID,
			soh.OrderDate
		) t
WHERE OrderDate = LatestOrderDate;

-- PART 6 - WINDOW FUNCTIONS

/* Rank Products Within Categories: Products ranked by total sales within 
each category (1 = top seller) — return category, product, total sales, rank*/
SELECT
	*,
	RANK() OVER(PARTITION BY ProductCategory ORDER BY TotalSales DESC) AS Rank
FROM(
	SELECT
		pc.Name AS ProductCategory,
		p.Name As Product,
		SUM(sod.LineTotal) AS TotalSales
	FROM Production.Product AS p
		JOIN Production.ProductSubcategory AS ps
			ON p.ProductSubcategoryID = ps.ProductSubcategoryID
		JOIN Production.ProductCategory AS pc
			ON ps.ProductCategoryID = pc.ProductCategoryID
		JOIN Sales.SalesOrderDetail sod
			ON p.ProductID = sod.ProductID
	GROUP BY 
		pc.Name,
		p.Name
	) t;


/* Running Sales Total: Cumulative monthly sales within each 
year (resets annually) — return year, month, monthly sales, running total*/

SELECT
	*,
	SUM(MonthlySales) OVER(
						PARTITION BY Year ORDER BY Month) AS RunningTotal
FROM(
	SELECT
		YEAR(soh.OrderDate) Year,
		MONTH(soh.OrderDate) Month,
		SUM(sod.LineTotal) MonthlySales

	FROM Sales.SalesOrderDetail sod
	JOIN Sales.SalesOrderHeader soh
		ON sod.SalesOrderID = soh.SalesOrderID

	GROUP BY
		YEAR(soh.OrderDate),
		MONTH(soh.OrderDate)
	) t;


/* Month-over-Month Comparison: Monthly sales vs. previous month, with the difference — return year, 
month, monthly sales, previous month sales, difference*/

SELECT
	*,
	MonthlySales - PrevMonthSales AS Difference
FROM(
	SELECT
		YEAR(soh.OrderDate) Year,
		MONTH(soh.OrderDate) Month,
		SUM(sod.LineTotal) MonthlySales,
		LAG(SUM(sod.LineTotal))OVER(
								PARTITION BY YEAR(soh.OrderDate)  
								ORDER BY MONTH(soh.OrderDate)) AS PrevMonthSales
	FROM Sales.SalesOrderDetail sod
	JOIN Sales.SalesOrderHeader soh
		ON sod.SalesOrderID = soh.SalesOrderID

	GROUP BY
		YEAR(soh.OrderDate),
		MONTH(soh.OrderDate)
	) t;


/*Customer Purchase Sequence: Order history per repeat customer with 
sequence number, previous order date, and days since last order — return name, 
order ID, order date, sequence, previous order date, days since previous order*/

SELECT
	*,
	DATEDIFF(day, OrderDate, PreviousOrderDate) DaysDiff
FROM(
		SELECT
			CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
			soh.SalesOrderID AS OrderID,
			soh.OrderDate AS OrderDate,
			ROW_NUMBER() OVER(
							PARTITION BY c.CustomerID
							ORDER BY soh.OrderDate) AS Sequence,
			LAG(soh.OrderDate) OVER (
							PARTITION BY c.CustomerID
							ORDER BY soh.OrderDate ) PreviousOrderDate
		FROM Sales.SalesOrderHeader soh
				JOIN Sales.Customer c
					ON soh.CustomerID = c.CustomerID
				JOIN Person.Person p
					ON c.CustomerID = p.BusinessEntityID
			) t










