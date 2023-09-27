--  train schedule -- train name, seats numbers, seat types, start journey, halt stations, arrival and depature timmings, prices

 CALL add_schedule(
    in_name       => 'Humsafar_Express'::VARCHAR(100),
    in_seats      => ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]::INT[],
    in_seat_types => ARRAY['AC', 'AC', 'AC', 'AC', 'AC', 'AC',  'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC']::SEAT_TYPE[],
    in_week_days  => ARRAY['Monday',  'Wednesday', 'Friday']::DAYS[],
    in_stations   => ARRAY['Bangalore_cantt', 'Palakkad_jn', 'Ernakulam']::VARCHAR(100)[],
    in_arr_time   => ARRAY[(1, '18:00:00'), (2, '6:00:00'), (2, '9:30:00')]::DAY_TIME_Format[],
    in_dep_time   => ARRAY[(1, '18:20:00'), (2, '6:20:00'), (2, '10:00:00')]::DAY_TIME_Format[],
    in_fares      => ARRAY[0, 100, 200]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    in_name       => 'Sabari express'::VARCHAR(100),
    in_seats      => ARRAY[1, 2, 3, 4, 5, 6, 7]::INT[],
    in_seat_types => ARRAY['AC', 'AC','NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC']::SEAT_TYPE[],
    in_week_days  => ARRAY['Monday',  'Wednesday', 'Friday']::DAYS[],
    in_stations   => ARRAY['Secunderabad_Jn', 'Vijayawada_jn', 'Palakkad_jn', 'Ernakulam']::VARCHAR(100)[],
    in_arr_time   => ARRAY[(1, '12:15:00'), (1, '19:00:00'), (2, '7:30:00'), (2, '10:30:00')]::DAY_TIME_Format[],
    in_dep_time   => ARRAY[(1, '12:40:00'), (1, '19:20:00'), (2, '7:50:00'), (2, '10:50:00')]::DAY_TIME_Format[],
    in_fares      => ARRAY[0, 120, 220, 400]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    in_name       => 'dennai Express'::VARCHAR(100),
    in_seats      => ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]::INT[],
    in_seat_types => ARRAY['AC', 'AC', 'AC', 'AC' , 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC']::SEAT_TYPE[],
    in_week_days  => ARRAY['Monday', 'Saturday']::DAYS[],
    in_stations   => ARRAY['Chennai_Central', 'Bangalore_cantt', 'Howrah_Jn', 'Lucknow_Jn']::VARCHAR(100)[],
    in_arr_time   => ARRAY[(1, '7:00:00'), (1, '19:00:00'), (2, '8:00:00'), (2, '20:00:00')]::DAY_TIME_Format[],
    in_dep_time   => ARRAY[(1, '7:20:00'), (1, '19:20:00'), (2, '8:20:00'), (2, '20:20:00')]::DAY_TIME_Format[],
    in_fares      => ARRAY[0, 900, 2200,5000]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    in_name       => 'Rajadhani Express'::VARCHAR(100),
    in_seats      => ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]::INT[],
    in_seat_types => ARRAY['AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC', 'AC']::SEAT_TYPE[],
    in_week_days  => ARRAY['Monday', 'Thursday']::DAYS[],
    in_stations   => ARRAY['Hazrat_Nizamuddin', 'Secunderabad_Jn', 'Chennai_Central']::VARCHAR(100)[],
    in_arr_time   => ARRAY[(1, '9:00:00'), (3, '6:00:00'), (3, '23:00:00')]::DAY_TIME_Format[],
    in_dep_time   => ARRAY[(1, '9:30:00'), (3, '7:00:00'), (3, '23:10:00')]::DAY_TIME_Format[],
    in_fares      => ARRAY[0, 5500, 7500]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    'Palakkad Super Fast'::VARCHAR(100),
    ARRAY[1, 2, 3, 4, 5]::INT[],
    ARRAY['AC', 'AC', 'AC', 'NON-AC', 'NON-AC']::SEAT_TYPE[],
    ARRAY['Monday', 'Tuesday', 'Wednesday', 'Friday', 'Saturday']::DAYS[],
    ARRAY['Palakkad_jn', 'Ernakulam']::VARCHAR(100)[],
    ARRAY[(1, '8:00:00'), (1, '11:00:00')]::DAY_TIME_Format[],
    ARRAY[(1, '8:10:00'), (1, '11:20:00')]::DAY_TIME_Format[],
    ARRAY[0, 120]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    'Indian express'::VARCHAR(100),
    ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]::INT[],
    ARRAY['AC', 'AC', 'NON-AC', 'AC', 'NON-AC', 'NON-AC', 'AC', 'AC', 'NON-AC', 'AC', 'NON-AC', 'NON-AC', 'AC', 'AC', 'NON-AC', 'AC', 'NON-AC', 'NON-AC', 'AC', 'AC']::SEAT_TYPE[],
    ARRAY['Saturday']::DAYS[],
    ARRAY['Bangalore_cantt', 'Chennai_Central', 'Vijayawada_jn', 'Howrah_Jn', 'Kanpur_Central',  'Guwahati_Jn',  'Lucknow_Jn', 'Hazrat_Nizamuddin',   'Mumbai_central', 'Palakkad_jn']::VARCHAR(100)[],
    ARRAY[(1, '09:00:00'), (1, '19:00:00'), (2, '01:00:00'), (2, '23:00:00'), (3, '13:00:00'), (4, '12:00:00'), (5, '01:10:00'), (5, '12:50:00'), (6, '05:00:00'), (7, '09:00:00')]::DAY_TIME_Format[],
    ARRAY[(1, '10:00:00'), (1, '19:20:00'), (2, '01:30:00'), (2, '23:30:00'), (3, '13:30:00'), (5, '00:30:00'), (5, '01:40:00'), (5, '13:00:00'), (6, '06:00:00'), (7, '9:40:00')]::DAY_TIME_Format[],
    ARRAY[0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    'Intercity'::VARCHAR(100),
    ARRAY[1, 2, 3]::INT[],
    ARRAY['AC', 'AC',  'NON-AC']::SEAT_TYPE[],
    ARRAY[ 'Tuesday', 'Thursday',  'Saturday']::DAYS[],
    ARRAY[ 'Howrah_Jn', 'Kanpur_Central',  'Guwahati_Jn',  'Lucknow_Jn']::VARCHAR(100)[],
    ARRAY[(1, '4:00:00'), (1, '19:00:00'),(2,'5:00:00'),(2,'20:00:00')]::DAY_TIME_Format[],
    ARRAY[(1, '4:10:00'), (1, '19:12:00'),(2,'5:05:00'),(2,'20:34:00')]::DAY_TIME_Format[],
    ARRAY[0, 220,330,430]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    'Gujarat Rail'::VARCHAR(100),
    ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]::INT[],
    ARRAY['AC', 'AC', 'NON-AC', 'AC', 'NON-AC', 'NON-AC', 'AC', 'AC', 'NON-AC', 'AC']::SEAT_TYPE[],
    ARRAY['Monday']::DAYS[],
    ARRAY[ 'Ahmedabad_Jn', 'Guwahati_Jn', 'Kanpur_Central', 'Howrah_Jn']::VARCHAR(100)[],
    ARRAY[(1, '9:00:00'), (2, '7:00:00'), (2, '19:00:00'), (3, '12:00:00')]::DAY_TIME_Format[],
    ARRAY[(1, '9:10:00'), (2, '7:20:00'), (2, '19:30:00'), (3, '12:05:00')]::DAY_TIME_Format[],
    ARRAY[0, 130, 240, 305]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    'Kochi-Chennai'::VARCHAR(100),
    ARRAY[1, 2, 3, 4]::INT[],
    ARRAY['AC', 'AC', 'NON-AC', 'NON-AC']::SEAT_TYPE[],
    ARRAY['Monday', 'Wednesday', 'Friday']::DAYS[],
    ARRAY['Ernakulam', 'Palakkad_jn', 'Chennai_Central']::VARCHAR(100)[],
    ARRAY[(1, '13:30:00'), (1, '21:50:00'), (2, '9:00:00')]::DAY_TIME_Format[],
    ARRAY[(1, '14:00:00'), (1, '22:00:00'), (2, '9:00:00')]::DAY_TIME_Format[],
    ARRAY[0, 120, 240]::NUMERIC(7, 2)[]
);

CALL add_schedule(
    'North-Intercity'::VARCHAR(100),
    ARRAY[1, 2, 3, 4, 5, 6, 7, 8]::INT[],
    ARRAY['AC', 'AC', 'AC', 'AC', 'NON-AC', 'NON-AC', 'NON-AC', 'NON-AC']::SEAT_TYPE[],
    ARRAY['Wednesday']::DAYS[],
    ARRAY['Lucknow_Jn', 'Ahmedabad_Jn', 'Mumbai_central', 'Kanpur_Central', 'Howrah_Jn', 'Hazrat_Nizamuddin']::VARCHAR(100)[],
    ARRAY[(1, '2:10:00'), (1, '3:50:00'), (1, '8:20:00'), (2, '12:00:00'), (3, '19:55:00'), (3, '21:55:00')]::DAY_TIME_Format[],
    ARRAY[(1, '3:00:00'), (1, '4:00:00'), (2, '7:00:00'), (2, '13:00:00'), (3, '20:50:00'), (3, '22:55:00')]::DAY_TIME_Format[],
    ARRAY[0, 1090, 2430, 3540, 4210, 5890]::NUMERIC(7, 2)[]
);

