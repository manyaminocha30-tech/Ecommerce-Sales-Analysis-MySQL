CREATE DATABASE ecommerce_sql_project; 

USE ecommerce_sql_project;

CREATE TABLE Customers 
(customer_id INT PRIMARY KEY,  
customer_name VARCHAR(100) NOT NULL, 
email VARCHAR(150) UNIQUE, 
gender VARCHAR(20), 
city VARCHAR(50),  
state VARCHAR(50),  
signup_date DATE,  
customer_segment VARCHAR(30) );

LOAD DATA LOCAL INFILE "C:\Users\saksh\Downloads\customers (1).csv" 
INTO TABLE Customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

select * from Customers;

CREATE TABLE Sellers 
(seller_id INT PRIMARY KEY,   
 seller_name VARCHAR(100) NOT NULL,    
 city VARCHAR(50),    
 state VARCHAR(50),    
 rating DECIMAL(3,2),    
 join_date DATE );

LOAD DATA LOCAL INFILE "C:\Users\saksh\Downloads\sellers.csv" 
INTO TABLE Sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

SELECT COUNT(*) FROM Customers; 
SELECT COUNT(*) FROM Sellers; 
SELECT COUNT(*) FROM Products; 
SELECT COUNT(*) FROM Orders; 
SELECT COUNT(*) FROM Order_Items; 
SELECT COUNT(*) FROM Payments; 
SELECT COUNT(*) FROM Reviews;

SELECT * FROM Customers LIMIT 10; 
SELECT * FROM Sellers LIMIT 10; 
SELECT * FROM Products LIMIT 10; 
SELECT * FROM Orders LIMIT 10; 
SELECT * FROM Order_Items LIMIT 10; 
SELECT * FROM Payments LIMIT 10; 
SELECT * FROM Reviews LIMIT 10;

SELECT o.order_id, o.order_date, c.customer_id, c.customer_name 
FROM Orders o 
JOIN Customers c 
ON o.customer_id = c.customer_id LIMIT 20;

SELECT p.product_id, p.product_name, s.seller_name 
FROM Products p 
JOIN Sellers s 
ON p.seller_id = s.seller_id LIMIT 20;

SELECT o.order_id, p.product_name, oi.quantity, oi.unit_price, oi.line_total 
FROM Orders o 
JOIN Order_Items oi 
ON o.order_id = oi.order_id 
JOIN Products p 
ON oi.product_id = p.product_id 
LIMIT 20;

SELECT customer_id, COUNT(*) 
FROM Customers 
GROUP BY customer_id 
HAVING COUNT(*) > 1; 

SELECT product_id, COUNT(*) 
FROM Products 
GROUP BY product_id 
HAVING COUNT(*) > 1; 

SELECT order_id, COUNT(*) 
FROM Orders 
GROUP BY order_id 
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS total_records,    
SUM(customer_id IS NULL) AS null_customer_id,    
SUM(customer_name IS NULL) AS null_customer_name,    
SUM(email IS NULL) AS null_email 
FROM Customers; 

SELECT COUNT(*) AS total_records,    
SUM(order_id IS NULL) AS null_order_id,    
SUM(customer_id IS NULL) AS null_customer_id,    
SUM(order_date IS NULL) AS null_order_date 
FROM Orders;

CREATE INDEX idx_orders_customer ON Orders(customer_id); 
CREATE INDEX idx_orders_date ON Orders(order_date); 
CREATE INDEX idx_orders_status ON Orders(order_status); 
CREATE INDEX idx_order_items_order ON Order_Items(order_id); 
CREATE INDEX idx_order_items_product ON Order_Items(product_id); 
CREATE INDEX idx_products_category ON Products(category); 
CREATE INDEX idx_products_seller ON Products(seller_id); 
CREATE INDEX idx_payments_order ON Payments(order_id); 
CREATE INDEX idx_reviews_product ON Reviews(product_id); 
CREATE INDEX idx_reviews_customer ON Reviews(customer_id);


#1. Delivered orders
SELECT * FROM Orders 
WHERE order_status='Delivered';

#2. Orders after 2025-01-01
SELECT * FROM Orders 
WHERE order_date>'2025-01-01';

#3. Delivered orders paid by UPI
SELECT * FROM Orders 
WHERE order_status='Delivered' AND payment_method='UPI';

#4. Customers from selected cities
SELECT * FROM Customers 
WHERE city IN ('Delhi','Mumbai','Bengaluru');

#5. Products priced 1000-5000
SELECT * FROM Products 
WHERE price BETWEEN 1000 AND 5000;

#6. Customers whose name starts with A
SELECT * FROM Customers 
WHERE customer_name 
LIKE 'A%';

#7. 10 most expensive products
SELECT * FROM Products 
ORDER BY price 
DESC LIMIT 10;

#8. Unique payment methods
SELECT DISTINCT payment_method 
FROM Orders;

#9. Orders by status
SELECT order_status,COUNT(*) AS order_count 
FROM Orders 
GROUP BY order_status;

#10. Sales by payment method
SELECT o.payment_method,SUM(p.amount) AS total_amount 
FROM Orders o 
JOIN Payments p ON o.order_id=p.order_id 
GROUP BY o.payment_method;

#11. Average price by category
SELECT category,AVG(price) AS avg_price 
FROM Products 
GROUP BY category;

#12. Units sold per product
SELECT product_id,SUM(quantity) AS units_sold 
FROM Order_Items 
GROUP BY product_id;

#13. Cities with >500 customers
SELECT city,COUNT(*) AS customer_count 
FROM Customers 
GROUP BY city 
HAVING COUNT(*)>500;

#14. Categories with avg price >5000
SELECT category,AVG(price) AS avg_price 
FROM Products 
GROUP BY category 
HAVING AVG(price)>5000;

#15. Orders with customer names
SELECT o.order_id,o.order_date,c.customer_name 
FROM Orders o 
INNER JOIN Customers c 
ON o.customer_id=c.customer_id;

#16. All customers and orders
SELECT c.customer_id,c.customer_name,o.order_id 
FROM Customers c 
LEFT JOIN Orders o 
ON c.customer_id=o.customer_id;

#17. Customers with no orders
SELECT c.customer_id,c.customer_name 
FROM Customers c 
LEFT JOIN Orders o 
ON c.customer_id=o.customer_id 
WHERE o.order_id IS NULL;

#18. Customer, order and payment
SELECT c.customer_name,o.order_id,p.amount 
FROM Customers c 
JOIN Orders o 
ON c.customer_id=o.customer_id 
JOIN Payments p 
ON o.order_id=p.order_id;

#19. Total spending per customer
SELECT c.customer_id,c.customer_name,
SUM(p.amount) AS total_spent 
FROM Customers c 
JOIN Orders o 
ON c.customer_id=o.customer_id 
JOIN Payments p 
ON o.order_id=p.order_id 
GROUP BY c.customer_id,c.customer_name;

#20. Customers spending >100000
SELECT c.customer_id,c.customer_name,
SUM(p.amount) AS total_spent 
FROM Customers c 
JOIN Orders o 
ON c.customer_id=o.customer_id 
JOIN Payments p 
ON o.order_id=p.order_id 
GROUP BY c.customer_id,c.customer_name 
HAVING SUM(p.amount)>100000;

#21. Products from same category
SELECT a.product_name,b.product_name,a.category 
FROM Products a 
JOIN Products b 
ON a.category=b.category 
AND a.product_id<b.product_id;

#22. Products above overall average
SELECT * FROM Products 
WHERE price>(SELECT AVG(price) 
FROM Products);

#23. Customers with at least one order
SELECT * FROM Customers 
WHERE customer_id IN (SELECT customer_id 
FROM Orders);

#24. Products above category average
SELECT p.* FROM Products p 
WHERE p.price>(SELECT AVG(p2.price) 
FROM Products p2 
WHERE p2.category=p.category);

#25. Customer spending using CTE
WITH customer_spend AS (SELECT o.customer_id,SUM(p.amount) total_spent 
FROM Orders o 
JOIN Payments p 
ON o.order_id=p.order_id 
GROUP BY o.customer_id) 
SELECT * FROM customer_spend;

#26. Top 10 customers by spending
WITH s AS (SELECT o.customer_id,SUM(p.amount) total_spent 
FROM Orders o 
JOIN Payments p 
ON o.order_id=p.order_id 
GROUP BY o.customer_id) 
SELECT * FROM s 
ORDER BY total_spent 
DESC LIMIT 10;

#27. Monthly order counts
WITH m AS (SELECT DATE_FORMAT(order_date,'%Y-%m') month,
COUNT(*) orders 
FROM Orders 
GROUP BY DATE_FORMAT(order_date,'%Y-%m')) 
SELECT * FROM m 
ORDER BY month;

#28. Revenue by category
WITH s AS (SELECT pr.category,SUM(oi.line_total) revenue 
FROM Order_Items oi 
JOIN Products pr 
ON oi.product_id=pr.product_id 
GROUP BY pr.category) 
SELECT * FROM s 
ORDER BY revenue DESC;

#29. Rank products by price
SELECT product_id,product_name,price,
RANK() OVER(ORDER BY price DESC) price_rank 
FROM Products;

#30. Rank products within category
SELECT product_id,product_name,category,price,
DENSE_RANK() OVER(PARTITION BY category ORDER BY price DESC) category_rank 
FROM Products;

#31. Number each customer's orders
SELECT customer_id,order_id,order_date,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) order_number 
FROM Orders;

#32. Running revenue
SELECT payment_date,payment_id,amount,SUM(amount) 
OVER(ORDER BY payment_date,payment_id) running_revenue 
FROM Payments;

#33. Running average payment
SELECT payment_date,payment_id,amount,AVG(amount) 
OVER(ORDER BY payment_date,payment_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_avg 
FROM Payments;

#34. Previous payment comparison
SELECT payment_id,payment_date,amount,LAG(amount) 
OVER(ORDER BY payment_date,payment_id) previous_amount 
FROM Payments;

#35. Next payment amount
SELECT payment_id,payment_date,amount,LEAD(amount) 
OVER(ORDER BY payment_date,payment_id) next_amount 
FROM Payments;

#36. Rank customers by spending
WITH s AS (SELECT o.customer_id,SUM(p.amount) total_spent 
FROM Orders o 
JOIN Payments p 
ON o.order_id=p.order_id 
GROUP BY o.customer_id) 
SELECT *,DENSE_RANK() OVER(ORDER BY total_spent DESC) customer_rank 
FROM s;

#37. Top 3 products per category
WITH r AS 
(SELECT *,DENSE_RANK() OVER(PARTITION BY category ORDER BY price DESC) rnk 
FROM Products) 
SELECT * FROM r WHERE rnk<=3;

#38. Price segmentation
SELECT product_id,product_name,price,CASE WHEN price<1000 THEN 'Budget' 
WHEN price<5000 THEN 'Mid-Range' 
ELSE 'Premium' END price_segment 
FROM Products;

#39. Orders by year
SELECT YEAR(order_date) order_year,COUNT(*) orders 
FROM Orders 
GROUP BY YEAR(order_date);

#40. Cancellation rate
SELECT ROUND(100*SUM(CASE WHEN order_status='Cancelled' 
THEN 1 ELSE 0 END)/COUNT(*),2) cancellation_rate_pct 
FROM Orders;
