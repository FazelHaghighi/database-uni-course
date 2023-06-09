-- view 1
CREATE OR REPLACE VIEW top_credit AS
SELECT customerNumber
FROM customers
ORDER BY creditLimit DESC
LIMIT 10;

-- view 2 - most expensive items
CREATE OR REPLACE VIEW most_expensive_items AS
SELECT productCode, MSRP
FROM products
ORDER BY MSRP DESC
LIMIT 10;

-- materialized view 1
CREATE MATERIALIZED VIEW past_10_month_orders AS
SELECT *
FROM orders
WHERE orderDate > (SELECT MAX(orderDate) - INTERVAL '10 months' FROM orders);

-- materialized view 2 - top 10 customers in last month
CREATE MATERIALIZED VIEW top_customers AS
SELECT customerNumber, sum(amount)
FROM payments
WHERE paymentdate > (SELECT MAX(paymentdate) - INTERVAL '1 months' FROM payments)
GROUP BY customerNumber
ORDER BY sum(amount) DESC
LIMIT 10;

-- function 1
CREATE OR REPLACE FUNCTION GetProductsWithinMSRPRange(amount1 DECIMAL, amount2 DECIMAL)
RETURNS TABLE (productCode VARCHAR)
AS $$
BEGIN
  RETURN QUERY
    SELECT p.productCode
    FROM products p
    WHERE p.MSRP BETWEEN amount1 AND amount2
    ORDER BY p.MSRP DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- function 2
CREATE OR REPLACE FUNCTION CalculateTotalAmount(p_productCode VARCHAR)
RETURNS DECIMAL
AS $$
DECLARE
  total DECIMAL := 0;
BEGIN
  SELECT SUM(quantityOrdered * priceEach)
  INTO total
  FROM orderdetails
  WHERE productCode = p_productCode;

  RETURN total;
END;
$$ LANGUAGE plpgsql;

-- function 3
CREATE OR REPLACE FUNCTION GetOrderCountForCustomerWithMaxPayment(startDate DATE, endDate DATE)
RETURNS INTEGER
AS $$
DECLARE
  customerId INTEGER;
  orderCount INTEGER;
BEGIN
  SELECT customerNumber
  INTO customerId
  FROM (
    SELECT customerNumber, SUM(amount) AS totalAmount
    FROM payments
    WHERE paymentDate BETWEEN startDate AND endDate
    GROUP BY customerNumber
    ORDER BY totalAmount DESC
    LIMIT 1
  ) AS subquery;

  SELECT COUNT(*)
  INTO orderCount
  FROM orders
  WHERE customerNumber = customerId;

  RETURN orderCount;
END;
$$ LANGUAGE plpgsql;

-- function 4 - returning quantity in stock for a given item
CREATE OR REPLACE FUNCTION GetProductQuantity(p_productCode VARCHAR)
RETURNS numeric
AS $$
DECLARE
  quantity numeric := 0;
BEGIN
  SELECT p.quantityInStock
  INTO quantity
  FROM products AS p
  WHERE p.productCode = p_productCode;

  RETURN quantity;
END;
$$ LANGUAGE plpgsql;

-- function 5 - checking for discountCode for a given item
CREATE OR REPLACE FUNCTION CheckDiscountCode(productCode VARCHAR)
RETURNS VARCHAR
AS $$
DECLARE
  discountCode VARCHAR;
BEGIN
  SELECT p.discountCode
  INTO discountCode
  FROM products p
  WHERE p.productCode = CheckDiscountCode.productCode;

  IF discountCode IS NULL THEN
    RETURN 'No'; -- No discount code found
  ELSE
    RETURN discountCode; -- Return the discount code
  END IF;
END;
$$ LANGUAGE plpgsql;

-- stored procedure 1
CREATE OR REPLACE PROCEDURE UpdateMSRPByPercentage(p_percentage DECIMAL)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE products
  SET MSRP = MSRP + (MSRP * p_percentage / 100);
END;
$$;

-- stored procedure 2
CREATE OR REPLACE PROCEDURE UpdateCreditLimitByLast3MonthsPayment(increaseAmount DECIMAL)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE customers
  SET creditLimit = creditLimit + increaseAmount
  WHERE customerNumber = (
    SELECT c.customerNumber
    FROM customers c
    JOIN (
      SELECT customerNumber, SUM(amount) AS totalAmount
      FROM payments
      WHERE paymentDate > (SELECT MAX(paymentDate) - INTERVAL '3 months' FROM payments)
      GROUP BY customerNumber
      ORDER BY totalAmount DESC
      LIMIT 1
    ) AS p ON c.customerNumber = p.customerNumber
  );
END;
$$;

-- stored procedure 3 - put a 10 percent discount on all products ordered in last month
CREATE OR REPLACE PROCEDURE ApplyDiscountOnLastMonthOrders()
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE products
  SET MSRP = MSRP * 0.9 -- Apply 10% discount
  WHERE productCode IN (
    SELECT od.productCode
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.orderDate > (SELECT MAX(orderDate) - INTERVAL '1 month' FROM orders)
  );
END;
$$;

-- stored procedure 4 - update the quantity in stock for a given item
CREATE OR REPLACE PROCEDURE UpdateProductQuantity(p_productCode VARCHAR, p_quantity INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE products
  SET quantityInStock = p_quantity
  WHERE productCode = p_productCode;
END;
$$;

-- trigger 1
CREATE OR REPLACE FUNCTION ApplyDiscount()
RETURNS TRIGGER
AS $$
BEGIN
  IF NEW.quantityOrdered * NEW.priceEach > 3000 THEN
    NEW.priceEach := NEW.priceEach * 0.7; -- Apply 30% discount
  ELSIF NEW.quantityOrdered * NEW.priceEach > 2000 THEN
    NEW.priceEach := NEW.priceEach * 0.8; -- Apply 20% discount
  ELSIF NEW.quantityOrdered * NEW.priceEach > 1000 THEN
    NEW.priceEach := NEW.priceEach * 0.9; -- Apply 10% discount
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER apply_discount_trigger
BEFORE INSERT OR UPDATE ON orderdetails
FOR EACH ROW
EXECUTE FUNCTION ApplyDiscount();

-- trigger 2
CREATE OR REPLACE FUNCTION ReduceQuantityInStock()
RETURNS TRIGGER
AS $$
BEGIN
  UPDATE products
  SET quantityInStock = quantityInStock - NEW.quantityOrdered
  WHERE productCode = NEW.productCode;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reduce_quantity_trigger
AFTER INSERT ON orderdetails
FOR EACH ROW
EXECUTE FUNCTION ReduceQuantityInStock();

-- trigger 3 - update the credit limit of the customer by the value of the order
CREATE OR REPLACE FUNCTION IncreaseCreditLimit()
RETURNS TRIGGER
AS $$
BEGIN
  UPDATE customers
  SET creditLimit = creditLimit + (
    SELECT SUM(od.quantityOrdered * od.priceEach)
    FROM orderdetails od
    WHERE od.orderNumber = NEW.orderNumber
  )
  WHERE customerNumber = (
    SELECT customerNumber
    FROM orders
    WHERE orderNumber = NEW.orderNumber
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increase_credit_limit_trigger
AFTER INSERT ON orderdetails
FOR EACH ROW
EXECUTE FUNCTION IncreaseCreditLimit();

-- trigger 4 - update the custom materialized view
CREATE OR REPLACE FUNCTION UpdateTopCustomers()
RETURNS TRIGGER
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW top_customers;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_top_customers_trigger
AFTER INSERT OR UPDATE OR DELETE ON payments
FOR EACH STATEMENT
EXECUTE FUNCTION UpdateTopCustomers();
