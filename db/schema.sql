-- Schema DB: Taxi Reservation System
CREATE DATABASE IF NOT EXISTS taxi_manager
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE taxi_manager;

CREATE TABLE drivers (
  driver_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  license_number VARCHAR(30) NOT NULL UNIQUE,
  vehicle_plate VARCHAR(20) NOT NULL UNIQUE,
  credit_card_number VARCHAR(32) NOT NULL,
  seats INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (seats > 0)
) ENGINE=InnoDB;

CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  phone VARCHAR(30) NOT NULL UNIQUE,
  credit_card_number VARCHAR(32) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE ride_requests (
  ride_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  driver_id INT NULL,
  pickup_address VARCHAR(255) NOT NULL,
  destination_address VARCHAR(255) NOT NULL,
  status ENUM(
    'requested',
    'accepted',
    'in_progress',
    'completed',
    'expired',
    'cancelled_by_user',
    'cancelled_by_driver'
  ) NOT NULL,
  requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  accepted_at DATETIME NULL,
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  expired_at DATETIME NULL,
  cancelled_at DATETIME NULL,
  driver_cancelled_at DATETIME NULL,
  fare_amount DECIMAL(10,2) NULL,
  duration_seconds INT NULL,
  commission_amount DECIMAL(10,2) NULL,
  commission_charged_at DATETIME NULL,
  paid_at DATETIME NULL,
  CONSTRAINT fk_ride_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_ride_driver FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
  CHECK (fare_amount IS NULL OR fare_amount >= 0),
  CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
  CHECK (commission_amount IS NULL OR commission_amount >= 0)
) ENGINE=InnoDB;

CREATE INDEX idx_ride_status_requested ON ride_requests(status, requested_at);
CREATE INDEX idx_ride_driver_status ON ride_requests(driver_id, status);
CREATE INDEX idx_ride_customer_status ON ride_requests(customer_id, status);
