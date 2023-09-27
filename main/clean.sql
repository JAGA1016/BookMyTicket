drop database railway_reservation_system with (FORCE);
CREATE DATABASE railway_reservation_system;

-- Users
DROP ROLE IF EXISTS "ravi@123.com";
DROP ROLE IF EXISTS "ram@123.com";
-- DROP ROLE IF EXISTS "ghi@ghi.com";
-- DROP ROLE IF EXISTS "jkl@jkl.com";
-- DROP ROLE IF EXISTS "mno@mno.com";

-- dbAdmin
DROP ROLE IF EXISTS "jaga";
DROP ROLE IF EXISTS "anish";

-- Station Masters
DROP ROLE IF EXISTS "rail_master";


-- Passengers
DROP ROLE IF EXISTS "passenger";



REVOKE ALL ON DATABASE railway_reservation_system FROM users;
REVOKE ALL ON DATABASE railway_reservation_system FROM dbAdmin;
REVOKE ALL ON DATABASE railway_reservation_system FROM railway_manager;

DROP ROLE IF EXISTS users;
DROP ROLE IF EXISTS dbAdmin;
DROP ROLE IF EXISTS railway_manager;
