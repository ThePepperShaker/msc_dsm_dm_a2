DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Aircraft CASCADE;
DROP TABLE IF EXISTS AircraftSlot CASCADE;
DROP TABLE IF EXISTS FlightSlot CASCADE;
DROP TABLE IF EXISTS MaintenanceSlot CASCADE;
DROP TABLE IF EXISTS MaintenanceEvent CASCADE;
DROP TABLE IF EXISTS ScheduledMaintenanceEvent CASCADE;
DROP TABLE IF EXISTS UnscheduledMaintenanceEvent CASCADE;
DROP TABLE IF EXISTS WorkOrderAOS CASCADE;
DROP TABLE IF EXISTS WorkOrderOI CASCADE;
DROP TABLE IF EXISTS Trip CASCADE;
DROP TABLE IF EXISTS CustomerPreference CASCADE; 
DROP TABLE IF EXISTS AircraftMaintenanceLogs CASCADE; 
DROP TABLE IF EXISTS CustomerFeedback CASCADE; 


----------------- Task 2: Create Tables of the database -----------------

-- Create the Customers table containing customer data, uniquely identified by the customer_id
CREATE TABLE IF NOT EXISTS Customer (
   customer_id INT PRIMARY KEY,
   customer_name VARCHAR(50) NOT NULL,
   email VARCHAR(100) NOT NULL UNIQUE,
   phone_number BIGINT NOT NULL,
   address VARCHAR(255),
   frequent_flyer boolean,
   miles int NULL
);


-- Create the Aircrafts table containing aircraft inventory data and is uniquely identified by the aircraft_id (registration_nr)
CREATE TABLE IF NOT EXISTS Aircraft  (
    aircraft_id INT PRIMARY KEY, -- This is the registration_nr of the aircraft 
    aircraft_type VARCHAR(100) NOT NULL,
    aircraft_company VARCHAR(100),
    capacity INT NOT NULL
);

-- Create the AircraftSlots table containing the slots 
CREATE TABLE IF NOT EXISTS AircraftSlot ( 
    slot_id INT PRIMARY KEY,
    aircraft_id INT REFERENCES Aircraft(aircraft_id) ON DELETE CASCADE,
    slot_type VARCHAR(20) CHECK (slot_type IN ('Flight', 'Maintenance')),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL
);

-- Create the Flights table 
CREATE TABLE IF NOT EXISTS Flight (
    flight_id INT PRIMARY KEY, -- is the flight number
    departure_airport VARCHAR(100) NOT NULL,
    arrival_airport VARCHAR(100) NOT NULL,
    delay_code VARCHAR(10),
    number_of_passengers INT,
    number_of_cabin_crew INT,
    number_of_flight_crew INT,
    flight_status VARCHAR(20) NOT NULL, -- (scheduled, delayed, canceled)
    date_of_flight DATE,
    actual_departure_time TIME,
    actual_arrival_time TIME,
    -- Additional checks to ensure non-negativity of certain columns
    CHECK (number_of_passengers >= 0),
	CHECK (number_of_cabin_crew >= 0),
	CHECK (number_of_flight_crew >= 0)
);

-- Create the FlightSlots table containing only the flight slots 
CREATE TABLE IF NOT EXISTS FlightSlot ( 
    slot_id INTEGER PRIMARY KEY REFERENCES AircraftSlot(slot_id),
    flight_id INT REFERENCES Flight(flight_id) ON DELETE CASCADE
);

-- Create the Bookings table 
CREATE TABLE IF NOT EXISTS Booking (
    booking_id INT PRIMARY KEY,
    customer_id INT REFERENCES Customer(customer_id) ON DELETE CASCADE,
    seat_class VARCHAR(50),
    price NUMERIC(10, 2),
    payment_status BOOLEAN,
    booking_status VARCHAR(20),
    is_roundtrip BOOLEAN,
    number_passengers INT,
    created_at TIMESTAMPTZ, -- To store when a booking is made
    updated_at TIMESTAMPTZ -- To store when a booking is updated (e.g. a status change)
);

-- Create the Trip table 
CREATE TABLE IF NOT EXISTS Trip (
	trip_id INT PRIMARY KEY,
	booking_id INT REFERENCES Booking(booking_id) ON DELETE CASCADE,
	flight_id INT REFERENCES Flight(flight_id) ON DELETE CASCADE
);

-- Create the Maintenance Event table 
CREATE TABLE IF NOT EXISTS MaintenanceEvent (
	maintenance_event_id INT PRIMARY KEY,
	maintenance_type VARCHAR(20) CHECK (maintenance_type IN ('Scheduled', 'Unscheduled')),
	airport VARCHAR(20),
	subsystem VARCHAR(50)
);

-- Create the Maintenance slot table containing only maintenance slots 
CREATE TABLE IF NOT EXISTS MaintenanceSlot ( 
    slot_id INTEGER PRIMARY KEY REFERENCES AircraftSlot(slot_id),
    maintenance_event_id INT REFERENCES MaintenanceEvent(maintenance_event_id) ON DELETE CASCADE,
    is_scheduled BOOLEAN
);

-- Create the ScheduledMaintenanceEvent table
CREATE TABLE IF NOT EXISTS ScheduledMaintenanceEvent ( 
    scheduled_maintenance_event_id INT PRIMARY KEY REFERENCES MaintenanceEvent(maintenance_event_id) ON DELETE CASCADE,
    duration INTERVAL NOT NULL,
    aos_type VARCHAR(20) NOT NULL CHECK (aos_type IN ('MaintenanceService', 'RevisionService')),
    forecasted_date TIMESTAMPTZ NOT NULL,
    frequency VARCHAR(20),
    CHECK ( -- If the aos_type is RevisionService, then duration must be greater than 24 hours, and if aos_type is MaintenanceService, then duration must be less than 24 hours.
    		-- In case this constraint is not satified, we will get an error.
        (aos_type = 'RevisionService' AND duration IS NOT NULL AND duration > '24 hours'::INTERVAL) OR
        (aos_type = 'MaintenanceService' AND duration IS NOT NULL AND duration < '24 hours'::INTERVAL)
    )
);

-- Create the UnscheduledMaintenanceEvents table
CREATE TABLE IF NOT EXISTS UnscheduledMaintenanceEvent ( 
    unscheduled_maintenance_event_id INT PRIMARY KEY REFERENCES MaintenanceEvent(maintenance_event_id) ON DELETE CASCADE,
    flight_id INT REFERENCES Flight(flight_id) ON DELETE CASCADE,      
    duration INTERVAL,
    oi_type VARCHAR(30) CHECK (oi_type IN ('delayGenerating', 'safetyGenerating')),
    reporter_class VARCHAR(30) CHECK (reporter_class IN ('Pilot', 'Maintenance Personnel')) NOT NULL,
    reporter_id INT NOT NULL,
    reporting_date TIMESTAMPTZ NOT NULL,
    CHECK ( -- for delay generating the duration is known
	    (oi_type = 'safetyGenerating' AND duration IS NULL) OR
	    (oi_type = 'delayGenerating' AND duration IS NOT NULL)
	    )
	);

-- Scheduled Work Orders table
CREATE TABLE IF NOT EXISTS WorkOrderAOS (
    aos_work_order_id INT PRIMARY KEY,
    scheduled_maintenance_event_id INT REFERENCES ScheduledMaintenanceEvent(scheduled_maintenance_event_id) ON DELETE CASCADE,
    task_type VARCHAR(50) NOT NULL,
    execution_date TIMESTAMPTZ NOT NULL,
    number_of_workers INT NOT NULL,
    status VARCHAR(20) CHECK (status IN ('in-progress', 'pending', 'completed')) NOT NULL
);

-- Unscheduled Work Orders table
CREATE TABLE IF NOT EXISTS WorkOrderOI (
    oi_work_order_id INT PRIMARY KEY,
    unscheduled_maintenance_event_id INT REFERENCES UnscheduledMaintenanceEvent(unscheduled_maintenance_event_id) ON DELETE CASCADE,
    required_parts VARCHAR(50),
    estimated_completion_time INT,
    status VARCHAR(20) CHECK (status IN ('in-progress', 'pending', 'completed')) NOT NULL  
);


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
