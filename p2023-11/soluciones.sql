USE olympics;

# 1.
SELECT city.city_name, games.games_year
FROM city
INNER JOIN games_city
ON games_city.city_id = city.id
INNER JOIN games
ON games.id = games_city.games_id
WHERE games.season = 'Summer'
GROUP BY city.id, games.games_year
ORDER BY games.games_year DESC;

SELECT c.city_name, g.games_year
FROM city AS c
INNER JOIN games_city AS gc ON c.id = gc.city_id
INNER JOIN games AS g ON gc.games_id = g.id
WHERE g.season = 'Summer'
GROUP BY c.id
ORDER BY g.games_year DESC;

# 2. OJOOOOOO: No olvidar dejar solo lo que se pide en la query
SELECT noc_region.region_name
FROM noc_region
INNER JOIN person_region
ON person_region.region_id = noc_region.id
INNER JOIN person
ON person.id = person_region.person_id
INNER JOIN games_competitor
ON games_competitor.person_id = person.id
INNER JOIN competitor_event
ON competitor_event.competitor_id = games_competitor.id
INNER JOIN medal
ON medal.id = competitor_event.medal_id
INNER JOIN event
ON event.id = competitor_event.event_id
INNER JOIN sport
ON sport.id = event.sport_id
WHERE medal.medal_name = 'Gold' AND sport.sport_name = 'Football'
GROUP BY noc_region.id
ORDER BY COUNT(medal.id) DESC
LIMIT 10;


# 3.
WITH max_value() AS (
    SELECT MAX()
	FROM city AS country_city
	WHERE country_city.CountryCode = country.Code
	LIMIT 1
);

# La subquery es básicamente una lista de la cantidad de personas que participaron
# en un determinado juego olímpico
WITH num_of_participations(id, region_name, participations) AS
    (SELECT participants_by_game.id, participants_by_game.region_name, COUNT(participants_by_game.id) FROM (
            SELECT noc_region.id, noc_region.region_name
            FROM
                noc_region
                INNER JOIN person_region ON person_region.region_id = noc_region.id
                INNER JOIN person ON person.id = person_region.person_id
                INNER JOIN games_competitor ON games_competitor.person_id = person.id
                INNER JOIN games ON games.id = games_competitor.games_id
            GROUP BY
                noc_region.id, games.id
        ) AS participants_by_game
    GROUP BY participants_by_game.id)
SELECT (
    SELECT num_of_participations.region_name
    FROM num_of_participations
    WHERE num_of_participations.participations = (
	    SELECT MAX(num_of_participations.participations)
	    FROM num_of_participations
	    LIMIT 1
    )
    LIMIT 1
) AS most, (
    SELECT num_of_participations.region_name
    FROM num_of_participations
    WHERE num_of_participations.participations = (
	    SELECT MIN(num_of_participations.participations)
	    FROM num_of_participations
	    LIMIT 1
    )
    LIMIT 1
    ) AS least
;


# 4.
CREATE VIEW info_pais AS
SELECT region_name, sport_name, gold, silver, bronze, na FROM (SELECT
    region_id,
    region_name,
    sport_id,
    sport_name,
    SUM(CASE WHEN region_participations.medal_name='Gold' THEN 1 ELSE 0 END) AS gold,
    SUM(CASE WHEN region_participations.medal_name='Silver' THEN 1 ELSE 0 END) AS silver,
    SUM(CASE WHEN region_participations.medal_name='Bronze' THEN 1 ELSE 0 END) AS bronze,
    SUM(CASE WHEN region_participations.medal_name='NA' THEN 1 ELSE 0 END) AS na
    
FROM (
        SELECT noc_region.id as region_id, noc_region.region_name, sport.id AS sport_id, sport_name, medal.medal_name as medal_name
        FROM
            noc_region
            INNER JOIN person_region ON person_region.region_id = noc_region.id
            INNER JOIN person ON person.id = person_region.person_id
            INNER JOIN games_competitor ON games_competitor.person_id = person.id
            INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.person_id
            INNER JOIN medal ON medal.id = competitor_event.medal_id
            INNER JOIN event ON event.id = competitor_event.event_id
            INNER JOIN sport ON sport.id = event.sport_id
        GROUP BY
            noc_region.id, sport_id, medal.id
    ) AS region_participations
GROUP BY region_id, sport_id) AS info_deporte;

# 2do intento mío
CREATE VIEW info_medallas AS
SELECT  noc_region.region_name, 
        sport.sport_name, 
        COUNT(IF(medal.id = 1, 1, NULL)) AS gold,
        COUNT(IF(medal.id = 2, 1, NULL)) AS silver, 
        COUNT(IF(medal.id = 3, 1, NULL)) AS bronze, 
        COUNT(IF(medal.id = 4, 1, NULL)) AS na
FROM
    noc_region
    INNER JOIN person_region ON person_region.region_id = noc_region.id
    INNER JOIN person ON person.id = person_region.person_id
    INNER JOIN games_competitor ON games_competitor.person_id = person.id
    INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
    INNER JOIN medal ON medal.id = competitor_event.medal_id
    INNER JOIN event ON event.id = competitor_event.event_id
    INNER JOIN sport ON sport.id = event.sport_id
    GROUP BY noc_region.id, sport.id;

# Probando si esta otra sintaxis está bien
CREATE VIEW info_medallas2 AS
SELECT  noc_region.region_name, 
        sport.sport_name, 
        COUNT(CASE WHEN medal.id = 1 THEN 1 END) AS gold,
        COUNT(CASE WHEN medal.id = 2 THEN 1 END) AS silver, 
        COUNT(CASE WHEN medal.id = 3 THEN 1 END) AS bronze, 
        COUNT(CASE WHEN medal.id = 4 THEN 1 END) AS na
FROM
    noc_region
    INNER JOIN person_region ON person_region.region_id = noc_region.id
    INNER JOIN person ON person.id = person_region.person_id
    INNER JOIN games_competitor ON games_competitor.person_id = person.id
    INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
    INNER JOIN medal ON medal.id = competitor_event.medal_id
    INNER JOIN event ON event.id = competitor_event.event_id
    INNER JOIN sport ON sport.id = event.sport_id
    GROUP BY noc_region.id, sport.id;

select * from medallas;
select * from info_medallas;
select * from info_medallas2;
select * from info_pais;
drop view info_pais;
drop view info_medallas;
drop view info_medallas2;


# 5.
DELIMITER $$
CREATE PROCEDURE get_total_medals(IN region_name varchar(200))
BEGIN
	SELECT SUM(gold), SUM(silver), SUM(bronze)
    FROM info_medallas2
    INNER JOIN noc_region
    ON info_medallas2.region_name = noc_region.region_name
    WHERE noc_region.region_name = region_name
    GROUP BY noc_region.id;
END $$

DELIMITER;
drop PROCEDURE get_total_medals;
CALL get_total_medals('Albania');

SELECT * FROM noc_region;

# 6.
# a.
ALTER TABLE event
ADD COLUMN sport_name varchar(200);
UPDATE event
INNER JOIN sport ON sport.id = event.sport_id
SET event.sport_name = sport.sport_name;

# b.
SHOW CREATE TABLE event;
ALTER TABLE event
DROP FOREIGN KEY fk_ev_sp;
ALTER TABLE event
DROP COLUMN sport_id;

# c.
DROP TABLE sport;