CREATE TABLE IF NOT EXISTS station (
    station_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS train (
    train_no SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    src_station_id INT NOT NULL,
    dest_station_id INT NOT NULL,
    total_seats INT NOT NULL CHECK(total_seats >= 0),
    -- Week days on which this train will follow its schedule and start from the source station
    week_days DAYS [] NOT NULL,
    FOREIGN KEY(src_station_id) REFERENCES station(station_id) ON DELETE CASCADE,
    FOREIGN KEY(dest_station_id) REFERENCES station(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email_id VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
  	age INT NOT NULL CHECK(age > 0),
    mobile_no VARCHAR(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS passenger (
   passenger_id UUID DEFAULT UUID_GENERATE_V4() PRIMARY KEY,
  	name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age > 0)
);

CREATE TABLE IF NOT EXISTS seat (
    seat_id SERIAL PRIMARY KEY,
    seat_no INT CHECK(seat_no > 0),
    train_no INT NOT NULL,
    seat_type SEAT_TYPE NOT NULL,
    UNIQUE(seat_no, train_no),
    FOREIGN KEY(train_no) REFERENCES train(train_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ticket (
    pnr int DEFAULT nextval('serial') PRIMARY KEY,
    cost INT NOT NULL CHECK (cost > 0),
    src_station_id INT NOT NULL,
    dest_station_id INT NOT NULL,
    train_no INT NOT NULL,
    user_id INT NOT NULL,
    date DATE NOT NULL CHECK(date - CURRENT_DATE >= 0),
    passenger_id UUID NOT NULL,
  	seat_id INT DEFAULT NULL,
    seat_type SEAT_TYPE DEFAULT NULL,
    booking_status Ticket_Status DEFAULT 'Waiting',
  	booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(src_station_id) REFERENCES station(station_id) ON DELETE CASCADE,
    FOREIGN KEY(dest_station_id) REFERENCES station(station_id) ON DELETE CASCADE,
    FOREIGN KEY(train_no) REFERENCES train(train_no) ON DELETE CASCADE,
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(passenger_id) REFERENCES passenger(passenger_id) ON DELETE CASCADE,
  	FOREIGN KEY(seat_id) REFERENCES seat(seat_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS schedule (
    sch_id SERIAL PRIMARY KEY,
    -- Train Number to which the schedule is assigned
    train_no INT NOT NULL,
    -- Station from which the train departs
    curr_station_id INT NOT NULL,
    -- Station to which the train arrives
    -- For the destination station, this value can be NULL
    next_station_id INT,
    -- (Day of Journey, Time) at which the train will arrive at the current station
    arr_time DAY_TIME_Format NOT NULL,
    -- (Day of Journey, Time) at which the train will depart from the current station
    dep_time DAY_TIME_Format NOT NULL CHECK(arr_time <= dep_time),
    -- Fare from the source station of the train till the current_station
    fare NUMERIC(7, 2) NOT NULL CHECK(fare >= 0),
    -- Time by which the train will be delayed at the current station
    -- delay_time INTERVAL NOT NULL CHECK(delay_time >= INTERVAL '0'),
    FOREIGN KEY(train_no) REFERENCES train(train_no) ON DELETE CASCADE,
    FOREIGN KEY(curr_station_id) REFERENCES station(station_id) ON DELETE CASCADE,
    FOREIGN KEY(next_station_id) REFERENCES station(station_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS railway_manager (
    master_username VARCHAR(100) PRIMARY KEY,
    password VARCHAR(100) NOT NULL
);




