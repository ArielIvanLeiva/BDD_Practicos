USE world;

# 1.
SELECT city.Name, cityCountry.Name
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
	
# 5.
SELECT 