-- Confirm the status and allocate a seat to the ticket of the passenger
CREATE OR REPLACE PROCEDURE allocate_seat(
    in_pnr int,
    in_train_name VARCHAR(100),
    in_src_station_name VARCHAR(100),
    in_dest_station_name VARCHAR(100),
    in_date DATE,
    in_seat_type SEAT_TYPE
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    in_train_no INT;
    in_src_station_id INT;
    in_dest_station_id INT;
    sch_ids INT[] := ARRAY[]::INT[];
    reservation_info RECORD;
    val INT;
    tmp_seat_id INT;
    idx INT;
    in_total_seats INT;
    -- debug_cnt INT := 0;
    in_days DAYS;
    tmp_seat_type SEAT_TYPE;
BEGIN
    -- Getting the declared values
    SELECT get_train_no(in_train_name)
    INTO in_train_no;

    SELECT get_station_id(in_src_station_name)
    INTO in_src_station_id;

    SELECT get_station_id(in_dest_station_name)
    INTO in_dest_station_id;

    -- RAISE NOTICE 'src_station_id %, dest_station_id %, in_seat_type %', in_src_station_id, in_dest_station_id, in_seat_type;

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

    -- RAISE NOTICE 'total_seats %, sch_ids %', in_total_seats, sch_ids;

    -- Create a tmp table for reservation
    CREATE TEMPORARY TABLE reservation (
        sch_id INT,
        seat_id INT,
        res_seat_type SEAT_TYPE,
        booked BOOLEAN
    );

    CREATE INDEX temp_res_sch ON reservation USING HASH(sch_id);
    CREATE INDEX temp_res_seat_id ON reservation USING HASH(seat_id);

    -- Add all possible pairs of schedule_id and seat_id to the tmp table
    -- TODO: Try to make this short
    FOR idx IN 1 .. in_total_seats
    LOOP
        FOREACH val IN ARRAY sch_ids
        LOOP
            SELECT seat_type
            INTO tmp_seat_type
            FROM seat
            WHERE train_no = in_train_no
            AND seat_no = idx;

            INSERT INTO reservation(sch_id, seat_id, res_seat_type, booked)
            VALUES (val, idx, tmp_seat_type, False);
        END LOOP;
    END LOOP;
    
    -- Updating booked values
    FOR reservation_info IN (SELECT src_station_id AS travel_src_station,
                                dest_station_id AS travel_dest_station,
                                seat_id
                            FROM ticket
                            WHERE (date - get_journey_at_station(src_station_id, train_no) + 1) =
                                (in_date - get_journey_at_station(in_src_station_id, in_train_no) + 1)
                                AND train_no = in_train_no
                                AND booking_status = 'Confirmed'
                                AND seat_type = in_seat_type
                            )
    LOOP
        FOREACH val IN ARRAY get_sch_ids(
                                in_train_no,
                                reservation_info.travel_src_station,
                                reservation_info.travel_dest_station
                            )
        LOOP
            UPDATE reservation
            SET booked = True
            WHERE sch_id = val
                AND seat_id = reservation_info.seat_id
                AND res_seat_type = in_seat_type;
            -- debug_cnt := debug_cnt + 1;
            -- RAISE NOTICE 'inside loop seat_id %, sch_id %', reservation_info."seat_id", val;
        END LOOP;

    END LOOP;

    -- Now selecting best seat out of all the empty seats
    SELECT seat_id
    INTO tmp_seat_id
    FROM reservation
    GROUP BY seat_id
    HAVING seat_id IN (
        -- all empty seats as written above
        -- (in the current range)
        SELECT seat_id
        FROM reservation
        WHERE (sch_id = ANY(sch_ids))
            AND res_seat_type = in_seat_type
        GROUP BY seat_id
        HAVING COALESCE(SUM((booked)::INT), 0) = 0
    )
    ORDER BY COALESCE(SUM(booked::INT), 0) DESC
    LIMIT 1;

    -- RAISE NOTICE 'best seat %', tmp_seat_id;

    IF tmp_seat_id IS NOT NULL THEN
        UPDATE ticket
        SET booking_status = 'Confirmed',
            seat_id = tmp_seat_id,
            seat_type = in_seat_type
        WHERE pnr = in_pnr;
    END IF;
    
    DROP TABLE reservation;
END;
$$;


-- Add a new user
CREATE OR REPLACE PROCEDURE add_user(
  	in_name VARCHAR(100),
  	in_email VARCHAR(100),
    in_password VARCHAR(100),
  	in_age INT,
  	in_mobile VARCHAR(20)
)
AS $$
BEGIN
	INSERT INTO users(username, email_id,password, age, mobile_no)
    VALUES (in_name, in_email,in_password, in_age, in_mobile);

    EXECUTE FORMAT($f$CREATE USER %I IN GROUP users PASSWORD '%s'$f$, in_email, in_password);

    -- COMMIT;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;