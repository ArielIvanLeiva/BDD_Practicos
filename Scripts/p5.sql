USE sakila;

# 1.
CREATE TABLE IF NOT EXISTS directors (
	Nombre varchar(255),
	Apellido varchar(255),
	`Número de Películas` int
);

# 2. 
# Solo id's
SELECT film_actor.actor_id, COUNT(film_actor.film_id) AS num_films 
FROM film_actor
GROUP BY actor_id
ORDER BY num_films DESC
LIMIT 5;

# Ahora nombres (con unas cositas para mí mismo)
SELECT actor.first_name, actor.actor_id, COUNT(film_actor.film_id)
FROM actor
INNER JOIN film_actor
	ON actor.actor_id = film_actor.actor_id
INNER JOIN film
	ON film.film_id = film_actor.film_id
GROUP BY actor.actor_id
ORDER BY COUNT(film_actor.actor_id) DESC
LIMIT 5;

INSERT INTO directors
	SELECT actor.first_name, actor.last_name, COUNT(film_actor.film_id)
	FROM actor
	INNER JOIN film_actor
		ON actor.actor_id = film_actor.actor_id
	INNER JOIN film
		ON film.film_id = film_actor.film_id
	GROUP BY actor.actor_id
	ORDER BY COUNT(film_actor.actor_id) DESC
	LIMIT 5
;

# 3.
ALTER TABLE customer
ADD COLUMN premium_customer varchar(1) DEFAULT 'F';

ALTER TABLE customer
DROP COLUMN premium_customer;

ALTER TABLE customer
ADD CONSTRAINT CHECK (premium_customer = 'T' OR premium_customer = 'F');

# 4.
# Esto calcula el id de los 10 customers con mayor dinero gastado
SELECT customer_id
	FROM payment
	GROUP BY payment.customer_id
	ORDER BY SUM(payment.amount) DESC
	LIMIT 10;

# Esto es bonito pero mysql no me deja :-(
WITH customer_info(customer_id) AS 
(
	SELECT customer_id
	FROM payment
	GROUP BY payment.customer_id
	ORDER BY SUM(payment.amount) DESC
	LIMIT 10
)
UPDATE customer
SET premium_customer = 'T'
WHERE customer.customer_id IN (SELECT * FROM customer_info);

# Esto es un poco más sucio pero funciona
UPDATE customer
SET premium_customer = 'T'
WHERE EXISTS (
	SELECT payment.customer_id
	FROM payment
	GROUP BY payment.customer_id
	HAVING payment.customer_id = customer.customer_id
	ORDER BY SUM(payment.amount) DESC
	LIMIT 10
);

SELECT customer.premium_customer
FROM customer;
SELECT customer_id, SUM(payment.amount)
	FROM payment
	GROUP BY payment.customer_id
	ORDER BY SUM(payment.amount) DESC
	LIMIT 10;
describe film;
# 5.
SELECT film.title, rating, COUNT(inventory.film_id) AS amount
FROM inventory
INNER JOIN film
ON film.film_id = inventory.film_id
GROUP BY film.film_id
ORDER BY COUNT(inventory.film_id) DESC;

# 6.
SELECT MIN(payment_date) AS first_date, MAX(payment_date) AS last_date
FROM payment;

# 7.
SELECT EXTRACT(YEAR FROM payment.payment_date) AS `year`, EXTRACT(MONTH FROM payment.payment_date) AS `month`, AVG(payment.amount) AS average
FROM payment
GROUP BY EXTRACT(YEAR FROM payment.payment_date), EXTRACT(MONTH FROM payment.payment_date);

SELECT EXTRACT(YEAR FROM '2020-03-01');

# 8.
SELECT DISTINCT address.district, COUNT(address.district) AS number_of_rentals
FROM address
INNER JOIN customer
ON customer.address_id = address.address_id 
INNER JOIN rental
ON rental.customer_id = customer.customer_id
GROUP BY address.district
ORDER BY COUNT(address.district) DESC
LIMIT 10;

# 9.
ALTER TABLE inventory 
ADD stock INT
DEFAULT 5;

# 10
CREATE TRIGGER update_stock
AFTER INSERT ON rental
FOR EACH ROW
BEGIN
	UPDATE inventory
	SET stock = stock - 1
	WHERE inventory.inventory_id = NEW.inventory_id;
END;



# Probando cosas
INSERT INTO rental (rental_date,inventory_id,customer_id,return_date,staff_id,last_update) VALUES
	 ('2005-05-24 22:53:30',48,130,'2005-05-26 22:04:30',1,'2006-02-15 21:30:53');

SELECT DATEDIFF('2005-05-26 22:04:30','2005-03-22 22:53:30');

describe rental;
select * from rental LImit 1;
select rental.rental_id 
from rental 
where rental.inventory_id = 1; 
# 4863
select * from directors;
select inventory_id, stock from inventory
where inventory_id = 48;

# Hice esto porque si no me jodía el ejercicio siguiente (había diferencia negativa de días)
delete from rental
where rental_id = 16051;


# 11.
CREATE TABLE fines (
	rental_id INT,
	amount NUMERIC(10,2),
	FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
);

# 12.
DELIMITER $$
CREATE PROCEDURE check_date_and_fine()
BEGIN
	INSERT INTO fines(rental_id, amount)
	SELECT rental_id, (DATEDIFF(rental.return_date, rental.rental_date) - 3) * 1.5
	FROM rental
	WHERE DATEDIFF(rental.return_date, rental.rental_date) > 3;
END $$
DELIMITER ;
CALL check_date_and_fine; 
drop procedure check_date_and_fine;



# YO:
CREATE VIEW papa AS 
SELECT rental_id FROM rental;

# FULL permite distinguir si es una tabla o una view https://stackoverflow.com/questions/2834016/how-to-get-a-list-of-mysql-views
SHOW FULL tables;



# 13.
CREATE ROLE employee;
GRANT select, delete, update ON rental
TO employee;

# Para poder ver los permisos de los usuarios
SELECT * FROM mysql.user;
# O mejor
SHOW GRANTS FOR employee;

# 14.
REVOKE delete ON rental FROM employee;

CREATE ROLE administrator;
GRANT ALL PRIVILEGES ON sakila.* TO administrator;