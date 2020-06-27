-- Ex 1
SELECT *
FROM order_items
ORDER BY id
LIMIT 100;



-- Ex 2 + 3
-- Here we get a daily count of orders placed
SELECT DATE(ordered_at), COUNT(*)
FROM orders
GROUP BY 1
ORDER BY 1;



-- Ex 4a
-- Here we get the daily revenue (from orders)
SELECT
    DATE(ordered_at) AS order_date,
    ROUND(SUM(amount_paid), 2) AS daily_revenue
FROM orders
JOIN order_items on 
      orders.id = order_items.order_id
GROUP BY 1
ORDER BY 1;

-- Ex 4b
-- Here, we add to 4a by finding out daily revenue from kale smoothie orders
SELECT
    DATE(ordered_at) AS order_date,
    ROUND(SUM(amount_paid), 2) AS daily_revenue
FROM orders
JOIN order_items on 
      orders.id = order_items.order_id
WHERE name = 'kale-smoothie'
GROUP BY 1
ORDER BY 1;



-- Ex 6
-- Smoothies aren't doing well, but let's compare them to the other order items
-- So let's get the % of revenue that each item represents
-- Here, we first SUM the products by price to get total revenue for each item.
SELECT name, ROUND(SUM(amount_paid), 2)
FROM order_items
GROUP BY name
ORDER BY 2 DESC;



-- Ex 7
-- Now we need the %. We'll need a subquery.
-- The denominator in our second SELECT is our subquery which is the total revenue from order_items
-- We can see that kale and banana smoothies represent just 0.35% and 0.53% of our total revenue!
SELECT
	name,
	ROUND(SUM(amount_paid) /
		(SELECT SUM(amount_paid)
		 FROM order_items) * 100.0, 2) AS pct 
FROM order_items
GROUP BY 1
ORDER BY 2 DESC;



-- Ex 9a
-- So what's going on with the smoothies?
-- We can group the order items by what type of food they are.
-- Our order_items table doesn't include categories, so we'll need to make one in our SELECT statement!
-- We'll build this with a CASE statement
-- Here, we begin with a list of all the order_items with their new category name
SELECT
  CASE name
    WHEN 'kale-smoothie'    THEN 'smoothie'
    WHEN 'banana-smoothie'  THEN 'smoothie'
    WHEN 'orange-juice'     THEN 'drink'
    WHEN 'soda'             THEN 'drink'
    WHEN 'blt'              THEN 'sandwich'
    WHEN 'grilled-cheese'   THEN 'sandwich'
    WHEN 'tikka-masala'     THEN 'dinner'
    WHEN 'chicken-parm'     THEN 'dinner'
     ELSE 'other'
  END AS category
FROM order_items
GROUP BY id
LIMIT 100;

-- Ex 9b
-- We then complete the query by using the category column in our PREVIOUS revenue percentage calc (from ex 7).
-- So yes, as we can see, the whole smoothie category is performing poorly compared to do the other 5 categories.
SELECT
  CASE name
    WHEN 'kale-smoothie'    THEN 'smoothie'
    WHEN 'banana-smoothie'  THEN 'smoothie'
    WHEN 'orange-juice'     THEN 'drink'
    WHEN 'soda'             THEN 'drink'
    WHEN 'blt'              THEN 'sandwich'
    WHEN 'grilled-cheese'   THEN 'sandwich'
    WHEN 'tikka-masala'     THEN 'dinner'
    WHEN 'chicken-parm'     THEN 'dinner'
     ELSE 'other'
  END AS category,
  ROUND(1.0 * SUM(amount_paid) /
		(SELECT SUM(amount_paid)
		 FROM order_items) * 100.0, 2) AS pct 
FROM order_items
GROUP BY 1
ORDER BY 2 DESC;



-- Ex 11a
-- Reorder rates
-- So perhaps no-one likes kale, but perhaps there's another reason for its lack of sales?
-- Let's check it's reorder rate: the ratio of total no. of orders to no. of people making those orders
-- First let's count the total orders per product. We use DISTINCT to exclude multiple units in the same order.
SELECT
    name,
    COUNT(DISTINCT order_id)
FROM order_items
GROUP BY 1
ORDER BY 1;

-- Ex 11b
-- Now we need the number of people making these orders
-- So we join the orders table and count the DISTINCT values in delivered_to, and sort by re-order rate
-- Well! At a reorder rate of 10.5 and 7.2, BOTH smoothies have a high reorder rate, so strong repeat customers.
-- To sum up, the reorder ratio is: the total no. of orders to the no. of people making orders.
SELECT
    name,
    ROUND(1.0 * COUNT(DISTINCT oi.order_id) /
  COUNT(DISTINCT o.delivered_to), 2) AS reorder_rate
FROM order_items oi
    JOIN orders o ON
    o.id = oi.order_id
GROUP BY 1
ORDER BY 2 DESC;

