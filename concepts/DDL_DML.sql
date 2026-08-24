
/* DDL - Data Definition Language 
   DML - Data Modification Lamguage
 */

-- Create a Table — DDL Command
CREATE TABLE Customers
(
	CustomerID INT NOT NULL,
	CustomerName VARCHAR(50) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	City VARCHAR(50),
	Country VARCHAR(50),
	RegistrationDate DATE NOT NULL,
	CONSTRAINT PK PRIMARY KEY (CustomerID)
)


-- Insert Data — DML Command

INSERT INTO Customers
    (CustomerID, CustomerName, Email, City, Country, RegistrationDate)
VALUES
		(001, 'Ladecole', 'ladecole3@gmail.com', 'Yaounde', 'Cameroon',  '2023-05-23'),
		(002, 'Mubarak', 'mubee26@gmail.com', 'Lagos', 'Nigeria',  '2024-10-03'),
		(003, 'Kole', 'Kole3@gmail.com', 'Oyo', 'Nigeria', '2020-02-01'),
		(004, 'Aishat', 'ashley6@gmail.com', 'New York', 'USA',  '2025-05-13'),
		(005, 'Tanjiro', 'kamado@gmail.com', 'Tokyo', 'Japan', '2023-09-29')


-- Update Records — DML Command
UPDATE Customers	
SET City = 'Kaduna'
WHERE CustomerID = 003

-- Add a Column — DDL Command
ALTER TABLE Customers
ADD MembershipLevel VARCHAR(50)

UPDATE Customers
SET MembershipLevel = 'Bronze'
WHERE CustomerID = 001

UPDATE Customers
SET MembershipLevel = 'Silver'
WHERE CustomerID = 002

UPDATE Customers
SET MembershipLevel = 'Gold'
WHERE CustomerID = 003

UPDATE Customers
SET MembershipLevel = 'Bronze'
WHERE CustomerID = 004

UPDATE Customers
SET MembershipLevel = 'Silver'
WHERE CustomerID = 005

/* Update Multiple Records — DML Command
   Give all customers from a particular country a Gold membership
   */

UPDATE Customers
SET MembershipLevel = 'Gold'
WHERE Country = 'Nigeria'

-- Delete a Record — DML Command
DELETE FROM Customers
WHERE CustomerID = 003






