create database if not exists ProjectSp2025;
use ProjectSp2025;

/* create table if not exists users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    user_type ENUM('admin', 'rep', 'customer') DEFAULT 'customer'
);

CREATE TABLE if not exists Airlines (
    airline_id CHAR(2) PRIMARY KEY, -- e.g., 'AA', 'UA'
    airline_name VARCHAR(100) NOT NULL
);

CREATE TABLE if not exists Airports (
    airport_id CHAR(3) PRIMARY KEY, -- e.g., 'JFK'
    airport_name VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE if not exists Aircrafts (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100),
    total_seats INT NOT NULL
);

CREATE TABLE if not exists Flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_id CHAR(2),
    aircraft_id INT,
    flight_number VARCHAR(10),
    departure_airport CHAR(3),
    arrival_airport CHAR(3),
    departure_time DATETIME,
    arrival_time DATETIME,
    days_of_week SET('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'),
    domestic BOOLEAN,
    price DECIMAL(10,2),
    num_stops INT,
    FOREIGN KEY (airline_id) REFERENCES Airlines(airline_id),
    FOREIGN KEY (aircraft_id) REFERENCES Aircrafts(aircraft_id),
    FOREIGN KEY (departure_airport) REFERENCES Airports(airport_id),
    FOREIGN KEY (arrival_airport) REFERENCES Airports(airport_id)
);

CREATE TABLE if not exists Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    total_fare DECIMAL(10,2),
    booking_fee DECIMAL(10,2),
    purchase_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    class ENUM('economy', 'business', 'first'),
    passenger_first_name VARCHAR(50),
    passenger_last_name VARCHAR(50),
    passenger_id_number VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE if not exists TicketFlights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT,
    flight_id INT,
    seat_number VARCHAR(10),
    flight_date DATE,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

CREATE TABLE if not exists WaitingList (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    flight_id INT,
    request_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    notified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

CREATE TABLE if not exists Questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    question_text TEXT,
    asked_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE if not exists Answers (
    answer_id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT,
    rep_id INT,
    answer_text TEXT,
    answered_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES Questions(question_id),
    FOREIGN KEY (rep_id) REFERENCES Users(user_id)
);

-- Users (3 types)
INSERT INTO Users (first_name, last_name, email, password, user_type) VALUES
('Alice', 'Smith', 'alice@example.com', 'password1', 'customer'),
('Bob', 'Johnson', 'bob@example.com', 'password2', 'customer'),
('Carol', 'Williams', 'carol@example.com', 'password3', 'rep'),
('Dave', 'Brown', 'dave@example.com', 'password4', 'rep'),
('Eve', 'Jones', 'eve@example.com', 'password5', 'admin'),
('Frank', 'Davis', 'frank@example.com', 'password6', 'customer'),
('Grace', 'Miller', 'grace@example.com', 'password7', 'customer'),
('Hank', 'Wilson', 'hank@example.com', 'password8', 'rep'),
('Ivy', 'Moore', 'ivy@example.com', 'password9', 'customer'),
('Jack', 'Taylor', 'jack@example.com', 'password10', 'customer');

-- Airlines
INSERT INTO Airlines (airline_id, airline_name) VALUES
('AA', 'American Airlines'),
('UA', 'United Airlines'),
('DL', 'Delta Airlines'),
('SW', 'Southwest Airlines'),
('JB', 'JetBlue Airways'),
('BA', 'British Airways'),
('AF', 'Air France'),
('LH', 'Lufthansa'),
('AI', 'Air India'),
('EK', 'Emirates');

-- Airports
INSERT INTO Airports (airport_id, airport_name, city, country) VALUES
('JFK', 'John F. Kennedy International Airport', 'New York', 'USA'),
('EWR', 'Newark Liberty International Airport', 'Newark', 'USA'),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'USA'),
('ORD', 'O’Hare International Airport', 'Chicago', 'USA'),
('LGA', 'LaGuardia Airport', 'New York', 'USA'),
('SFO', 'San Francisco International Airport', 'San Francisco', 'USA'),
('CDG', 'Charles de Gaulle Airport', 'Paris', 'France'),
('DEL', 'Indira Gandhi International Airport', 'Delhi', 'India'),
('DXB', 'Dubai International Airport', 'Dubai', 'UAE'),
('LHR', 'London Heathrow Airport', 'London', 'UK');

-- Aircrafts
INSERT INTO Aircrafts (model, total_seats) VALUES
('Boeing 737', 150),
('Airbus A320', 180),
('Boeing 777', 300),
('Airbus A380', 500),
('Boeing 787', 250),
('Embraer E190', 100),
('Bombardier CRJ900', 90),
('Boeing 767', 210),
('Airbus A350', 325),
('Concorde', 120);

-- Flights
INSERT INTO Flights (airline_id, aircraft_id, flight_number, departure_airport, arrival_airport, departure_time, arrival_time, days_of_week, domestic, price, num_stops) VALUES
('AA', 1, 'AA101', 'JFK', 'LAX', '2025-06-01 08:00:00', '2025-06-01 11:00:00', 'Mon,Wed,Fri', TRUE, 299.99, 0),
('UA', 2, 'UA222', 'LAX', 'ORD', '2025-06-01 09:00:00', '2025-06-01 13:00:00', 'Tue,Thu', TRUE, 250.00, 1),
('DL', 3, 'DL333', 'ORD', 'JFK', '2025-06-01 10:00:00', '2025-06-01 14:00:00', 'Fri,Sat', TRUE, 280.00, 0),
('SW', 4, 'SW444', 'LGA', 'SFO', '2025-06-01 11:00:00', '2025-06-01 14:30:00', 'Mon,Wed', TRUE, 310.00, 1),
('JB', 5, 'JB555', 'JFK', 'CDG', '2025-06-01 17:00:00', '2025-06-02 06:30:00', 'Fri,Sun', FALSE, 700.00, 0),
('AF', 6, 'AF666', 'CDG', 'LHR', '2025-06-02 08:00:00', '2025-06-02 09:00:00', 'Tue,Thu', FALSE, 200.00, 0),
('LH', 7, 'LH777', 'LHR', 'DEL', '2025-06-02 10:00:00', '2025-06-02 20:00:00', 'Fri,Sun', FALSE, 800.00, 1),
('AI', 8, 'AI888', 'DEL', 'DXB', '2025-06-03 05:00:00', '2025-06-03 09:00:00', 'Mon,Wed', FALSE, 350.00, 0),
('EK', 9, 'EK999', 'DXB', 'JFK', '2025-06-03 12:00:00', '2025-06-03 20:00:00', 'Sun', FALSE, 900.00, 0),
('BA', 10, 'BA123', 'LHR', 'EWR', '2025-06-03 07:00:00', '2025-06-03 15:00:00', 'Mon,Wed,Fri', FALSE, 820.00, 0);

*/
/*insert into users (first_name, last_name, email, password, user_type) values 
('Nihal', 'Shah', 'nns86@scarletmail.rutgers.edu', 'nns86', 'admin'),
('Tanish', 'Ravinuthala', 'tr517@scarletmail.rutgers.edu', 'tr517', 'rep'),
('Chase', 'Moskowitz', 'ctm176@scarletmail.rutgers.edu', 'ctm176', 'customer'),
('Haadi', 'Khan', 'hk900@scarletmail.rutgers.edu', 'hk900', 'customer');
*/
/*INSERT INTO Aircrafts (model, total_seats) VALUES
('Boeing 737', 150);

INSERT INTO Flights (airline_id, aircraft_id, flight_number, departure_airport, arrival_airport, departure_time, arrival_time, days_of_week, domestic, price, num_stops) VALUES
('AA', 11, 'AF691', 'LAX', 'JFK', '2025-06-04 08:00:00', '2025-06-04 14:00:00', 'Tue,Thu', FALSE, 200.00, 0);
*/
