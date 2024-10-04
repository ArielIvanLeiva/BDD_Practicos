# 1.
ALTER TABLE person
ADD COLUMN total_medals INT DEFAULT 0;

# 2.
WITH
    person_medals (person_id, total_medals) AS (
        SELECT person.id, COUNT(medal.id)
        FROM
            person
            INNER JOIN games_competitor ON games_competitor.person_id = person.id
            INNER JOIN competitor_event ON competitor_event.competitor_id = games_competitor.id
            INNER JOIN medal ON medal.id = competitor_event.medal_id
        WHERE
            medal.id != 4
        GROUP BY
            person.id
    )
UPDATE person
INNER JOIN person_medals
ON person_medals.person_id = person.id
SET person.total_medals = person_medals.total_medals;
SELECT * from medal;


# para verificar
SELECT person.full_name, COUNT(medal.id), person.total_medals
FROM person
INNER JOIN games_competitor
ON games_competitor.person_id = person.id
INNER JOIN competitor_event
ON competitor_event.competitor_id = games_competitor.id
INNER JOIN medal
ON medal.id = competitor_event.medal_id
WHERE medal.id != 4
GROUP BY person.id
HAVING person.full_name LIKE 'Michael fred%';

# 3.
SELECT person.full_name, medal.medal_name, COUNT(medal.id)
FROM medal
INNER JOIN competitor_event ON competitor_event.medal_id = medal.id
INNER JOIN games_competitor ON games_competitor.id = competitor_event.competitor_id
INNER JOIN person ON person.id = games_competitor.person_id
INNER JOIN person_region ON person_region.person_id = person.id
INNER JOIN noc_region ON noc_region.id = person_region.region_id
WHERE noc_region.id = 9 AND medal.id != 4
GROUP BY person.id, medal.id;

# 4.
SELECT sport.sport_name, COUNT(medal.id)
FROM medal
INNER JOIN competitor_event ON competitor_event.medal_id = medal.id
INNER JOIN games_competitor ON games_competitor.id = competitor_event.competitor_id
INNER JOIN person ON person.id = games_competitor.person_id
INNER JOIN person_region ON person_region.person_id = person.id
INNER JOIN noc_region ON noc_region.id = person_region.region_id
INNER JOIN event ON event.id = competitor_event.event_id
INNER JOIN sport ON sport.id = event.sport_id
# ID de Argentina
WHERE noc_region.id = 9
GROUP BY noc_region.id, sport.id;

# Haciendo que se consideren los deportes sin medallas
SELECT sport.sport_name, COUNT(medal.id)
FROM competitor_event
LEFT JOIN medal ON medal.id = competitor_event.medal_id 
INNER JOIN games_competitor ON games_competitor.id = competitor_event.competitor_id
INNER JOIN person ON person.id = games_competitor.person_id
INNER JOIN person_region ON person_region.person_id = person.id
INNER JOIN noc_region ON noc_region.id = person_region.region_id
INNER JOIN event ON event.id = competitor_event.event_id
INNER JOIN sport ON sport.id = event.sport_id
# ID de Argentina
WHERE noc_region.id = 9
GROUP BY noc_region.id, sport.id
ORDER BY sport.id;

SELECT * from sport;