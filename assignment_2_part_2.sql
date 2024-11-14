----------------- A.2 Modeling and querying with JSON  -----------------

-- Project Partners: Oliver Tausendschoen & Timothy Cassel

------------------------- JSON Queries ------------------------- 

-- (JQ1) Find customers who prefer extra legroom and have submitted feedback with a service rating lower than 3.

WITH merged_tables AS (
    SELECT 
        cp.customer_id,
        cp.preferences -> 'seating' ->> 'extra_legroom' AS is_extra_legroom,
        -- We select the customer rating from the json field 
        (cf.survey ->> 'rating')::int AS customer_rating
    FROM customerPreference cp
    LEFT JOIN CustomerFeedback cf 
        ON cp.customer_id = cf.customer_id
)

-- Select only where the extra_legroom columns is true and customer rating below 3 
SELECT
    * 
FROM merged_tables 
WHERE is_extra_legroom = 'true' AND customer_rating < 3;


WITH maintenances_with_flags AS (
   SELECT
       aml.maintenance_event_log_id,
       aml.maintenance_event_id,
       (aml.maintenance_log->>'date')::DATE AS maintenance_date,
       asl.aircraft_id
   FROM
       AircraftMaintenanceLogs aml
   JOIN maintenanceSlot ms 
       ON aml.maintenance_event_id = ms.maintenance_event_id
   JOIN aircraftSlot asl
       ON ms.slot_id = asl.slot_id
   WHERE
       (aml.maintenance_log->>'date')::DATE >= CURRENT_DATE - INTERVAL '6 months'  -- Filter to last 6 months
)

, flights_after_maintenance AS (
   SELECT 
       f.flight_id,
       f.date_of_flight,
       asl.aircraft_id
   FROM 
       flight f
   JOIN flightSlot fs 
       ON f.flight_id = fs.flight_id
   JOIN aircraftSlot asl
       ON fs.slot_id = asl.slot_id
   JOIN maintenances_with_flags mwf
       ON asl.aircraft_id = mwf.aircraft_id
          AND f.date_of_flight > mwf.maintenance_date  -- Flight occurs after the maintenance date
   WHERE 
       asl.slot_type = 'Flight'
)

, customers_identified AS (
   SELECT 
       DISTINCT c.customer_id
   FROM flights_after_maintenance fam
   JOIN trip t 
       ON fam.flight_id = t.flight_id
   JOIN booking b
       ON t.booking_id = b.booking_id 
   JOIN customer c 
       ON b.customer_id = c.customer_id
)

-- Output final average ratings for the customers 
SELECT 
	ROUND(AVG((survey->>'rating')::INTEGER),2) AS avg_rating,
    ROUND(AVG((survey->'topics'->>'comfort')::INTEGER),2) AS avg_comfort,
    ROUND(AVG((survey->'topics'->>'service')::INTEGER),2) AS avg_service,
    ROUND(AVG((survey->'topics'->>'cleanliness')::INTEGER),2) AS avg_cleanliness,
    ROUND(AVG((survey->'topics'->>'entertainment')::INTEGER),2) AS avg_entertainment
FROM customerfeedback cf
JOIN customers_identified ci
ON cf.customer_id = ci.customer_id;

-- The outcome of this is ~3 for each rating. This makes a lot of sense since we randomly generate data between 1-5 rating and hence over a large enough sample, this should be equal to 3 fof course.
-- Our DGP does not know about the influence of maintenance logs, and hence this does not affect rating. 




-- (JQ3) Find customers who have not provided feedback but have specific preferences (e.g., vegetarian meals).
WITH merged_tables_3 AS (
    SELECT 
        cp.customer_id,
        cp.preferences -> 'meal' AS meal_preferences,
        (cf.survey ->> 'rating')::int AS customer_rating
    FROM customerPreference cp
    LEFT JOIN CustomerFeedback cf 
        ON cp.customer_id = cf.customer_id
)

SELECT
    m.customer_id,
    c.customer_name,
    m.meal_preferences,
    m.customer_rating
FROM merged_tables_3 m 
LEFT JOIN customer c 
	on m.customer_id = c.customer_id
WHERE m.customer_rating IS NULL;


-- (JQ4) Find the most common customer preferences (e.g., meal, seating) for customers who rated their flight 5 stars in overall feedback.
-- For each of, meal preferences, and seat preferences we find the most common one and union them to present the findings in one table

WITH cust_with_high_rating AS (
    SELECT 
        cf.customer_id,
        (cf.survey ->> 'rating')::int AS customer_rating
    FROM CustomerFeedback cf 
    WHERE (cf.survey ->> 'rating')::int = 5
)

-- Most common meal preference
(SELECT 
    'meal' AS preference_type,
    cp.preferences ->> 'meal' AS most_common_preference_value,
    COUNT(*) AS preference_count
FROM cust_with_high_rating hr
INNER JOIN customerPreference cp 
    ON hr.customer_id = cp.customer_id 
GROUP BY most_common_preference_value
ORDER BY preference_count DESC
LIMIT 1)

UNION ALL

-- Most common extra legroom preference
(SELECT 
    'extra_legroom' AS preference_type,
    cp.preferences -> 'seating' ->> 'extra_legroom' AS most_common_preference_value,
    COUNT(*) AS preference_count
FROM cust_with_high_rating hr
INNER JOIN customerPreference cp 
    ON hr.customer_id = cp.customer_id 
GROUP BY most_common_preference_value
ORDER BY preference_count DESC
LIMIT 1)

UNION ALL

-- Most common seat near exit preference
(SELECT 
    'seat_near_exit' AS preference_type,
    cp.preferences -> 'seating' ->> 'seat_near_exit' AS most_common_preference_value,
    COUNT(*) AS preference_count
FROM cust_with_high_rating hr
INNER JOIN customerPreference cp 
    ON hr.customer_id = cp.customer_id 
GROUP BY most_common_preference_value
ORDER BY preference_count DESC
LIMIT 1)

UNION ALL

-- Most common aisle seat preference
(SELECT 
    'aisle' AS preference_type,
    cp.preferences -> 'seating' ->> 'aisle' AS most_common_preference_value,
    COUNT(*) AS preference_count
FROM cust_with_high_rating hr
INNER JOIN customerPreference cp 
    ON hr.customer_id = cp.customer_id 
GROUP BY most_common_preference_value
ORDER BY preference_count DESC
LIMIT 1);

---------------------------------------------------------------------------------------------------------
-------------------------------------------------- END --------------------------------------------------
---------------------------------------------------------------------------------------------------------