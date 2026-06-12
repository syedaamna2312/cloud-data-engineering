-- ================================================================================
-- INTERVIEW PREP: BikeStores Database - 15 Beginner-Friendly Questions
-- Focus: Basic SELECT, WHERE, JOIN, GROUP BY, Simple Window Functions
-- Difficulty: Beginner to Lower-Intermediate
-- ================================================================================

-- ================================================================================
-- QUESTION 1: Basic SELECT (Beginner)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Show all products from the production.products table.
--  Display only: product_name, model_year, list_price.
--  Order by list_price from highest to lowest."
------------------------------------------------

-- ================================================================================

SELECT
product_name,
model_year,
list_price
FROM production.products
ORDER BY list_price DESC;

-- ================================================================================
-- QUESTION 2: Filtering with WHERE (Beginner)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Find all customers who live in New York (state = 'NY').
--  Show their first name, last name, city, and state."
-------------------------------------------------------

-- ================================================================================

SELECT
first_name,
last_name,
city,
state
FROM sales.customers
WHERE state = 'NY';

-- ================================================================================
-- QUESTION 3: Simple JOIN (Beginner)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Show all orders with customer names.
--  Display: order_id, order_date, customer first name, customer last name.
--  Order by order_date (newest first)."
----------------------------------------

-- ================================================================================

SELECT
o.order_id,
o.order_date,
c.first_name,
c.last_name
FROM sales.orders o
INNER JOIN sales.customers c
ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- ================================================================================
-- QUESTION 4: Basic GROUP BY with COUNT (Beginner)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Count how many customers are in each state.
--  Show state name and number of customers.
--  Order by customer count from highest to lowest."
----------------------------------------------------

-- ================================================================================

SELECT
state,
COUNT(*) AS customer_count
FROM sales.customers
GROUP BY state
ORDER BY customer_count DESC;

-- ================================================================================
-- QUESTION 5: GROUP BY with SUM (Beginner-Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Calculate total sales amount for each store.
--  Show store_name and total_sales.
--  (Hint: sales_amount = quantity * list_price * (1 - discount))"
------------------------------------------------------------------

-- ================================================================================

SELECT
s.store_name,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM sales.stores s
INNER JOIN sales.orders o
ON s.store_id = o.store_id
INNER JOIN sales.order_items oi
ON o.order_id = oi.order_id
GROUP BY s.store_name;

-- ================================================================================
-- QUESTION 6: GROUP BY with AVG and HAVING (Beginner-Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Find brands that have an average product price greater than $2000.
--  Show brand_name and average_price.
--  Only include brands with at least 3 products."
--------------------------------------------------

-- ================================================================================

SELECT
b.brand_name,
AVG(p.list_price) AS average_price
FROM production.brands b
INNER JOIN production.products p
ON b.brand_id = p.brand_id
GROUP BY b.brand_name
HAVING AVG(p.list_price) > 2000
AND COUNT(*) >= 3;

-- ================================================================================
-- QUESTION 7: Basic Window Function - ROW_NUMBER() (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Number all products from cheapest to most expensive.
--  Show product_name, list_price, and a row number column called 'price_rank'.
--  Cheapest product should be number 1."
-----------------------------------------

-- ================================================================================

SELECT
product_name,
list_price,
ROW_NUMBER() OVER(ORDER BY list_price ASC) AS price_rank
FROM production.products;

-- ================================================================================
-- QUESTION 8: ROW_NUMBER() with PARTITION BY (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "For each brand, number the products by price (most expensive first).
--  Show brand_name, product_name, list_price, and rank within brand.
--  The most expensive product in each brand should be number 1."
-----------------------------------------------------------------

-- ================================================================================

SELECT
b.brand_name,
p.product_name,
p.list_price,
ROW_NUMBER() OVER
(
PARTITION BY p.brand_id
ORDER BY p.list_price DESC
) AS rank_in_brand
FROM production.products p
INNER JOIN production.brands b
ON p.brand_id = b.brand_id;

-- ================================================================================
-- QUESTION 9: Basic Running Total with SUM() OVER() (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Calculate a running total of daily orders.
--  Show order_date, number of orders on that date,
--  and cumulative total of orders so far.
--  Order by order_date."
-------------------------

-- ================================================================================

WITH DailyOrders AS
(
SELECT
order_date,
COUNT(*) AS daily_order_count
FROM sales.orders
GROUP BY order_date
)
SELECT
order_date,
daily_order_count,
SUM(daily_order_count) OVER(ORDER BY order_date) AS cumulative_total
FROM DailyOrders;

-- ================================================================================
-- QUESTION 10: RANK() vs ROW_NUMBER() (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Use both ROW_NUMBER() and RANK() on products ordered by list_price DESC.
--  Show product_name, list_price, row_number, and rank.
--  What difference do you notice when there are ties?"
-------------------------------------------------------

-- ================================================================================

SELECT
product_name,
list_price,
ROW_NUMBER() OVER(ORDER BY list_price DESC) AS row_number,
RANK() OVER(ORDER BY list_price DESC) AS rank_number
FROM production.products;

-- Difference:
-- ROW_NUMBER() always gives unique numbers.
-- RANK() gives the same rank to tied values and skips numbers afterward.

-- ================================================================================
-- QUESTION 11: Multiple JOINs (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Show all order items with product and order information.
--  Display: order_id, order_date, product_name, quantity, list_price.
--  Only show orders from 2023."
--------------------------------

-- ================================================================================

SELECT
o.order_id,
o.order_date,
p.product_name,
oi.quantity,
oi.list_price
FROM sales.orders o
INNER JOIN sales.order_items oi
ON o.order_id = oi.order_id
INNER JOIN production.products p
ON oi.product_id = p.product_id
WHERE YEAR(o.order_date) = 2023;

-- ================================================================================
-- QUESTION 12: Basic CASE Statement (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Categorize products by price:
--    Under $500 = 'Budget'
--    $500 to $2000 = 'Regular'
--    Over $2000 = 'Premium'
--  Show product_name, list_price, and price_category."
-------------------------------------------------------

-- ================================================================================

SELECT
product_name,
list_price,
CASE
WHEN list_price < 500 THEN 'Budget'
WHEN list_price BETWEEN 500 AND 2000 THEN 'Regular'
ELSE 'Premium'
END AS price_category
FROM production.products;

-- ================================================================================
-- QUESTION 13: LAG() - Previous Row Access (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "For each customer, show their order date and the date of their previous order.
--  Display: customer_id, order_id, order_date, previous_order_date.
--  If no previous order, show NULL."
-------------------------------------

-- ================================================================================

SELECT
customer_id,
order_id,
order_date,
LAG(order_date) OVER
(
PARTITION BY customer_id
ORDER BY order_date
) AS previous_order_date
FROM sales.orders;

-- ================================================================================
-- QUESTION 14: Finding Top N with Window Function (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Find the top 3 most expensive products in each category.
--  Show category_name, product_name, list_price, and rank.
--  Use RANK() for ranking."
----------------------------

-- ================================================================================

WITH RankedProducts AS
(
SELECT
c.category_name,
p.product_name,
p.list_price,
RANK() OVER
(
PARTITION BY p.category_id
ORDER BY p.list_price DESC
) AS product_rank
FROM production.products p
INNER JOIN production.categories c
ON p.category_id = c.category_id
)
SELECT *
FROM RankedProducts
WHERE product_rank <= 3;

-- ================================================================================
-- QUESTION 15: Combined Query - Everything Learned (Intermediate)
-- ================================================================================
-----------------------------------------------------------------------------------

-- "Create a report showing:
--    1. Customer name
--    2. Total amount spent by that customer
--    3. Customer's rank by spending (1 = highest spender)
--    4. Price tier of customer (VIP if spent > $5000, Regular if $1000-$5000, New if < $1000)
--  Order by rank."
-------------------

-- ================================================================================

WITH CustomerSpending AS
(
SELECT
c.customer_id,
c.first_name + ' ' + c.last_name AS customer_name,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items oi
ON o.order_id = oi.order_id
GROUP BY
c.customer_id,
c.first_name,
c.last_name
)
SELECT
customer_name,
total_spent,
RANK() OVER(ORDER BY total_spent DESC) AS spending_rank,
CASE
WHEN total_spent > 5000 THEN 'VIP'
WHEN total_spent BETWEEN 1000 AND 5000 THEN 'Regular'
ELSE 'New'
END AS customer_tier
FROM CustomerSpending
ORDER BY spending_rank;

-- ================================================================================
-- END OF INTERVIEW QUESTIONS
-- ================================================================================
