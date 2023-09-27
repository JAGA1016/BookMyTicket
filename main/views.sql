CREATE VIEW booking_details AS
    SELECT pnr, u.username as user_name, u.email_id as user_email, u.mobile_no as user_mobile, p.pid as passenger_id, p.name as passenger_name, p.age as passenger_age, t.train_no as train_no, t.seat_id, t.seat_type, t.booking_status, t.booking_time,
    t.src_station_id as bording_station, t.dest_station_id as destination_station, t.date as bording_date
    from ticket as t natural join users as u inner join passenger as p on p.pid = t.pid;

CREATE VIEW trains_availability AS
SELECT sch.train_no,
    tt.name AS train_name,
    curr.name AS current_station,
    nxt.name AS next_station,
    (sch.arr_time).time AS arrival_time,
    (sch.dep_time).time - (sch.arr_time).time AS halt_time,
    ARRAY_TO_STRING(get_updated_days((sch.arr_time).day_of_journey,tt.week_days), '/', '')AS running_days,
    get_fare(tt.name,curr.name,nxt.name) as price
FROM schedule AS sch
    JOIN train AS tt ON sch.train_no = tt.train_no
    JOIN railway_station AS curr ON sch.curr_station_id = curr.station_id
    LEFT JOIN railway_station AS nxt ON sch.next_station_id = nxt.station_id
    WHERE nxt.name IS NOT NULL
ORDER BY sch.train_no ASC, sch.arr_time ASC;

CREATE VIEW user_info AS
SELECT user_id, username, email_id, age from users;





