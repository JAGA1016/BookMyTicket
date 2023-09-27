-- Trigger function for automatic seat allocation
-- trigger-1
CREATE OR REPLACE FUNCTION book_seat()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
    train_name VARCHAR(100);
    src_station_name VARCHAR(100);
    dest_station_name VARCHAR(100);
    waiting_ticket RECORD;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Extract train_name, source/destination station names
        SELECT get_train_name(NEW.train_no)
        INTO train_name;
        SELECT get_station_name(NEW.src_station_id)
        INTO src_station_name;
        SELECT get_station_name(NEW.dest_station_id)
        INTO dest_station_name;

        -- Try allocating seat to this passenger
        CALL allocate_seat(NEW.pnr, train_name, src_station_name, dest_station_name, NEW.date, NEW.seat_type);
    ELSEIF TG_OP = 'UPDATE' AND NEW.booking_status = 'Cancelled' THEN
        -- Loop all the passengers in the waiting queue in order of booking time
        FOR waiting_ticket IN (SELECT pnr,
                                    train_no,
                                    src_station_id,
                                    dest_station_id,
                                    date,
                                    seat_type
                                FROM ticket
                                WHERE booking_status = 'Waiting'
                                    AND (date - get_journey_at_station(src_station_id, train_no) + 1) =
                                (NEW.date - get_journey_at_station(NEW.src_station_id, NEW.train_no) + 1)
                                    AND train_no = NEW.train_no
                                ORDER BY booking_time ASC)
        LOOP
            -- RAISE NOTICE '%', waiting_ticket;
            -- Extract train_name, source/destination station names
            SELECT get_train_name(waiting_ticket.train_no)
            INTO train_name;
            SELECT get_station_name(waiting_ticket.src_station_id)
            INTO src_station_name;
            SELECT get_station_name(waiting_ticket.dest_station_id)
            INTO dest_station_name;

            -- Try allocating seat to this passenger
            CALL allocate_seat(waiting_ticket.pnr, train_name, src_station_name, dest_station_name,
                waiting_ticket.date, waiting_ticket.seat_type);
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER assign_seat
AFTER INSERT OR UPDATE
ON ticket
FOR EACH ROW
EXECUTE FUNCTION book_seat();


-- trigger -2
CREATE OR REPLACE FUNCTION log_manager_actions()
RETURNS trigger AS $body$
BEGIN
   if (TG_OP = 'INSERT') then
       INSERT INTO updated_stations_schedule (
            sch_id,
            old_data,
            new_data,
            modified_type,
            modified_timestamp,
            created_by
       )
       VALUES(
           NEW.sch_id,
           NULL,
           to_jsonb(NEW),
           'INSERT',
           CURRENT_TIMESTAMP,
           CURRENT_USER
       );
             
       RETURN NEW;
   elsif (TG_OP = 'UPDATE') then
       INSERT INTO updated_stations_schedule (
            sch_id,
            old_data,
            new_data,
            modified_type,
            modified_timestamp,
            created_by
       )
       VALUES(
           NEW.sch_id,
           to_jsonb(OLD),
           to_jsonb(NEW),
           'UPDATE',
           CURRENT_TIMESTAMP,
           CURRENT_USER
       );
             
             
       RETURN NEW;
   elsif (TG_OP = 'DELETE') then
       INSERT INTO updated_stations_schedule (
            sch_id,
            old_data,
            new_data,
            modified_type,
            modified_timestamp,
            created_by
       )
       VALUES(
           OLD.id,
           to_jsonb(OLD),
           null,
           'DELETE',
           CURRENT_TIMESTAMP,
           CURRENT_USER
       );
        
       RETURN OLD;
   end if;
     
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER schedule_log 
AFTER INSERT OR UPDATE 
ON schedule
FOR EACH ROW
EXECUTE FUNCTION log_manager_actions();


-- trigger -3
CREATE OR REPLACE FUNCTION check_email() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email_id ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Invalid email format';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_email_trigger 
BEFORE INSERT ON users 
FOR EACH ROW 
EXECUTE FUNCTION check_email();




-- trigger -4
-- CREATE OR REPLACE FUNCTION check_pnr()
-- RETURNS TRIGGER
-- LANGUAGE PLPGSQL
-- AS $$
-- DECLARE
--      in_ticket_pnr INT 
    
-- BEGIN
--     SELECT pnr
--     INTO in_ticket_pnr
--     FROM ticket
--     WHERE pnr = NEW.pnr;
--     ASSERT in_ticket_pnr IS NOT NULL, 'Ticket with PNR "' || NEW.pnr || '" does not exist!';
--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER check_ticket_update 
-- BEFORE UPDATE ON ticket
--  FOR EACH ROW EXECUTE FUNCTION check_pnr();
