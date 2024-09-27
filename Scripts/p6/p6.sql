USE classicmodels;

# 1. No encontré una mejor forma
SELECT offices.officeCode, COUNT(employees.officeCode) AS n_employees
FROM offices
INNER JOIN employees
ON employees.officeCode = offices.officeCode
GROUP BY employees.officeCode
ORDER BY n_employees DESC
LIMIT 1;

# Sin extra:
SELECT offices.officeCode
FROM offices
INNER JOIN employees
ON employees.officeCode = offices.officeCode
GROUP BY employees.officeCode
ORDER BY COUNT(employees.officeCode) DESC
LIMIT 1;


# 2. ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor cantidad de productos?
WITH num_orders (officeCode, num) AS (
    SELECT offices.officeCode, COUNT(orders.customerNumber)
    FROM offices
    INNER JOIN employees
    ON employees.officeCode = offices.officeCode
    INNER JOIN customers
    ON customers.salesRepEmployeeNumber = employees.employeeNumber
    INNER JOIN orders
    ON orders.customerNumber = customers.customerNumber
    GROUP BY offices.officeCode
)
SELECT AVG(num)
FROM num_orders;

WITH num_orders (officeCode, num) AS (
    SELECT offices.officeCode, COUNT(orders.customerNumber)
    FROM offices
    INNER JOIN employees
    ON employees.officeCode = offices.officeCode
    INNER JOIN customers
    ON customers.salesRepEmployeeNumber = employees.employeeNumber
    INNER JOIN orders
    ON orders.customerNumber = customers.customerNumber
    GROUP BY offices.officeCode
)
SELECT offices.officeCode
FROM offices
    INNER JOIN num_orders
    ON num_orders.officeCode = offices.officeCode
    WHERE num_orders.num = (
        SELECT MAX(num_orders.num) 
        FROM num_orders
    )
;

# Verificando que esté Bien
WITH num_orders (officeCode, num) AS (
    SELECT offices.officeCode, COUNT(orders.customerNumber)
    FROM offices
    INNER JOIN employees
    ON employees.officeCode = offices.officeCode
    INNER JOIN customers
    ON customers.salesRepEmployeeNumber = employees.employeeNumber
    INNER JOIN orders
    ON orders.customerNumber = customers.customerNumber
    GROUP BY offices.officeCode
) 
SELECT officeCode, num
FROM num_orders
WHERE num = 106;

SELECT offices.officeCode, employees.employeeNumber
FROM offices
INNER JOIN employees
ON employees.officeCode = offices.officeCode
INNER JOIN customers
ON customers.customerNumber = employees.reportsTo;

# 3. 
# Para ver las claves foráneas de una tabla
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM
    information_schema.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = 'classicmodels' AND
    TABLE_NAME = 'orders' AND
    REFERENCED_TABLE_NAME IS NOT NULL;

# O mucho mejor
SHOW CREATE TABLE customers;

SELECT AVG(), MAX(), MIN()