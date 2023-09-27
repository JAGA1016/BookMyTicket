-- User Defined Types
CREATE TYPE DAYS AS ENUM (
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
);
CREATE TYPE dml_type AS ENUM ('INSERT','UPDATE','DELETE');

CREATE TYPE SEAT_TYPE AS ENUM ('AC', 'NON-AC');

CREATE TYPE Ticket_Status AS ENUM('Waiting', 'Confirmed', 'Cancelled');

CREATE TYPE DAY_TIME_Format AS (
    day_of_journey INT,  -- Max value is 7
    time TIME
);
Create type seat_info as (
    available_ac int ,
    available_non_ac int
);

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "intarray";




--- operators

--  DAY_TIME_Format <= DAY_TIME_Format
CREATE OR REPLACE FUNCTION le_day_time(dt1 DAY_TIME_Format, dt2 DAY_TIME_Format)
RETURNS BOOL
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF dt1.day_of_journey < dt2.day_of_journey THEN
        RETURN TRUE;
    ELSEIF dt1.day_of_journey > dt2.day_of_journey THEN
        RETURN FALSE;
    ELSE
        IF dt1.time < dt2.time THEN
            RETURN TRUE;
        ELSEIF dt1.time > dt2.time THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END IF;

END;
$$;

CREATE OPERATOR <= (
    function = le_day_time,
    LEFTARG = DAY_TIME_Format,
    RIGHTARG = DAY_TIME_Format
);


--  DAY_TIME_Format < DAY_TIME_Format
CREATE OR REPLACE FUNCTION lt_day_time(dt1 DAY_TIME_Format, dt2 DAY_TIME_Format)
RETURNS BOOL
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF dt1."day_of_journey" < dt2."day_of_journey" THEN
        RETURN TRUE;
    ELSEIF dt1."day_of_journey" > dt2."day_of_journey" THEN
        RETURN FALSE;
    ELSE
        IF dt1.time < dt2.time THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END IF;

END;
$$;

CREATE OPERATOR < (
    function = lt_day_time,
    LEFTARG = DAY_TIME_Format,
    RIGHTARG = DAY_TIME_Format
);


-- DAYS + INT = DAYS
CREATE OR REPLACE FUNCTION addToDay(day DAYS, diff INT)
RETURNS DAYS
LANGUAGE PLPGSQL
AS $$
DECLARE
    sum INT := 0;
    result DAYS;
BEGIN
    IF (day = 'Monday') THEN sum := 0;
    ELSEIF (day = 'Tuesday') THEN sum := 1;
    ELSEIF (day = 'Wednesday') THEN sum := 2;
    ELSEIF (day = 'Thursday') THEN sum := 3;
    ELSEIF (day = 'Friday') THEN sum := 4;
    ELSEIF (day = 'Saturday') THEN sum := 5;
    ELSE  sum := 6;
    END IF;

    sum := (sum + diff) % 7;

    IF (sum = 0) THEN result := 'Monday';
    ELSEIF  (sum = 1) THEN result := 'Tuesday';
    ELSEIF  (sum = 2) THEN result := 'Wednesday';
    ELSEIF  (sum = 3) THEN result := 'Thursday';
    ELSEIF  (sum = 4) THEN result := 'Friday';
    ELSEIF  (sum = 5) THEN result := 'Saturday';
    ELSE  result := 'Sunday';
    END IF;

    RETURN result;
END;
$$;


CREATE OPERATOR @+ (
    FUNCTION = addToDay,
    LEFTARG = DAYS,
    RIGHTARG = INT
);


-- DAYS - DAYS = INT
-- Considering Day1 > Day2
CREATE OR REPLACE FUNCTION day_diff(day1 DAYS, day2 DAYS)
RETURNS INT
LANGUAGE PLPGSQL
AS $$
DECLARE
    d1 INT := 0;
    d2 INT := 0;
    result INT := 0;
BEGIN
    IF (day1 = 'Monday') THEN d1 := 0;
    ELSEIF (day1 = 'Tuesday') THEN d1 := 1;
    ELSEIF (day1 = 'Wednesday') THEN d1 := 2;
    ELSEIF (day1 = 'Thursday') THEN d1 := 3;
    ELSEIF (day1 = 'Friday') THEN d1 := 4;
    ELSEIF (day1 = 'Saturday') THEN d1 := 5;
    ELSE  d1 := 6;
    END IF;

    IF (day2 = 'Monday') THEN d2 := 0;
    ELSEIF (day2 = 'Tuesday') THEN d2 := 1;
    ELSEIF (day2 = 'Wednesday') THEN d2 := 2;
    ELSEIF (day2 = 'Thursday') THEN d2 := 3;
    ELSEIF (day2 = 'Friday') THEN d2 := 4;
    ELSEIF (day2 = 'Saturday') THEN d2 := 5;
    ELSE  d2 := 6;
    END IF;

    result := (d1 - d2 + 7) % 7;

    RETURN result;
END;
$$;

CREATE OPERATOR @- (
    FUNCTION = day_diff,
    LEFTARG = DAYS,
    RIGHTARG = DAYS
);
