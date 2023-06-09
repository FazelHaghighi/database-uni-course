-- Q1
SELECT customernumber
FROM payments
WHERE paymentdate > (SELECT MAX(paymentdate) - INTERVAL '2 months' FROM payments)
GROUP BY customernumber
ORDER BY COUNT(*) DESC
LIMIT 1;

-- Q2
SELECT customerNumber
FROM payments
WHERE amount > 300
  AND paymentDate = '2002-04-13';

-- Q3
SELECT productName, MSRP, quantityInStock
FROM products
WHERE productCode IN (
    SELECT productCode
    FROM orderdetails
    ORDER BY quantityOrdered * priceEach DESC
    LIMIT 1
);

-- Q4
SELECT customerName, MSRP AS "most expensive item"
FROM (
    SELECT c.customerName, p.MSRP,
        ROW_NUMBER() OVER (PARTITION BY c.customerNumber ORDER BY p.MSRP DESC) AS rn
    FROM customers AS c
    JOIN orders AS o ON c.customerNumber = o.customerNumber
    JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
    JOIN products AS p ON od.productCode = p.productCode
) AS ranked_customers
WHERE rn = 1;

-- Q5
SELECT customerNumber
FROM customers
WHERE customerNumber NOT IN (
    SELECT orders.customerNumber
    FROM orders
);

-- Q6
SELECT p.productCode, p.productName
FROM products AS p
JOIN orderdetails AS od ON p.productCode = od.productCode
JOIN orders AS o ON od.orderNumber = o.orderNumber
WHERE o.orderDate > (SELECT MAX(orderDate) - INTERVAL '2 months' FROM orders)
ORDER BY od.quantityOrdered * od.priceEach DESC
LIMIT 1;

-- custom query

-- 1.employees ordered by number of customers they have
SELECT customers.salesRepEmployeeNumber AS employeeNumber, COUNT(*) AS CustomersCount
FROM customers
INNER JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
GROUP BY customers.salesRepEmployeeNumber
ORDER BY CustomersCount DESC;

-- 2.pure profit for each product and assigns a rank to each product based on its profitability within its corresponding product line
SELECT productline, productName, quantityInStock * (MSRP - buyPrice) AS value, 
    RANK() OVER (PARTITION BY productLine ORDER BY quantityInStock * (MSRP - buyPrice) DESC) AS value_rank
FROM products;

-- 3.top 5 customers who have spent the most money
SELECT o.customerNumber
FROM orders AS o
JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY o.customerNumber
ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC
LIMIT 5;

-- 4.top 10 customers who have spent the most money in the last 6 months and have not ordered in the last 3 months
SELECT o.customerNumber
FROM orders AS o
JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
WHERE o.orderDate > (SELECT MAX(orderDate) - INTERVAL '6 months' FROM orders)
  AND o.orderDate < (SELECT MAX(orderDate) - INTERVAL '3 months' FROM orders)
GROUP BY o.customerNumber
ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC
LIMIT 10;

-- 5.top 10 products with the highest amount of discounts
SELECT productName, discountCode, ROUND((MSRP * amount) / 100, 2) AS discountedPrice
FROM products
JOIN discounts USING (discountCode)
ORDER BY discountedPrice DESC
LIMIT 10;
