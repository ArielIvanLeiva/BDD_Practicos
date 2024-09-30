USE classicmodels;

# 1. No encontré una mejor forma
SELECT offices.officeCode, COUNT(employees.officeCode) AS n_employees
FROM offices
    INNER JOIN employees ON employees.officeCode = offices.officeCode
GROUP BY
    employees.officeCode
ORDER BY n_employees DESC
LIMIT 1;

# Sin extra:
SELECT offices.officeCode
FROM offices
    INNER JOIN employees ON employees.officeCode = offices.officeCode
GROUP BY
    employees.officeCode
ORDER BY COUNT(employees.officeCode) DESC
LIMIT 1;

# 2. ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor cantidad de productos?
WITH
    num_orders (officeCode, num) AS (
        SELECT offices.officeCode, COUNT(orders.customerNumber)
        FROM
            offices
            INNER JOIN employees ON employees.officeCode = offices.officeCode
            INNER JOIN customers ON customers.salesRepEmployeeNumber = employees.employeeNumber
            INNER JOIN orders ON orders.customerNumber = customers.customerNumber
        GROUP BY
            offices.officeCode
    )
SELECT AVG(num)
FROM num_orders;

WITH
    num_orders (officeCode, num) AS (
        SELECT offices.officeCode, COUNT(orders.customerNumber)
        FROM
            offices
            INNER JOIN employees ON employees.officeCode = offices.officeCode
            INNER JOIN customers ON customers.salesRepEmployeeNumber = employees.employeeNumber
            INNER JOIN orders ON orders.customerNumber = customers.customerNumber
        GROUP BY
            offices.officeCode
    )
SELECT offices.officeCode
FROM offices
    INNER JOIN num_orders ON num_orders.officeCode = offices.officeCode
WHERE
    num_orders.num = (
        SELECT MAX(num_orders.num)
        FROM num_orders
    );

# Verificando que esté Bien
WITH
    num_orders (officeCode, num) AS (
        SELECT offices.officeCode, COUNT(orders.customerNumber)
        FROM
            offices
            INNER JOIN employees ON employees.officeCode = offices.officeCode
            INNER JOIN customers ON customers.salesRepEmployeeNumber = employees.employeeNumber
            INNER JOIN orders ON orders.customerNumber = customers.customerNumber
        GROUP BY
            offices.officeCode
    )
SELECT officeCode, num
FROM num_orders
WHERE
    num = 106;

# 3.
# Para ver las claves foráneas de una tabla
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = 'classicmodels'
    AND TABLE_NAME = 'orders'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

# O mucho mejor
SHOW CREATE TABLE customers;

SELECT AVG(), MAX(), MIN()
    # OJO: Esto habla de dependencia funcional, pero el principal problema es que no ese están usando correctamente funciones agregadas.
SELECT YEAR(paymentDate), MONTH(payments.paymentDate), amount
FROM payments
GROUP BY
    YEAR(paymentDate),
    MONTH(payments.paymentDate);

# Ahora sí
SELECT
    YEAR(paymentDate) AS year,
    MONTH(paymentDate) AS month,
    AVG(amount) AS average,
    MAX(amount) AS maximum,
    MIN(amount) AS minimum
FROM payments
GROUP BY
    YEAR(paymentDate),
    MONTH(paymentDate);

# Formateando un poquito
SELECT CONCAT(
        year, '-', LPAD(month, 2, '0')
    ) as date, average, maximum, minimum
FROM (
        SELECT
            YEAR(paymentDate) AS year, MONTH(paymentDate) AS month, AVG(amount) AS average, MAX(amount) AS maximum, MIN(amount) AS minimum
        FROM payments
        GROUP BY
            YEAR(paymentDate), MONTH(paymentDate)
    ) AS results;

DESCRIBE customers;
# 4.
DELIMITER $$

CREATE PROCEDURE check_date_and_fine(IN customerNumber INT,IN creditLimit decimal(10, 2))
BEGIN
	UPDATE customers
    SET customers.creditLimit = creditLimit
    WHERE customers.customerNumber = customerNumber;
END $$

DELIMITER;

# 5.
CREATE VIEW `Premium Customers` AS
SELECT customers.customerName, customers.city, SUM(payments.amount)
FROM customers
    INNER JOIN payments ON payments.customerNumber = customers.customerNumber
GROUP BY
    customers.customerNumber
ORDER BY SUM(payments.amount) DESC
LIMIT 10;

DROP VIEW `Premium Customers`;

SELECT * FROM `Premium Customers`;

# 6.
DESCRIBE employees;

DELIMITER $$

CREATE FUNCTION `employee of the month`(mes INT, anio INT)
RETURNS varchar(100) DETERMINISTIC
BEGIN
    DECLARE full_name varchar(100);

    SELECT CONCAT(employees.firstName, ' ', employees.lastName)
    FROM customers
    INNER JOIN employees
    ON employees.employeeNumber = customers.salesRepEmployeeNumber
    INNER JOIN orders
    ON orders.customerNumber = customers.customerNumber
    WHERE MONTH(orders.orderDate) = mes AND YEAR(orders.orderDate) = anio
    GROUP BY employees.employeeNumber
    ORDER BY COUNT(orders.customerNumber) DESC
    LIMIT 1
    INTO full_name;

	RETURN full_name;
END $$

DELIMITER;

DROP FUNCTION `employee of the month`;

SELECT `employee of the month` (2, 2005);

# 7.

# Esto tiene un problema de tipos
# Referencing column 'productCode' and referenced column 'productCode' in foreign key constraint 'Product Refillment_ibfk_1' are incompatible.
CREATE TABLE `Product Refillment` (
    refillmentID int NOT NULL AUTO_INCREMENT,
    productCode int NOT NULL,
    orderDate DATE,
    quantity int,
    PRIMARY KEY (refillmentID),
    FOREIGN KEY (productCode) REFERENCES products (productCode)
);

# Miramos la table products
DESCRIBE products;

# Corregimos
CREATE TABLE `Product Refillment` (
    refillmentID int NOT NULL AUTO_INCREMENT,
    productCode varchar(15) NOT NULL,
    orderDate DATE,
    quantity int,
    PRIMARY KEY (refillmentID),
    FOREIGN KEY (productCode) REFERENCES products (productCode)
);

# 8.
DELIMITER $$

CREATE TRIGGER `Restock Product`
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
    DECLARE quantityIS int;

    SELECT quantityInStock 
    FROM products
    WHERE orderdetails.productCode = products.productCode
    INTO quantityIS;

	IF quantityIS - NEW.quantityOrdered < 10 THEN
        INSERT INTO `Product Refillment` (productCode, orderDate, quantity) VALUES (
            NEW.productCode,
            CURRENT_DATE(),
            10
        );
    END IF;
END;

DELIMITER ;

select quantityInStock, productCode
FROM products
ORDER BY quantityInStock ASC;

# El que tiene menor stock S24_2000


# 9. IMPORTANTE: Para poder acceder con un usario y apoderarse de su rol,
# el mismo debe utilizar 
# SET ROLE `Nombre del rol`;
CREATE ROLE `Empleado`;
GRANT SELECT, CREATE VIEW ON classicmodels.* TO `Empleado`;

CREATE USER Pepe IDENTIFIED BY '123456';
GRANT Empleado TO 'Pepe'@'%';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'Pepe'@'%';