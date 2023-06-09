-- view 1
SELECT customerNumber
FROM top_credit;

-- view 2 - most expensive items
SELECT productCode, MSRP
FROM most_expensive_items;

-- materialized view 1
SELECT *
FROM past_10_month_orders;

-- materialized view 2 - top 10 customers in last month
SELECT *
FROM top_customers;

-- function 1
SELECT *
FROM GetProductsWithinMSRPRange(100, 200);

-- function 2
SELECT CalculateTotalAmount('S10_1678');

-- function 3
SELECT GetOrderCountForCustomerWithMaxPayment('2003-01-01', '2004-06-30');

-- function 4 - returning quantity in stock for a given item
SELECT GetProductQuantity('S10_1678');

-- function 5 - checking for discountCode for a given item
SELECT CheckDiscountCode('S10_1678');

-- stored procedure 1
-- Query the MSRP values before the update
SELECT productCode, MSRP AS originalMSRP
FROM products
ORDER BY originalMSRP;

-- Call the procedure to update the MSRP
CALL UpdateMSRPByPercentage(10);

-- Query the MSRP values after the update
SELECT productCode, MSRP AS updatedMSRP
FROM products
ORDER BY updatedMSRP;


-- stored procedure 2
-- Query the credit limit values before the update
SELECT customerNumber, creditLimit AS originalCreditLimit
FROM customers
ORDER BY originalCreditLimit DESC;

-- Call the procedure to update the credit limit
CALL UpdateCreditLimitByLast3MonthsPayment(500);

-- Query the credit limit values after the update
SELECT customerNumber, creditLimit AS updatedCreditLimit
FROM customers
ORDER BY updatedCreditLimit DESC;


-- stored procedure 3 - put a 10 percent discount on all products ordered in last month
-- Query the MSRP values before applying the discount
SELECT productCode, MSRP AS originalMSRP
FROM products
ORDER BY originalMSRP;

-- Call the procedure to apply the discount
CALL ApplyDiscountOnLastMonthOrders();

-- Query the MSRP values after applying the discount
SELECT productCode, MSRP AS updatedMSRP
FROM products
ORDER BY updatedMSRP;


-- stored procedure 4 - update the quantity in stock for a given item
-- Query the quantity in stock values before the update
SELECT productCode, quantityInStock AS originalQuantity
FROM products
ORDER BY originalQuantity DESC;

-- Call the procedure to update the quantity in stock
CALL UpdateProductQuantity('S12_2823', 10000);

-- Query the quantity in stock values after the update
SELECT productCode, quantityInStock AS updatedQuantity
FROM products
ORDER BY updatedQuantity DESC;


-- trigger 1
insert into orders(orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber) values

(10505,'2003-01-06','2003-01-13','2003-01-10','Shipped',NULL,363),

(10506,'2003-01-09','2003-01-18','2003-01-11','Shipped',NULL,128),

(10507,'2003-01-10','2003-01-18','2003-01-14','Shipped',NULL,181);

insert into orderdetails(orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) values

(10505,'S18_1749',10,'350',3),

(10506,'S18_2248',10,'250',2),

(10507,'S18_4409',10,'150',4);

SELECT * FROM orderdetails
WHERE orderNumber = 10505 or orderNumber = 10506 or orderNumber = 10507;


-- trigger 2
insert into products(productCode, productName, productLine, productScale, productVendor, productDescription, quantityInStock, buyPrice, MSRP, discountCode) values

('A1','test','Ships','1:10','ok','ok',100,'300','350',NULL),

('A2','test1','Ships','1:10','ok','ok',100,'200','250',NULL),

('A3','test2','Ships','1:10','ok','ok',100,'100','150',NULL);

insert into orders(orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber) values

(10700,'2003-01-06','2003-01-13','2003-01-10','Shipped',NULL,363),

(10701,'2003-01-09','2003-01-18','2003-01-11','Shipped',NULL,128),

(10702,'2003-01-10','2003-01-18','2003-01-14','Shipped',NULL,181);

insert into orderdetails(orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) values

(10700,'ABCD',10,'350',3),

(10701,'EFGH',10,'250',2),

(10702,'IJKL',10,'150',4);

SELECT quantityInStock FROM products
WHERE productCode = 'A1' or productCode = 'A2' or productCode = 'A3';


-- trigger 3 - update the credit limit of the customer by the value of the order
SELECT creditLimit FROM customers
WHERE customerNumber = 363 or customerNumber = 128 or customerNumber = 181;

insert into orders(orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber) values

(10950,'2003-01-06','2003-01-13','2003-01-10','Shipped',NULL,363),

(10951,'2003-01-09','2003-01-18','2003-01-11','Shipped',NULL,128),

(10952,'2003-01-10','2003-01-18','2003-01-14','Shipped',NULL,181);

insert into orderdetails(orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) values

(10950,'S18_1749',10,'350',3),

(10951,'S18_2248',10,'250',2),

(10952,'S18_4409',10,'150',4);

SELECT creditLimit FROM customers
WHERE customerNumber = 363 or customerNumber = 128 or customerNumber = 181;


-- trigger 4 - update the custom materialized view
SELECT *
FROM past_10_month_orders;
