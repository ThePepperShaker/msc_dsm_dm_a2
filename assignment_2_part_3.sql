---------------------------------
--- Assignment 2: Task 3 - Q1 ---
---------------------------------

CREATE OR REPLACE FUNCTION check_maintenance_schedule()
RETURNS TRIGGER AS $$
DECLARE
    assigned_aircraft_id INT;
    flight_start TIMESTAMPTZ;
    flight_end TIMESTAMPTZ;
BEGIN
    -- Fetch the aircraft_id and flight times directly from AircraftSlot and Flight
    SELECT asl.aircraft_id, 
           (f.date_of_flight::TIMESTAMPTZ + f.actual_departure_time::INTERVAL) AS flight_start,
           (f.date_of_flight::TIMESTAMPTZ + f.actual_arrival_time::INTERVAL) AS flight_end
    INTO assigned_aircraft_id, flight_start, flight_end
    FROM AircraftSlot asl
    JOIN Flight f ON f.flight_id = NEW.flight_id
    WHERE asl.slot_id = NEW.slot_id;

    RAISE NOTICE 'Aircraft ID: %, Flight Start: %, Flight End: %', 
                  assigned_aircraft_id, flight_start, flight_end;

    -- Ensure aircraft_id was found
    IF assigned_aircraft_id IS NULL THEN
        RAISE EXCEPTION 'No aircraft found for slot_id %. Check data integrity.', NEW.slot_id;
    END IF;

    -- Check for overlapping maintenance schedules
    IF EXISTS (
        SELECT 1
        FROM AircraftSlot asl
        JOIN MaintenanceSlot ms ON asl.slot_id = ms.slot_id
        WHERE asl.aircraft_id = assigned_aircraft_id
          AND asl.slot_type = 'Maintenance'
          AND (flight_start, flight_end) OVERLAPS (asl.start_time, asl.end_time)
    ) THEN
        -- Raise an error if a conflict exists
        RAISE EXCEPTION 'Aircraft % is scheduled for maintenance and cannot be assigned to this flight.', assigned_aircraft_id;
    ELSE
        RAISE NOTICE 'No maintenance conflict for Aircraft ID: %', assigned_aircraft_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



-- Step 2: Create the Trigger on the FlightSlot Table
DROP TRIGGER IF EXISTS before_flight_slot_insert_or_update ON FlightSlot;
CREATE TRIGGER before_flight_slot_insert_or_update
BEFORE INSERT OR UPDATE ON FlightSlot
FOR EACH ROW
EXECUTE FUNCTION check_maintenance_schedule();



-- Testing our trigger with data insertion 

-- Drop rows 
DELETE FROM MaintenanceEvent WHERE maintenance_event_id = -2;
DELETE FROM AIRCRAFT WHERE aircraft_id = -2;
DELETE FROM MAINTENANCESLOT WHERE slot_id = -2;
delete FROM AIRCRAFTSLOT WHERE aircraft_id = -2;
delete FROM FLIGHT WHERE flight_id = -2;
--DROP FROM FLIGHTSLOT WHERE aircraft_id = -3



INSERT INTO Aircraft (aircraft_id, aircraft_type, aircraft_company, capacity) 
VALUES (-2, 'Boeing 737', 'Test Airline', 180);

INSERT INTO MaintenanceEvent (maintenance_event_id, maintenance_type, airport, subsystem)
VALUES (-2, 'Scheduled', 'JFK', 'Engine');

INSERT INTO AircraftSlot (slot_id, aircraft_id, slot_type, start_time, end_time)
VALUES (-2, -2, 'Maintenance', '2024-01-01 08:00:00', '2024-01-01 20:00:00');

INSERT INTO MaintenanceSlot (slot_id, maintenance_event_id, is_scheduled)
VALUES (-2, -2, TRUE);

INSERT INTO Flight (flight_id, departure_airport, arrival_airport, flight_status, date_of_flight, actual_departure_time, actual_arrival_time)
VALUES (-2, 'JFK', 'LAX', 'scheduled', '2024-01-01', '10:00:00', '15:00:00');

-- Insert a new slot for the flight
INSERT INTO AircraftSlot (slot_id, aircraft_id, slot_type, start_time, end_time)
VALUES (-3, -2, 'Flight', '2024-01-01 10:00:00', '2024-01-01 15:00:00');

-- Attempt to assign the new flight slot (should raise an exception)
INSERT INTO FlightSlot (slot_id, flight_id)
VALUES (-3, -2);  -- This should raise an exception




---------------------------------
--- Assignment 2: Task 3 - Q2 ---
---------------------------------
CREATE TABLE IF NOT EXISTS CustomerFeedbackArchive (
    feedback_id INT PRIMARY KEY,
    customer_id INT,
    survey JSONB,
    archived_at TIMESTAMPTZ DEFAULT NOW() 
);



-- Function to archive old feedback 
CREATE OR REPLACE FUNCTION archive_old_feedback()
RETURNS TRIGGER AS $$
DECLARE
    archived_count INT;  -- Variable to store the number of archived rows
BEGIN
    -- Move feedback older than 2 years to the archive table
    INSERT INTO CustomerFeedbackArchive (feedback_id, customer_id, survey, archived_at)
    SELECT feedback_id, customer_id, survey, NOW()
    FROM CustomerFeedback
    WHERE (survey->>'survey_date')::DATE < CURRENT_DATE - INTERVAL '2 years';

    -- Get the number of rows affected by the INSERT
    GET DIAGNOSTICS archived_count = ROW_COUNT;

    -- Log a notice about the archiving
    IF archived_count > 0 THEN
        RAISE NOTICE '% feedback entries older than 2 years were archived.', archived_count;
    ELSE
        RAISE NOTICE 'No feedback entries older than 2 years to archive.';
    END IF;

    -- Delete the old feedback from the main table
    DELETE FROM CustomerFeedback
    WHERE (survey->>'survey_date')::DATE < CURRENT_DATE - INTERVAL '2 years';

    -- Allow the new feedback to be inserted
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;




-- Create the function on the original table 
DROP TRIGGER IF EXISTS before_insert_feedback ON CustomerFeedback;
CREATE TRIGGER before_insert_feedback
BEFORE INSERT ON CustomerFeedback
FOR EACH ROW
EXECUTE FUNCTION archive_old_feedback();


-- Test the trigger 
delete from customer where customer_id in (-1,-2,-3);
delete from customerfeedback where customer_id in (-1,-2,-3);
delete from customerFeedbackArchive where customer_id in (-1, -2);

-- Insert some new test customers
INSERT INTO Customer (customer_id, customer_name, email, phone_number, address)
VALUES 
(-1, 'test guy', 'testguy@email.com', '012345678', 'test, 123, Barcelona'),
(-2, 'test girl', 'testgirl@email.com', '012345679', 'test, 456, Barcelona'),
(-3, 'test kid', 'testkid@email.com', '012345674', 'test, 789, Barcelona');

-- Insert old customer feedback for them 
INSERT INTO CustomerFeedback (feedback_id, customer_id, survey)
VALUES
(-1, -1, '{"survey_date": "2021-01-01", "rating": 5, "comments": "Great!"}'::jsonb),
(-2, -2, '{"survey_date": "2022-01-01", "rating": 4, "comments": "Good"}'::jsonb),
(-3, -3, '{"survey_date": "2024-01-01", "rating": 5, "comments": "Excellent"}'::jsonb);


-- Check the CustomerFeedbackArchive table to verify that the two entries have been moved
select * 
from customerfeedbackarchive;


