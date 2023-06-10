-- Indexing

CREATE INDEX customer_name_idx ON customers (customerName);

CREATE INDEX product_line_idx ON products (productLine);

CREATE INDEX customer_number_amount_idx ON payments (customerNumber, amount);


-- Transaction

BEGIN;
insert into orders(orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber) values
(12000,'2003-01-06','2003-01-13','2003-01-10','Shipped',NULL,363);
COMMIT;

BEGIN;
UPDATE orders SET status = 'In Process' 
WHERE orderNumber = 12000;
ROLLBACK;

BEGIN;
DELETE FROM orders 
WHERE orderNumber = 12000;
COMMIT;
