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
SELECT EXTRACT(MONTH FROM '2020-03-01');