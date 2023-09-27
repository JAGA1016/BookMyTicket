--Status of seat reservation: In the waiting list or confirmed?
CREATE OR REPLACE FUNCTION get_ticket_status(in_pnr int)
RETURNS Ticket_Status
AS $$
DECLARE
	status Ticket_Status;
BEGIN
    PERFORM validate_pnr(in_pnr);

    SELECT booking_status
    INTO status
    FROM ticket
    WHERE pnr = in_pnr;

    RETURN status;
END;
$$ LANGUAGE PLPGSQL
   SECURITY DEFINER;