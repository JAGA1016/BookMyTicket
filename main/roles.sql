-- dbadmin role
CREATE GROUP dbAdmin;

GRANT ALL ON DATABASE railway_reservation_system TO dbAdmin;

GRANT ALL ON ALL TABLES IN SCHEMA PUBLIC TO dbAdmin;

ALTER ROLE dbAdmin BYPASSRLS;

CREATE USER jaga IN GROUP dbAdmin BYPASSRLS PASSWORD 'jaga';
CREATE USER anish IN GROUP dbAdmin BYPASSRLS PASSWORD 'anish';
-- CREATE USER rak IN GROUP dbAdmin BYPASSRLS PASSWORD 'rak';

-- station master role
CREATE USER railway_master  IN GROUP railway_manager PASSWORD 'rail';

CREATE GROUP railway_manager;
REVOKE ALL ON PROCEDURE add_railway_station,
    add_schedule,
    update_train_status
FROM PUBLIC;


GRANT ALL ON TABLE railway_station TO railway_manager;
GRANT ALL ON TABLE schedule TO railway_manager;
GRANT ALL ON TABLE train TO railway_manager;
GRANT ALL ON TABLE seat TO railway_manager;
GRANT ALL ON trains_availability to railway_manager;

GRANT EXECUTE ON PROCEDURE add_railway_station,
    add_schedule,
    update_train_status
TO railway_manager;


-- user roles
CREATE GROUP users;

REVOKE ALL ON PROCEDURE book_tickets,
    cancel_booking,
    allocate_seat
FROM PUBLIC;

GRANT ALL ON TABLE users TO users;
GRANT ALL ON TABLE passenger TO users;
GRANT SELECT ON TABLE ticket TO users;
GRANT SELECT ON TABLE train TO users;
GRANT SELECT ON TABLE railway_station TO users;
GRANT SELECT ON booking_details TO users;


GRANT EXECUTE ON PROCEDURE book_tickets,
    cancel_booking
TO users;

-- passenger role 
CREATE USER passenger PASSWORD 'passenger';



---row level security


ALTER TABLE users
ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_policy
ON users
FOR ALL
TO users
USING (email_id = CURRENT_USER);

ALTER TABLE ticket
ENABLE ROW LEVEL SECURITY;

CREATE POLICY ticket_policy
ON ticket
FOR SELECT
TO users
USING (ticket.user_id = (SELECT user_id
                            FROM users
                            WHERE email_id = CURRENT_USER ) );


ALTER TABLE passenger
ENABLE ROW LEVEL SECURITY;

CREATE POLICY passenger_policy
ON passenger
FOR ALL
TO users
USING (passenger.pid = ANY(SELECT pid
                            FROM ticket
                            WHERE ticket.user_id = (SELECT user_id
                                                    FROM users
                                                    WHERE email_id = CURRENT_USER )  )   );
