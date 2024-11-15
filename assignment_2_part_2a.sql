----------------- A.2 Modeling and querying with JSON  -----------------

-- Project Partners: Oliver Tausendschoen & Timothy Cassel

------------------------- Part (a) JSON Tables ------------------------- 

DROP TABLE IF EXISTS CustomerPreference CASCADE; 
DROP TABLE IF EXISTS AircraftMaintenanceLogs CASCADE; 
DROP TABLE IF EXISTS CustomerFeedback CASCADE; 


-- Customer Preferences Table 
CREATE TABLE IF NOT EXISTS CustomerPreference (
 	customer_preference_id INT PRIMARY KEY,
 	customer_id INT REFERENCES Customer(customer_id) ON DELETE CASCADE,
 	preferences JSONB
);


-- Aircraft Maintenace Logs Table 
CREATE TABLE IF NOT EXISTS AircraftMaintenanceLogs (
	maintenance_event_log_id INT PRIMARY KEY,
	maintenance_event_id INT REFERENCES MaintenanceEvent(maintenance_event_id) ON DELETE CASCADE,
	maintenance_log JSONB
	
);

-- Customer Feedback Table 
CREATE TABLE IF NOT EXISTS CustomerFeedback (
	feedback_id INT PRIMARY KEY,
	customer_id INT REFERENCES Customer(customer_id) ON DELETE CASCADE,
	survey JSONB
);