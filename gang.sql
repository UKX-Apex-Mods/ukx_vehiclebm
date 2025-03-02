-- SQL script to create the necessary tables for the gang vehicle sales tracking

-- Table to store information about vehicles sold by gang members
CREATE TABLE IF NOT EXISTS bmgangsold (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gang VARCHAR(50),
    player_id INT,
    name VARCHAR(100),
    vehicle VARCHAR(50),
    amount INT,
    sale_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store information about the weekly vehicle sale limit for each gang
CREATE TABLE IF NOT EXISTS bmganglimit (
    gang VARCHAR(50) PRIMARY KEY,
    weekly_limit INT
);

-- Table to store information about vehicles available for sale
CREATE TABLE IF NOT EXISTS bmvehiclelist (
    vehicle_name VARCHAR(100),
    vehicle_model VARCHAR(50),
    vehicle_brand VARCHAR(50),
    vehicle_type VARCHAR(50),
    vehicle_price INT
);