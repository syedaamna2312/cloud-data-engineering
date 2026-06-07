-- ============================================================
--  HOMEWORK: Indexes & Stored Procedures
--  Topic   : SQL Indexes + Stored Procedures
--  Level   : Beginner to Intermediate
-- ============================================================

-- ============================================================
--  PART A: INDEXES
-- ============================================================

-- Q1.
-- Write a query to create a non-clustered index on the
-- last_name column of sales.customers.
-- Then write a SELECT statement that would benefit from it.
-- Hint: Think about which queries filter by last name.

-- Your answer here:

CREATE NONCLUSTERED INDEX IX_Customers_LastName
ON sales.customers(last_name);

SELECT *
FROM sales.customers
WHERE last_name = 'Brown';

-- Q2.
-- Create a composite index on sales.orders using
-- customer_id and order_date.
-- Write a query that filters on both columns and benefits
-- from this index.
-- Hint: Composite indexes work best when you filter on both columns.

-- Your answer here:

CREATE NONCLUSTERED INDEX IX_Orders_Customer_OrderDate
ON sales.orders(customer_id, order_date);

SELECT *
FROM sales.orders
WHERE customer_id = 10
AND order_date >= '2024-01-01';

-- Q3.
-- A teammate suggests adding a unique index on
-- sales.customers(phone_number).
-- What could go wrong with this?
-- What assumption must be true for this to be safe?
-- Hint: Think about duplicate or missing (NULL) values.

-- Your answer here (write as a comment):

-- A UNIQUE index will fail if duplicate phone numbers already exist.
-- It may also be problematic if multiple customers have NULL phone numbers.
-- It is safe only if every customer has a unique phone number
-- and duplicate values are not allowed.

-- Q4.
-- Look at the columns below from a sales.orders table.
-- Decide which columns SHOULD have an index and which should NOT.
-- Explain your reasoning for each as a comment.
------------------------------------------------

--   order_id     (Primary Key)
--   status       (only 3 values: Pending, Shipped, Delivered)
--   customer_id  (Foreign Key)
--   notes        (free text, rarely searched)

-- Your answer here (write as a comment):

-- order_id:
-- Should have an index because it is the Primary Key.

-- status:
-- Usually should NOT have an index because it contains very few distinct values.

-- customer_id:
-- Should have an index because it is frequently used in joins and searches.

-- notes:
-- Should NOT have a regular index because it is large text and rarely searched.

-- Q5.
-- Write the command to check existing indexes on production.products.
-- Then describe (as a comment) what the output columns tell you.
-- Hint: Use sp_helpindex.

-- Your answer here:

EXEC sp_helpindex 'production.products';

-- index_name:
-- Name of the index.

-- index_description:
-- Type of index (clustered, nonclustered, unique, etc.).

-- index_keys:
-- Columns included in the index.

-- ============================================================
--  PART B: STORED PROCEDURES
-- ============================================================

-- Q6.
-- Create a stored procedure called sp_GetCustomerOrders
-- that accepts a @CustomerID parameter and returns all orders
-- for that customer showing: order_id, order_date, order_status.
-- Test it using EXEC after you create it.

-- Your answer here:

CREATE PROCEDURE sp_GetCustomerOrders
@CustomerID INT
AS
BEGIN
SELECT
order_id,
order_date,
order_status
FROM sales.orders
WHERE customer_id = @CustomerID;
END;
GO

EXEC sp_GetCustomerOrders 10;
GO

-- Q7.
-- Modify sp_GetCustomerOrders from Q6 so that if no orders
-- are found for the given customer, it returns the message:
-- 'No orders found for this customer'
-- Hint: Use IF EXISTS or check @@ROWCOUNT.

-- Your answer here:

ALTER PROCEDURE sp_GetCustomerOrders
@CustomerID INT
AS
BEGIN

```
IF EXISTS
(
    SELECT 1
    FROM sales.orders
    WHERE customer_id = @CustomerID
)
BEGIN
    SELECT
        order_id,
        order_date,
        order_status
    FROM sales.orders
    WHERE customer_id = @CustomerID;
END
ELSE
BEGIN
    PRINT 'No orders found for this customer';
END
```

END;
GO

-- Q8.
-- Create a stored procedure sp_ProductsByCategory that accepts:
--   @CategoryID  INT
--   @MaxPrice    DECIMAL(10,2)  with a default value of 9999
-- It should return all matching products ordered by price (low to high).
-- Hint: Use a default parameter value like you saw with @threshold.

-- Your answer here:

CREATE PROCEDURE sp_ProductsByCategory
@CategoryID INT,
@MaxPrice DECIMAL(10,2) = 9999
AS
BEGIN

```
SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE category_id = @CategoryID
  AND list_price <= @MaxPrice
ORDER BY list_price ASC;
```

END;
GO

EXEC sp_ProductsByCategory 1;
GO

-- ============================================================
--  PART C: MIXED / THINK QUESTIONS
-- ============================================================

-- Q9.
-- You have a sales.orders table with 2 million rows.
-- A stored procedure filters by store_id and order_date.
-- It runs very slowly.
-- What TWO things would you do to fix it, and why?
-- Hint: Think about both indexes and procedure logic.

-- Your answer here (write as a comment):

-- 1. Create an index on store_id and order_date to speed up filtering.
-- 2. Review the stored procedure and avoid unnecessary SELECT *,
--    joins, or calculations so SQL Server processes fewer rows.

-- Q10.
-- A junior developer creates indexes on EVERY column of a table
-- to "make everything faster".
-- Write a short explanation (3-5 sentences) of why this is
-- actually a bad idea.
-- Hint: Think about how INSERT, UPDATE, and DELETE are affected.

-- Your answer here (write as a comment):

-- Creating indexes on every column is usually a bad idea.
-- Each index consumes disk space and memory.
-- INSERT, UPDATE, and DELETE operations become slower because
-- SQL Server must update every index whenever data changes.
-- Too many indexes can also confuse the optimizer and increase
-- maintenance costs.
-- Indexes should only be created on columns that are frequently
-- used in searches, joins, sorting, or filtering.

-- ============================================================
--  END OF HOMEWORK
-- ============================================================
