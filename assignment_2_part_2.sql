DROP TABLE IF EXISTS CustomerPreference CASCADE; 
DROP TABLE IF EXISTS AircraftMaintenanceLogs CASCADE; 
DROP TABLE IF EXISTS CustomerFeedback CASCADE; 


CREATE TABLE IF NOT EXISTS CustomerPreference (
 	customer_preference_id INT PRIMARY KEY,
 	customer_id INT REFERENCES Customer(customer_id) ON DELETE CASCADE,
 	preferences JSONB
);

CREATE TABLE IF NOT EXISTS AircraftMaintenanceLogs (
	maintenance_event_log_id INT PRIMARY KEY,
	maintenance_event_id INT REFERENCES MaintenanceEvent(maintenance_event_id) ON DELETE CASCADE,
	maintenance_log JSONB
	
);

CREATE TABLE IF NOT EXISTS CustomerFeedback (
	feedback_id INT PRIMARY KEY,
	customer_id INT REFERENCES Customer(customer_id) ON DELETE CASCADE,
	survey JSONB
);


-- Insert example into Customer Preferences 
INSERT INTO CustomerPreference (customer_preference_id, customer_id, preferences) VALUES 
(1, 1, '{"meal": "vegetarian", "seating": {"aisle": true, "extra_legroom": true, "seat_near_exit": false}, "notifications": {"email": true, "sms": false}}'::jsonb),
(2, 2, '{"meal": "non-vegetarian", "seating": {"aisle": false, "extra_legroom": false, "seat_near_exit": true}, "notifications": {"email": false, "sms": true}}'::jsonb),
(3, 3, '{"meal": "vegan", "seating": {"aisle": true, "extra_legroom": false, "seat_near_exit": true}, "notifications": {"email": true, "sms": false}}'::jsonb),
(4, 4, '{"meal": "kosher", "seating": {"aisle": false, "extra_legroom": true, "seat_near_exit": false}, "notifications": {"email": true, "sms": false}}'::jsonb),
(5, 5, '{"meal": "vegetarian", "seating": {"aisle": true, "extra_legroom": true, "seat_near_exit": true}, "notifications": {"email": false, "sms": true}}'::jsonb),
(6, 6, '{"meal": "non-vegetarian", "seating": {"aisle": false, "extra_legroom": true, "seat_near_exit": true}, "notifications": {"email": true, "sms": false}}'::jsonb),
(7, 7, '{"meal": "vegan", "seating": {"aisle": true, "extra_legroom": false, "seat_near_exit": false}, "notifications": {"email": false, "sms": true}}'::jsonb),
(8, 8, '{"meal": "kosher", "seating": {"aisle": false, "extra_legroom": true, "seat_near_exit": true}, "notifications": {"email": true, "sms": true}}'::jsonb),
(9, 9, '{"meal": "vegetarian", "seating": {"aisle": true, "extra_legroom": true, "seat_near_exit": false}, "notifications": {"email": false, "sms": true}}'::jsonb),
(10, 10, '{"meal": "non-vegetarian", "seating": {"aisle": false, "extra_legroom": false, "seat_near_exit": true}, "notifications": {"email": true, "sms": false}}'::jsonb);

             

-- Insert example into Maintenance Logs 
INSERT INTO AircraftMaintenanceLogs (maintenance_event_log_id, maintenance_event_id, maintenance_log) VALUES 
(1, 1, '{"date": "2024-06-24", "check_type": "Full Inspection", "components_checked": [{"name": "Engine", "status": "Operational", "last_replaced": "2023-12-01"}, {"name": "Hydraulics", "status": "Requires Service", "last_replaced": "2024-03-12"}]}'::jsonb),
(2, 2, '{"date": "2024-02-10", "check_type": "Routine Check", "components_checked": [{"name": "Engine", "status": "Operational", "last_replaced": "2023-10-01"}, {"name": "Wings", "status": "Operational", "last_replaced": "2024-01-10"}]}'::jsonb),
(3, 3, '{"date": "2023-07-14", "check_type": "Safety Audit", "components_checked": [{"name": "Hydraulics", "status": "Requires Service", "last_replaced": "2023-12-01"}, {"name": "Wings", "status": "Operational", "last_replaced": "2023-08-05"}]}'::jsonb),
(4, 4, '{"date": "2024-01-05", "check_type": "Full Inspection", "components_checked": [{"name": "Engine", "status": "Requires Service", "last_replaced": "2023-11-10"}, {"name": "Hydraulics", "status": "Operational", "last_replaced": "2023-09-01"}]}'::jsonb),
(5, 5, '{"date": "2023-04-20", "check_type": "Routine Check", "components_checked": [{"name": "Wings", "status": "Requires Service", "last_replaced": "2023-10-15"}, {"name": "Hydraulics", "status": "Operational", "last_replaced": "2024-04-01"}]}'::jsonb),
(6, 6, '{"date": "2023-03-10", "check_type": "Safety Audit", "components_checked": [{"name": "Engine", "status": "Operational", "last_replaced": "2024-02-11"}, {"name": "Hydraulics", "status": "Requires Service", "last_replaced": "2023-07-23"}]}'::jsonb),
(7, 7, '{"date": "2024-08-24", "check_type": "Full Inspection", "components_checked": [{"name": "Wings", "status": "Operational", "last_replaced": "2023-11-01"}, {"name": "Engine", "status": "Requires Service", "last_replaced": "2023-06-01"}]}'::jsonb),
(8, 8, '{"date": "2023-09-10", "check_type": "Routine Check", "components_checked": [{"name": "Hydraulics", "status": "Operational", "last_replaced": "2024-05-01"}, {"name": "Engine", "status": "Requires Service", "last_replaced": "2024-03-10"}]}'::jsonb),
(9, 9, '{"date": "2023-10-02", "check_type": "Safety Audit", "components_checked": [{"name": "Engine", "status": "Operational", "last_replaced": "2024-04-12"}, {"name": "Wings", "status": "Requires Service", "last_replaced": "2023-10-02"}]}'::jsonb),
(10, 10, '{"date": "2024-05-15", "check_type": "Full Inspection", "components_checked": [{"name": "Engine", "status": "Requires Service", "last_replaced": "2023-08-10"}, {"name": "Hydraulics", "status": "Operational", "last_replaced": "2024-02-01"}]}'::jsonb);



-- Insert example into Customer Feedback 
INSERT INTO CustomerFeedback (feedback_id, customer_id, survey) VALUES 
(1,1,   '{"survey_date": "2024-06-24", "rating": 5, "comments": "Great service, but could improve seating comfort.", "topics": {"comfort": 4, "service": 5, "cleanliness": 3, "entertainment": 2}}'::jsonb),
(2,2,   '{"survey_date": "2023-07-14", "rating": 5, "comments": "Flight was on time, but entertainment options were lacking.", "topics": {"comfort": 5, "service": 4, "cleanliness": 4, "entertainment": 3}}'::jsonb),
(3,3,   '{"survey_date": "2023-03-28", "rating": 4, "comments": "Friendly staff and clean aircraft.", "topics": {"comfort": 4, "service": 4, "cleanliness": 4, "entertainment": 1}}'::jsonb),
(4,5, '{"survey_date": "2024-01-31", "rating": 2, "comments": "Smooth check-in process, but meals could be better.", "topics": {"comfort": 2, "service": 3, "cleanliness": 4, "entertainment": 1}}'::jsonb),
(5,7,  '{"survey_date": "2023-04-20", "rating": 4, "comments": "Overall a good experience.", "topics": {"comfort": 5, "service": 4, "cleanliness": 3, "entertainment": 2}}'::jsonb),
(6,8,  '{"survey_date": "2023-10-13", "rating": 3, "comments": "Friendly staff but limited entertainment.", "topics": {"comfort": 3, "service": 4, "cleanliness": 4, "entertainment": 1}}'::jsonb),
(7,9, '{"survey_date": "2024-03-15", "rating": 5, "comments": "Good flight, would recommend.", "topics": {"comfort": 5, "service": 5, "cleanliness": 5, "entertainment": 4}}'::jsonb),
(8,10,  '{"survey_date": "2023-06-12", "rating": 3, "comments": "Average experience, could improve seating comfort.", "topics": {"comfort": 3, "service": 4, "cleanliness": 3, "entertainment": 2}}'::jsonb),
(9,11,  '{"survey_date": "2024-02-18", "rating": 4, "comments": "Service was good, but food could improve.", "topics": {"comfort": 4, "service": 4, "cleanliness": 5, "entertainment": 2}}'::jsonb),
(10,12, '{"survey_date": "2023-11-25", "rating": 5, "comments": "Excellent overall, very satisfied.", "topics": {"comfort": 5, "service": 5, "cleanliness": 5, "entertainment": 5}}'::jsonb);

            
            
-- (JQ1) Find customers who prefer extra legroom and have submitted feedback with a service rating lower than 3.

WITH merged_tables AS (
    SELECT 
        cp.customer_id,
        cp.preferences -> 'seating' ->> 'extra_legroom' AS is_extra_legroom,
        (cf.survey ->> 'rating')::int AS customer_rating
    FROM customerPreference cp
    LEFT JOIN CustomerFeedback cf 
        ON cp.customer_id = cf.customer_id
)
SELECT
    * 
FROM merged_tables 
WHERE is_extra_legroom = 'true' AND customer_rating < 3;
 
-- (JQ2) Identify flights that used aircraft with maintenance issues flagged within the last 6 months and correlate them with customer feedback on comfort.




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
    c.customer_name
FROM merged_tables_3 m 
LEFT JOIN customer c 
	on m.customer_id = c.customer_id
WHERE m.customer_rating IS NULL


-- (JQ4) Find the most common customer preferences (e.g., meal, seating) for customers who rated their flight 5 stars in overall feedback.

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
LEFT JOIN customerPreference cp 
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
LEFT JOIN customerPreference cp 
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
LEFT JOIN customerPreference cp 
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
LEFT JOIN customerPreference cp 
    ON hr.customer_id = cp.customer_id 
GROUP BY most_common_preference_value
ORDER BY preference_count DESC
LIMIT 1);







