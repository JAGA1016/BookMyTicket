--Add a new railway station
CREATE OR REPLACE PROCEDURE add_railway_station(
    in_name VARCHAR(100),
    in_city VARCHAR(100),
    in_state VARCHAR(100)
)
AS $$
BEGIN
    INSERT INTO railway_station(name, city, state)
    VALUES (in_name, in_city, in_state);
    -- COMMIT;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

-- Add a new schedule for a new route
CREATE OR REPLACE PROCEDURE add_schedule(
    in_name VARCHAR(100),
    in_seats INT[],
    in_seat_types SEAT_TYPE[],
    in_week_days DAYS[],
    in_stations VARCHAR(100)[],
    in_arr_time DAY_TIME_Format[],
    in_dep_time DAY_TIME_Format[],
    in_fares NUMERIC(7, 2)[]
)
AS $$
DECLARE
    in_train_no INT;
    in_station_ids INT[] := ARRAY[]::INT[];
    num_stations INT;
    num_seats INT;
    seat_rec RECORD;
    sch_rec RECORD;
    journey_len INT;
    num_week_days INT;
BEGIN
    -- Assuming `Admin` will also give the arr. time for src_station and dep. time for dest station
    -- Initially giving delay_time as 0 to all the schedules

    -- Input validation
    ASSERT ARRAY_LENGTH(in_stations, 1) = ARRAY_LENGTH(in_arr_time, 1), 'Number of stations and arrival times do not match';
    ASSERT ARRAY_LENGTH(in_stations, 1) = ARRAY_LENGTH(in_dep_time, 1), 'Number of stations and departure times do not match';
    ASSERT ARRAY_LENGTH(in_stations, 1) = ARRAY_LENGTH(in_fares, 1), 'Number of stations and fares for each station do not match';
    ASSERT ARRAY_LENGTH(in_seats, 1) = ARRAY_LENGTH(in_seat_types, 1), 'Number of seats and seat types do not match';

    -- Storing lengths of arrays
    num_stations := ARRAY_LENGTH(in_stations, 1);
    num_seats := ARRAY_LENGTH(in_seats, 1);
    num_week_days := ARRAY_LENGTH(in_week_days, 1);

    ASSERT num_week_days > 0, 'No week days specified!';

    -- Input validation for timings and fare
    FOR i IN 1 .. num_stations LOOP
        IF in_dep_time[i] < in_arr_time[i] THEN
            RAISE EXCEPTION 'Departure time of the station "%" cannot be before arrival time', in_stations[i];
        END IF;
        IF in_dep_time[i] >= in_arr_time[i + 1] THEN
            RAISE EXCEPTION 'Departure time of the station "%" is greater than arrival time of the next station', in_stations[i];
        END IF;
        IF in_fares[i] >= in_fares[i + 1] THEN
            RAISE EXCEPTION 'Fare of the station "%" is greater than the fare of next station', in_stations[i];
        END IF;
    END LOOP;

	-- validating days
    SELECT (in_dep_time[ARRAY_LENGTH(in_dep_time, 1)].day_of_journey - 1)
    INTO journey_len;

    ASSERT journey_len <= 7 , 'Journey length cannot be more than 7 days';

    IF (num_week_days > 1) THEN
        FOR i IN 1 .. (num_week_days - 1) LOOP
            ASSERT ((in_week_days[i + 1] @- in_week_days[i]) > (journey_len)), 'Given running days of the train in incorrect';
        END LOOP;
    	ASSERT ((in_week_days[1] @- in_week_days[num_week_days]) > (journey_len)), 'Given running days of the train in incorrect';
    END IF;

    -- Get the station ids corresponding to station names
    FOR i IN 1 .. num_stations LOOP
        in_station_ids[i] := (
            SELECT get_station_id(in_stations[i])
        );
    END LOOP;

    -- Insert and make a new train
    INSERT INTO train(
            name,
            src_station_id,
            dest_station_id,
            total_seats,
            week_days
        )
    VALUES (
            in_name,
            in_station_ids[1],
            in_station_ids[num_stations],
            num_seats,
            in_week_days
        )
    RETURNING train_no INTO in_train_no;

    -- Insert the schedule
    FOR i IN 1 .. num_stations LOOP
        INSERT INTO schedule(
                train_no,
                curr_station_id,
                next_station_id,
                arr_time,
                dep_time,
                fare,
                delay_time
            )
        VALUES (
                in_train_no,
                in_station_ids[i],
                in_station_ids[i + 1],
                in_arr_time[i],
                in_dep_time[i],
                in_fares[i],
                INTERVAL '0'
            );
    END LOOP;

    -- Insert the seats
    FOR i IN 1 .. num_seats LOOP
        INSERT INTO seat(
                seat_no,
                train_no,
                seat_type
            )
        VALUES (
                in_seats[i],
                in_train_no,
                in_seat_types[i]
            );
    END LOOP;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;

   --Update train status
CREATE OR REPLACE PROCEDURE update_train_status(
  	train_name VARCHAR(100),
  	station_name VARCHAR(100),
  	in_delay INTERVAL
)
AS $$
DECLARE
	train_id INT;
	station_id INT;
BEGIN
	SELECT get_train_no(train_name)
    INTO train_id;

	SELECT get_station_id(station_name)
    INTO station_id;

	UPDATE schedule
	SET delay_time = in_delay
	WHERE train_no = train_id
		AND curr_station_id = station_id;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;
