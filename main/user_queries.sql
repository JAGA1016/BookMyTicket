-- Users can book tickets for multiple passengers
CREATE OR REPLACE PROCEDURE book_tickets(
    in_name VARCHAR(100)[],
    in_age INT[],
    in_seat_type SEAT_TYPE[],
    src_station VARCHAR(100),
    dest_station VARCHAR(100),
    train_name VARCHAR(100),
    in_date DATE
)
AS $$
DECLARE
    fare INT;
    src_id INT;
    dest_id INT;
    train_number INT;
    in_user_id INT;
    temp_id UUID;
    num_names INT;
    in_pid UUID;
BEGIN
    -- Input validation
    ASSERT ARRAY_LENGTH(in_name, 1) = ARRAY_LENGTH(in_age, 1), 'Number of names and age for the passengers do not match';
    ASSERT ARRAY_LENGTH(in_name, 1) = ARRAY_LENGTH(in_seat_type, 1), 'Number of names and seats for the passengers do not match';

	-- Extracting different variables
    SELECT get_user_id(SESSION_USER::VARCHAR(100))
    INTO in_user_id ;

    SELECT get_train_no(train_name)
    INTO train_number;

    SELECT get_station_id(src_station)
    INTO src_id;

    SELECT get_station_id(dest_station)
    INTO dest_id;

    -- Check if the train runs on the day of the booking
    PERFORM validate_train_days_at_station(src_id, train_number, in_date);

    -- Get cost of the ticket
    SELECT get_fare(train_name, src_station, dest_station)
    INTO fare;

    -- Storing lengths of arrays
    SELECT ARRAY_LENGTH(in_name, 1)
    INTO num_names;

    FOR i IN 1 .. num_names LOOP
        -- Create new passenger
        INSERT INTO passenger(
                name,
                age
            )
        VALUES (
                in_name[i],
                in_age[i]
            )
        RETURNING pid INTO in_pid;

        -- Create tickets for each passenger with initial booking_status as 'Waiting'
        INSERT INTO ticket(
                cost,
                src_station_id,
                dest_station_id,
                train_no,
                user_id,
                date,
                pid,
                seat_type
            )
        VALUES (
                fare,
                src_id,
                dest_id,
                train_number,
                in_user_id,
                in_date,
                in_pid,
                in_seat_type[i]
            );
    END LOOP;

	-- COMMIT;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;


-- Cancel booking
CREATE OR REPLACE PROCEDURE cancel_booking(in_pnr int)
AS $$
BEGIN
    -- DEPRECATED CODE
	-- Update reservation table
	-- UPDATE reservation
	-- SET pnr = NULL,
	-- 	booked = FALSE
	-- WHERE pnr = in_pnr;

    PERFORM validate_pnr(in_pnr);

	-- Update ticket table
	UPDATE ticket
	SET booking_status = 'Cancelled',
        seat_id = NULL
	WHERE pnr = in_pnr;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

   -- Select appropriate train(s) for a given source and destination and date
CREATE OR REPLACE FUNCTION get_trains(
    src_station VARCHAR(100),
    dest_station VARCHAR(100),
    in_date DATE
)
RETURNS TABLE (
    train_no INT,
    train_name VARCHAR(100),
    seats_available seat_info,
    Total_seats int
)
AS $$
DECLARE
    src_id INT;
    dest_id INT;
    in_day DAYS;
    AC_total_seats seat_info;
    AC_booked_seats int;
BEGIN
	-- Get train Number
    SELECT get_station_id(src_station)
    INTO src_id;

    SELECT get_station_id(dest_station)
    INTO dest_id;

    SELECT get_day(in_date)
    INTO in_day;

    RETURN QUERY
		SELECT train.train_no,
            train.name,
            num_seats_available_from_src_to_dest(
                train.name,
                src_station,
                dest_station,
                in_date
            ) AS seats_available, train.total_seats  AS Total_seats
		FROM train,
            schedule as s1,
            schedule as s2
		WHERE s1.curr_station_id = src_id
            AND s2.curr_station_id = dest_id
            AND s1.dep_time < s2.arr_time
            AND s1.train_no = s2.train_no
            AND train.train_no = s1.train_no
            AND in_day = ANY(get_days_at_station(src_id, train.train_no));
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

-- Given a train give a schedule for it
CREATE OR REPLACE FUNCTION get_train_schedule(train_name VARCHAR(100))
RETURNS TABLE (
    current_station TEXT,
    next_station TEXT,
    arrival_time TIME,
    departure_time TIME,
    arrival_days TEXT,
    departure_days TEXT,
    delay_time INTERVAL
)
AS $$
DECLARE
    train_number INT;
BEGIN
	-- Get train Number
    SELECT get_train_no(train_name)
    INTO train_number;

    RETURN QUERY
        SELECT st.current_station,
            st.next_station,
            st.arrival_time,
            st.departure_time,
            st.arrival_days,
            st.departure_days,
            st.delay_time
        FROM stations_trains AS st
        WHERE st.train_no = train_number;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

-- Given station name get all trains schedule passing through that station
CREATE OR REPLACE FUNCTION get_trains_schedule_at_station(in_station_name VARCHAR(100))
RETURNS TABLE(
    train_no INT,
    train_name VARCHAR(100),
    source_station TEXT,
    next_station TEXT,
    destination_station TEXT,
    arrival_time TIME,
    departure_time TIME,
    arrival_days TEXT,
    departure_days TEXT,
    delay_time INTERVAL,
    total_seats INT,
    week_days DAYS[]
)
AS $$
DECLARE
    in_station_id INT;
BEGIN
    -- Get station id
    SELECT get_station_id(in_station_name)
    INTO in_station_id;

    RETURN QUERY
        SELECT st.train_no,
            st.train_name,
            st.source_station,
            st.next_station,
            st.destination_station,
            st.arrival_time,
            st.departure_time,
            st.arrival_days,
            st.departure_days,
            st.delay_time,
            st.total_seats,
            st.week_days
        FROM stations_trains AS st
        WHERE st.curr_station_id = in_station_id;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

-- Fare of the train route for a particular train from source to destination
CREATE OR REPLACE FUNCTION get_fare(
  	train_name VARCHAR(100),
  	src_station VARCHAR(100),
  	dest_station VARCHAR(100)
)
RETURNS INT
AS $$
DECLARE
	train_number INT;
    src_id INT;
    dest_id INT;
    total_fare INT;
    src_fare INT;
    dest_fare INT;
BEGIN
    SELECT get_train_no(train_name)
    INTO train_number;

    SELECT get_station_id(src_station)
    INTO src_id;

    SELECT get_station_id(dest_station)
    INTO dest_id;

    SELECT fare
    INTO src_fare
    FROM schedule
    WHERE curr_station_id = src_id
    	AND train_no = train_number;

    SELECT fare
    INTO dest_fare
    FROM schedule
    WHERE curr_station_id = dest_id
    	AND train_no = train_number;

    SELECT dest_fare - src_fare
    INTO total_fare;

    RETURN total_fare;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

-- 8. For a given PNR, give details of the journey and the passenger.
CREATE OR REPLACE FUNCTION get_passenger_details(in_pnr int)
RETURNS TABLE(
    pnr int,
    pid UUID,
    passenger_name VARCHAR(100),
    passenger_age INT,
    train_no INT,
    train_name VARCHAR(100),
    source_station TEXT,
    destination_station TEXT,
    date DATE,
    cost INT,
    user_name VARCHAR(100),
    user_email VARCHAR(100),
    user_mobile VARCHAR(20),
    booking_status Ticket_Status,
    seat_no INT,
    seat_type SEAT_TYPE
)
AS $$
BEGIN
    PERFORM validate_pnr(in_pnr);

    RETURN QUERY
        WITH temp_table AS (
            SELECT *
            FROM ticket as tic
            WHERE tic.pnr = in_pnr
        )
        SELECT t.pnr,
            t.pid,
            p.name AS passenger_name,
            p.age AS passenger_age,
            t.train_no,
            tr.name AS train_name,
            rs1.name, || ', ' || rs1.city || ', ' || rs1.state AS source_station,
            rs2.name, || ', ' || rs2.city || ', ' || rs2.state AS destination_station,
            t.date,
            t.cost,
            u.username AS user_name,
            u.email_id AS user_email,
            u.mobile_no AS user_mobile,
            t.booking_status,
            s.seat_no,
            s.seat_type
        FROM temp_table AS t
            JOIN passenger AS p ON t.pid = p.pid
            JOIN train AS tr ON t.train_no = tr.train_no
            JOIN railway_station AS rs1 ON rs1.station_id = t.src_station_id
            JOIN railway_station AS rs2 ON rs2.station_id = t.dest_station_id
            JOIN users AS u ON u.user_id = t.user_id
            LEFT JOIN seat AS s ON s.seat_id = t.seat_id;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

-- 9. No. of seats available for a particular train from src to dest on a particular date
CREATE OR REPLACE FUNCTION num_seats_available_from_src_to_dest(
    in_train_name VARCHAR(100),
    in_src_station_name VARCHAR(100),
    in_dest_station_name VARCHAR(100),
    in_date DATE
)
RETURNS seat_info
AS $$
DECLARE
    in_train_no INT;
    in_src_station_id INT;
    in_dest_station_id INT;
    result INT;
    avail seat_info;
    booked_seats INT;
    sch_ids  integer ARRAY;
    in_total_seats INT;
    AC_booked int;
    Total_ac int;
BEGIN
    SELECT get_train_no(in_train_name)
    INTO in_train_no;
    SELECT get_station_id(in_src_station_name)
    INTO in_src_station_id;
    SELECT get_station_id(in_dest_station_name)
    INTO in_dest_station_id;

    -- Check if the train runs on the day of the booking
    PERFORM validate_train_days_at_station(in_src_station_id, in_train_no, in_date);

    -- Getting the sch_ids
    SELECT get_sch_ids(in_train_no, in_src_station_id, in_dest_station_id)
    INTO sch_ids;

    -- total seats
    SELECT total_seats
    INTO in_total_seats
    FROM train
    WHERE train_no = in_train_no;

    -- total ac seats
     SELECT COUNT(seat_id)
    INTO Total_ac
    FROM seat
    where seat_type = 'AC' AND train_no = in_train_no
    GROUP BY train_no;

    -- booked ac seats 
    SELECT COUNT(DISTINCT seat_id)
    INTO AC_booked
    FROM ticket
    WHERE train_no = in_train_no
        AND booking_status = 'Confirmed'
        AND seat_type = 'AC'
        AND (date - get_journey_at_station(src_station_id, train_no) + 1) =
            (in_date - get_journey_at_station(in_src_station_id, in_train_no) + 1)
        AND ARRAY_LENGTH(
                (get_sch_ids(train_no, src_station_id, dest_station_id) & sch_ids), 1
            ) >= 1;

    -- getting booked_seats values
    SELECT COUNT(DISTINCT seat_id)
    INTO booked_seats
    FROM ticket
    WHERE train_no = in_train_no
        AND booking_status = 'Confirmed'
        AND (date - get_journey_at_station(src_station_id, train_no) + 1) =
            (in_date - get_journey_at_station(in_src_station_id, in_train_no) + 1)
        AND ARRAY_LENGTH(
                (get_sch_ids(train_no, src_station_id, dest_station_id) & sch_ids), 1
            ) >= 1;
    SELECT Total_ac-AC_booked
    INTO avail.available_ac;
    SELECT in_total_seats - booked_seats - avail.available_ac 
    into avail.available_non_ac;
    return avail;
    -- SELECT in_total_seats - booked_seats
    -- INTO result;
    -- RETURN result;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

   -- Get delay time of train at given staion
CREATE OR REPLACE FUNCTION get_train_status(
    train_name VARCHAR(100),
    station_name VARCHAR(100)
)
RETURNS INTERVAL
AS $$
DECLARE
    in_train_no INT;
    in_station_id INT;
    train_status INTERVAL;
BEGIN
    -- Get the train no
    SELECT get_train_no(train_name)
    INTO in_train_no;

    -- Get the station id
    SELECT get_station_id(station_name)
    INTO in_station_id;

    -- Get the train status
    SELECT delay_time
    INTO train_status
    FROM schedule
    WHERE train_no = in_train_no
        AND curr_station_id = in_station_id;

    RETURN train_status;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;




