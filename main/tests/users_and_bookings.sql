-- -- Users
CALL add_user(
    in_name     => 'ravi',
    in_email    => 'ravi@123.com',
    in_password => '123',
    in_age      => 18,
    in_mobile   => '9888887777'
);

CALL add_user('ram', 'ram@123.com', '123', 25, '9777766555');
-- CALL add_user('ghi', 'ghi@ghi.com', 'ghi', 40, '9999999999');
-- CALL add_user('jkl', 'jkl@jkl.com', 'jkl', 31, '9876543210');
-- CALL add_user('mno', 'mno@mno.com', 'mno', 55, '9988776655');



-- -- Bookings

-- -- TC-1
-- -- pqr will in waiting
\c railway_reservation_system ravi@123.com


CALL book_tickets(
    in_name      => ARRAY['ghi', 'jkl']::VARCHAR(100)[],
    in_age       => ARRAY[13, 15]::INT[],
    in_seat_type => ARRAY['AC', 'AC']::SEAT_TYPE[],
    src_station  => 'Howrah_Jn',
    dest_station => 'Kanpur_Central',
    train_name   => 'Intercity',
    in_date      => '2023-05-09'::DATE
);


-- CALL add_schedule(
--     'Intercity'::VARCHAR(100),
--     ARRAY[1, 2, 3]::INT[],
--     ARRAY['AC', 'AC',  'NON-AC']::SEAT_TYPE[],
--     ARRAY[ 'Tuesday', 'Thursday',  'Saturday']::DAYS[],
--     ARRAY[ 'Howrah_Jn', 'Kanpur_Central',  'Guwahati_Jn',  'Lucknow_Jn']::VARCHAR(100)[],
--     ARRAY[(1, '4:00:00'), (1, '19:00:00'),(2,'5:00:00'),(2,'20:00:00')]::DAY_TIME_Format[],
--     ARRAY[(1, '4:10:00'), (1, '19:12:00'),(2,'5:05:00'),(2,'20:34:00')]::DAY_TIME_Format[],
--     ARRAY[0, 220,330,430]::NUMERIC(7, 2)[]
-- );

\c railway_reservation_system ram@123.com

CALL book_tickets(
    in_name      => ARRAY['ghi', 'jkl', 'mno', 'pqr']::VARCHAR(100)[],
    in_age       => ARRAY[13, 15, 17, 19]::INT[],
    in_seat_type => ARRAY['AC', 'AC', 'AC', 'NON-AC']::SEAT_TYPE[],
    src_station  => 'Secunderabad_Jn',
    dest_station => 'Palakkad_jn',
    train_name   => 'Sabari express',
    in_date      => '2023-05-08'::DATE
);

-- CALL cancel_booking(1003);



-- -- TC-2
-- -- same seat as nanu
-- \c railway_reservation_system ghi@ghi.com
-- CALL book_tickets(
--     ARRAY['yogita']::VARCHAR(100)[],
--     ARRAY[35]::INT[],
--     ARRAY['NON-AC']::SEAT_TYPE[],
--     'Kolkata_RS',
--     'Bangalore_RS',
--     'KCBMD',
--     '2022-05-09'::DATE
-- );
-- -- same seat as yogita
-- CALL book_tickets(
--     ARRAY['nanu']::VARCHAR(100)[],
--     ARRAY[30]::INT[],
--     ARRAY['NON-AC']::SEAT_TYPE[],
--     'Bangalore_RS',
--     'Delhi_RS',
--     'KCBMD',
--     '2022-05-09'::DATE
-- );




-- CALL book_tickets(
--     ARRAY['df','ds','ad','ada','ra','pq','qa']::VARCHAR(100)[],
--     ARRAY[20,20,20,20,20,20,20]::INT[],
--     ARRAY['AC', 'AC', 'AC', 'AC', 'AC', 'AC','AC' ]::SEAT_TYPE[],
--     'Palakkad_RS',
--     'Mumbai_RS',
--     'Humsafar_Express',
--     '2023-05-02'::DATE
-- );

-- -- this will be in waiting
-- \c railway_reservation_system mno@mno.com
-- CALL book_tickets(
--     ARRAY['titu']::VARCHAR(100)[],
--     ARRAY[31]::INT[],
--     ARRAY['NON-AC']::SEAT_TYPE[],
--     'Chennai_RS',
--     'Delhi_RS',
--     'KCBMD',
--     '2022-05-09'::DATE
-- );

-- -- TC-3
-- -- u5 will be in waiting
-- CALL book_tickets(
--     ARRAY['u1', 'u2', 'u3', 'u4', 'u5']::VARCHAR(100)[],
--     ARRAY[27, 29, 31, 25, 15]::INT[],
--     ARRAY['AC','NON-AC','NON-AC','NON-AC','NON-AC']::SEAT_TYPE[],
--     'Mumbai_RS',
--     'Delhi_RS',
--     'KMD',
--     '2022-05-10'::DATE
-- );

-- -- TC-4
-- \c railway_reservation_system abc@abc.com
-- CALL book_tickets(  -- Will get seat booked
--     ARRAY['zyx']::VARCHAR(100)[],
--     ARRAY[13]::INT[],
--     ARRAY['AC']::SEAT_TYPE[],
--     'Lucknow_RS'::VARCHAR(100),
--     'Chennai_RS'::VARCHAR(100),
--     'LGCP'::VARCHAR(100),
--     '2022-05-09'::DATE
-- );

-- \c railway_reservation_system mno@mno.com
-- CALL book_tickets(  -- Will get seat booked
--     ARRAY['wvu']::VARCHAR(100)[],
--     ARRAY[29]::INT[],
--     ARRAY['AC']::SEAT_TYPE[],
--     'Gujarat_RS'::VARCHAR(100),
--     'Palakkad_RS'::VARCHAR(100),
--     'LGCP'::VARCHAR(100),
--     '2022-05-09'::DATE
-- );

-- \c railway_reservation_system def@def.com
-- CALL book_tickets(  -- `lkj` not get seat booked
--     ARRAY['lkj', 'gfe']::VARCHAR(100)[],
--     ARRAY[37, 55]::INT[],
--     ARRAY['AC', 'NON-AC']::SEAT_TYPE[],
--     'Gujarat_RS'::VARCHAR(100),
--     'Chennai_RS'::VARCHAR(100),
--     'LGCP'::VARCHAR(100),
--     '2022-05-09'::DATE
-- );


-- -- TC-5
-- \c railway_reservation_system abc@abc.com
-- CALL book_tickets(  -- Will get seat booked
--     ARRAY['cba']::VARCHAR(100)[],
--     ARRAY[13]::INT[],
--     ARRAY['AC']::SEAT_TYPE[],
--     'Lucknow_RS'::VARCHAR(100),
--     'Gujarat_RS'::VARCHAR(100),
--     'LGCP'::VARCHAR(100),
--     '2022-05-16'::DATE
-- );

-- \c railway_reservation_system mno@mno.com
-- CALL book_tickets(  -- Will get seat booked
--     ARRAY['rqp']::VARCHAR(100)[],
--     ARRAY[29]::INT[],
--     ARRAY['AC']::SEAT_TYPE[],
--     'Chennai_RS'::VARCHAR(100),
--     'Palakkad_RS'::VARCHAR(100),
--     'LGCP'::VARCHAR(100),
--     '2022-05-17'::DATE
-- );

-- \c railway_reservation_system def@def.com
-- CALL book_tickets(  -- Will get seat booked
--     ARRAY['lkj', 'gfe']::VARCHAR(100)[],
--     ARRAY[37, 55]::INT[],
--     ARRAY['AC', 'NON-AC']::SEAT_TYPE[],
--     'Gujarat_RS'::VARCHAR(100),
--     'Chennai_RS'::VARCHAR(100),
--     'LGCP'::VARCHAR(100),
--     '2022-05-16'::DATE
-- );


-- -- TC-6
-- \c railway_reservation_system abc@abc.com
-- CALL book_tickets(  -- Will get seat booked
--     ARRAY['abc']::VARCHAR(100)[],
--     ARRAY[37]::INT[],
--     ARRAY['AC']::SEAT_TYPE[],
--     'Indore_RS'::VARCHAR(100),
--     'Kolkata_RS'::VARCHAR(100),
--     'GIJK'::VARCHAR(100),
--     '2022-05-26'::DATE
-- );

-- \c railway_reservation_system def@def.com
-- CALL book_tickets(  -- Will not get seat booked
--     ARRAY['def']::VARCHAR(100)[],
--     ARRAY[55]::INT[],
--     ARRAY['AC']::SEAT_TYPE[],
--     'Gujarat_RS'::VARCHAR(100),
--     'Jaipur_RS'::VARCHAR(100),
--     'GIJK'::VARCHAR(100),
--     '2022-05-26'::DATE
-- );

-- \c railway_reservation_system ghi@ghi.com
-- CALL book_tickets(  -- Will not get seat booked
--     ARRAY['ghi']::VARCHAR(100)[],
--     ARRAY[61]::INT[],
--     ARRAY['AC']::SEAT_TYPE[],
--     'Jaipur_RS',
--     'Kolkata_RS',
--     'GIJK',
--     '2022-05-27'::DATE
-- );
