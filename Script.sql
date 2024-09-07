USE world;

# 1. NOTA: Está bueno agregar los renombres (sobretodo cuando no se va a usar la tabla)
SELECT city.Name AS City, cityCountry.Name AS Country
FROM city
INNER JOIN 
			(SELECT country.Name, country.Code FROM country WHERE country.Population < 10000) 
			AS cityCountry 
ON cityCountry.Code = city.CountryCode;


# 2.
WITH my_avg (value) AS (
	SELECT AVG(Population)
	FROM city
)
SELECT Name, Population
FROM city, my_avg
WHERE city.Population > my_avg.value;

# 2. Otra forma:
WITH my_avg (value) AS (
	SELECT AVG(Population)
	FROM city
)
SELECT Name, Population
FROM city
INNER JOIN my_avg
ON city.Population > my_avg.value;


# 3.
WITH asi_country (Population) AS (
	SELECT DISTINCT Population
	FROM country
	WHERE country.Continent = 'Asia'
)
SELECT DISTINCT city.Name
FROM city
INNER JOIN asi_country
ON city.Population >= asi_country.Population;

# 3. Otra forma
SELECT DISTINCT city.Name
FROM city
WHERE city.Population >= SOME (SELECT DISTINCT Population
	FROM country
	WHERE country.Continent = 'Asia');


# 4.
SELECT country.Name, cl.Language
FROM country
INNER JOIN countrylanguage as cl
ON (cl.IsOfficial != 'T' AND country.Code = cl.CountryCode)
WHERE cl.Percentage > ALL (
		SELECT cl_official.Percentage
		FROM countrylanguage as cl_official
		WHERE (cl_official.IsOfficial = 'T' AND country.Code = cl_official.CountryCode) 
	);


# Comando útil: 
DESCRIBE country;
# 5. Con subquery
SELECT DISTINCT country.Region
FROM country
INNER JOIN city
ON city.CountryCode = country.Code 
WHERE country.SurfaceArea < 1000 AND EXISTS (
		  SELECT city.Name
		  FROM city
		  WHERE	(city.CountryCode = country.Code AND city.Population > 100000)
	  );

# 5. Sin subquery. OBSERVACIÓN: Sirve bastante tener en cuenta la correspondencia de cardinalidades.
SELECT DISTINCT country.Region
FROM city
INNER JOIN country
ON (country.Code = city.CountryCode AND country.SurfaceArea < 1000 AND city.Population > 100000);

# Otra observación: El INNER JOIN es "simétrico"
SELECT DISTINCT country.Region
FROM country
INNER JOIN city
ON (country.Code = city.CountryCode AND country.SurfaceArea < 1000 AND city.Population > 100000);


# 6.
SELECT country.Name, city.Name, city.Population
FROM city
INNER JOIN country
ON (city.CountryCode = country.Code)
WHERE city.Population = (
	SELECT MAX(country_city.Population)
	FROM city AS country_city
	WHERE country_city.CountryCode = country.Code
	LIMIT 1
);


# AYUDAAAAAAa SELECT country.Name, city.Population
#FROM country; 

#SELECT city.CountryCode, MAX(city.Population)
#FROM city
#GROUP BY city.Population;

# 7.
SELECT country.Name, countrylanguage.Language
FROM country
INNER JOIN countrylanguage
ON (countrylanguage.CountryCode = country.Code AND countrylanguage.IsOfficial != 'T')
WHERE countrylanguage.Percentage > (
	SELECT AVG(countrylanguage.Percentage)
	FROM countrylanguage
	WHERE (countrylanguage.CountryCode = country.Code AND countrylanguage.IsOfficial = 'T')
	LIMIT 1
);

# 8.
SELECT country.Region, SUM(Population) as Population
FROM country
GROUP BY country.Region;

# 9. OBSERVACIÓN: El WHERE se aplica ANTES de que se calcule el promedio (sobre el dataset inicial)
SELECT country.Region, AVG(country.LifeExpectancy)
FROM country
WHERE 40 <= country.LifeExpectancy AND country.LifeExpectancy <= 70
GROUP BY country.Region;

# 9, Esto, a diferencia de lo anterior, se aplica al valor del promedio (luego del group)
SELECT country.Region, AVG(country.LifeExpectancy) AS AverageLE
FROM country
GROUP BY country.Region
HAVING 40 <= AverageLE AND AverageLE <= 70;

# 10.
SELECT country.Region, MIN(Population), MAX(Population), SUM(Population)
FROM country
GROUP BY country.Region;