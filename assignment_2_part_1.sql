----------------- A.1 Querying with SQL  ----------------
--------------------  SQL Queries ----------------------- 

-- Project Partners: Oliver Tausendschoen & Timothy Cassel

----------------------------------------------------------------------------------------------------------------
-- Query 1: Find customers who have made at least one booking in the last month and their booking details.
----------------------------------------------------------------------------------------------------------------

select
	c.*,
	b.*
from customer c
left join booking b
	on c.customer_id = b.booking_id
where created_at >= date_trunc('day', NOW() - interval '1 month');

----------------------------------------------------------------------------------------------------------------
-- Query 2: List all flights with delayed or canceled status, including flight crew details and aircraft assigned.
----------------------------------------------------------------------------------------------------------------
select
	f.flight_id,
	a.aircraft_id,
	f.flight_status,
	f.number_of_passengers,
	f.number_of_cabin_crew,
	f.number_of_flight_crew,
	a.aircraft_type,
	a.capacity
from flight f
left join flightslot fs
	on fs.flight_id = f.flight_id
left join aircraftslot asl
	on asl.slot_id = fs.slot_id
left join aircraft a
	on asl.aircraft_id = a.aircraft_id
where flight_status in ('delayed', 'canceled');

----------------------------------------------------------------------------------------------------------------
-- SQL Query 3: Get the total number of miles accumulated by a frequent flyer along with their upcoming bookings.
----------------------------------------------------------------------------------------------------------------

SELECT
   c.customer_id,
   c.customer_name,
   c.miles AS total_miles,
   COUNT(b.booking_id) AS upcoming_bookings
FROM
   Customer c
LEFT join
	Booking b
	on b.customer_id =c.customer_id
WHERE
   c.frequent_flyer = TRUE
   --AND b.created_at >= NOW()  -- Only include future bookings
GROUP BY
   c.customer_id,
   c.customer_name,
   c.miles
ORDER BY
   total_miles DESC;


----------------------------------------------------------------------------------------------------------------
-- SQL Query 4: Find flights departing in the next 7 days that are operated by a specific aircraft model but are not yet fully booked.
----------------------------------------------------------------------------------------------------------------

SELECT
   f.*,
   fs.*,
   asl.*,
   a.*
FROM
   flight f
LEFT JOIN
   flightslot fs
   ON fs.flight_id = f.flight_id
LEFT JOIN
   aircraftslot asl
   ON asl.slot_id = fs.slot_id
LEFT JOIN
   aircraft a
   ON asl.aircraft_id = a.aircraft_id
WHERE
   f.date_of_flight BETWEEN date_trunc('day', NOW()) AND date_trunc('day', NOW() + interval '7 days')
   and a.aircraft_id = 99 --SPECIFY AIRCRAFT MODEL HERE
   and a.capacity - f.number_of_passengers > 0;


----------------------------------------------------------------------------------------------------------------  
-- SQL Query 5: Generate a report of flights where maintenance schedules have con-flicted with the assigned aircraft.
----------------------------------------------------------------------------------------------------------------
  SELECT
   f.slot_id AS flight_slot_id,
   f.aircraft_id,
   f.start_time AS flight_start,
   f.end_time AS flight_end,
   m.slot_id AS maintenance_slot_id,
   m.start_time AS maintenance_start,
   m.end_time AS maintenance_end
FROM
   AircraftSlot f
JOIN
   AircraftSlot m ON f.aircraft_id = m.aircraft_id
WHERE
   f.slot_type = 'Flight'
   AND m.slot_type = 'Maintenance'
   AND (
       (f.start_time BETWEEN m.start_time AND m.end_time)
       OR
       (f.end_time BETWEEN m.start_time AND m.end_time)
       OR
       (m.start_time BETWEEN f.start_time AND f.end_time)
       OR
       (m.end_time BETWEEN f.start_time AND f.end_time)
   )
ORDER BY
   f.aircraft_id, f.start_time;
  
----------------------------------------------------------------------------------------------------------------
-- SQL Query 6: Calculate the revenue generated by each flight, including payment status for all bookings made.
----------------------------------------------------------------------------------------------------------------
  
SELECT
   f.flight_id,
   f.date_of_flight,
   SUM(b.price) AS total_revenue,
   COUNT(b.booking_id) AS total_bookings,
   COUNT(CASE WHEN b.payment_status = true THEN 1 END) AS paid_bookings,
   COUNT(CASE WHEN b.payment_status != true THEN 1 END) AS unpaid_bookings
FROM
   flight f
LEFT JOIN
   trip t
   ON t.flight_id = f.flight_id
LEFT JOIN
   booking b
   ON b.booking_id = t.booking_id
GROUP BY
   f.flight_id, f.date_of_flight
ORDER BY
   f.date_of_flight;
  
----------------------------------------------------------------------------------------------------------------
-- SQL Query 7: Find customers who have never booked a flight.
----------------------------------------------------------------------------------------------------------------
SELECT
   c.customer_id,
   c.customer_name,
   c.email
FROM
   customer c
LEFT JOIN
   booking b
   ON b.customer_id = c.customer_id
WHERE
   b.booking_id IS NULL;  -- Only customers with no bookings

   
----------------------------------------------------------------------------------------------------------------
-- SQL Query 8:Get flights that are fully booked (i.e., no available seats).
----------------------------------------------------------------------------------------------------------------
   
SELECT
   f.flight_id,
   f.date_of_flight,
   f.number_of_passengers,
   a.aircraft_id,
   a.capacity
FROM
   flight f
LEFT JOIN
   flightslot fs ON fs.flight_id = f.flight_id
LEFT JOIN
   aircraftslot asl ON asl.slot_id = fs.slot_id
LEFT JOIN
   aircraft a ON asl.aircraft_id = a.aircraft_id
WHERE
   f.number_of_passengers = a.capacity; -- NO cases (due to fake data not generating this exact case)
   

----------------------------------------------------------------------------------------------------------------
-- SQL Query 9: Find frequent flyers who have flown the most miles but haven’t made any bookings in the past year.
----------------------------------------------------------------------------------------------------------------
   
SELECT
   c.customer_id,
   c.customer_name ,
   c.miles,
   c.frequent_flyer
FROM
   customer c
left join
	booking b
	on c.customer_id =b.customer_id
LEFT JOIN
   trip t
   ON t.booking_id = b.booking_id
LEFT JOIN
   flight f
   ON t.flight_id = f.flight_id
WHERE
   c.frequent_flyer = TRUE
   AND c.miles > 0
   AND (
       -- No bookings in the past year
       b.created_at IS NULL
       OR b.created_at < NOW() - INTERVAL '1 year'
   )
ORDER BY
   c.miles DESC;


----------------------------------------------------------------------------------------------------------------   
-- SQL Query 10: Get the total Bookings and Revenue Generated per Month.
----------------------------------------------------------------------------------------------------------------
  
SELECT
   TO_CHAR(b.created_at , 'YYYY-MM') AS month,
   COUNT(b.booking_id) AS total_bookings,
   SUM(b.price) AS total_revenue
FROM
   booking b
LEFT JOIN
   trip t
   ON b.booking_id = t.booking_id
LEFT JOIN
   flight f
   ON t.flight_id = f.flight_id
GROUP BY
   TO_CHAR(b.created_at, 'YYYY-MM')
ORDER BY
   month DESC;
  
  
----------------------------------------------------------------------------------------------------------------
-- SQL Query 11: Get the top 5 Most Popular Flight Routes.
----------------------------------------------------------------------------------------------------------------
  
SELECT
   f.departure_airport AS departure_airport,
   f.arrival_airport AS arrival_airport,
   COUNT(t.trip_id) AS number_of_flights
FROM
   trip t
LEFT JOIN
   flight f ON t.flight_id = f.flight_id
GROUP BY
   f.departure_airport,
   f.arrival_airport
ORDER BY
   number_of_flights DESC
LIMIT 5;


----------------------------------------------------------------------------------------------------------------
-- SQL Query 12: Show how active frequent flyers have been, summarizing their total miles, number of bookings, and total money spent
----------------------------------------------------------------------------------------------------------------
SELECT
   c.customer_id,
   c.customer_name ,
   c.miles AS total_miles,
   COUNT(b.booking_id) AS number_of_bookings,
   SUM(b.price) AS total_money_spent
FROM
   customer c
LEFT JOIN
   booking b ON c.customer_id = b.customer_id
LEFT JOIN
   trip t ON t.booking_id = b.booking_id
WHERE
   c.frequent_flyer = TRUE
GROUP BY
   c.customer_id, c.customer_name, c.miles
ORDER BY
   total_money_spent DESC;

   
---------------------------------------------------------------------------------------------------------
-------------------------------------------------- END --------------------------------------------------
---------------------------------------------------------------------------------------------------------