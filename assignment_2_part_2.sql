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


-- (JQ2) Identify flights that used aircraft with maintenance issues flagged within the last 6 months and correlate them with customer feedback on comfort. WHAT IS MEANT BY CORRELATE?
WITH maintenance_dates AS (
   SELECT
       aml.maintenance_event_log_id,
       aml.maintenance_event_id,
       (aml.maintenance_log->>'date')::DATE AS maintenance_date
   FROM
       AircraftMaintenanceLogs aml
   WHERE
   		(aml.maintenance_log->>'date')::DATE >= CURRENT_DATE - INTERVAL '6 months'  -- Filter to last 6 months


)

,flight_dates AS (
   SELECT
       fs.flight_id,
       fs.date_of_flight,
       fs.flight_status
   FROM
       Flight fs
)

SELECT
   fd.flight_id,
   fd.date_of_flight,
   md.maintenance_event_id,
   md.maintenance_date
FROM
   flight_dates fd
JOIN
   maintenance_dates md ON fd.date_of_flight = md.maintenance_date
ORDER BY
   fd.date_of_flight;


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