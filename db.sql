DROP DATABASE IF EXISTS `taxi_manager`;
CREATE DATABASE `taxi_manager` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `taxi_manager`;

SET GLOBAL event_scheduler = ON;

-- PULIZIA UTENTI
DROP USER IF EXISTS 'guest'@'localhost';
DROP USER IF EXISTS 'customer'@'localhost';
DROP USER IF EXISTS 'driver'@'localhost';
DROP USER IF EXISTS 'manager'@'localhost';

-- TABELLE

CREATE TABLE `customers` (
  `username` VARCHAR(50) PRIMARY KEY,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `password_hash` CHAR(64) NOT NULL,
  `phone` VARCHAR(30) NOT NULL UNIQUE,
  `credit_card_number` VARCHAR(32) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `drivers` (
  `username` VARCHAR(50) PRIMARY KEY,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `password_hash` CHAR(64) NOT NULL,
  `license_number` VARCHAR(30) NOT NULL UNIQUE,
  `vehicle_plate` VARCHAR(20) NOT NULL UNIQUE,
  `credit_card_number` VARCHAR(32) NOT NULL,
  `seats` INT NOT NULL CHECK (`seats` > 0),
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `managers` (
  `username` VARCHAR(50) PRIMARY KEY,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `password_hash` CHAR(64) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `ride_requests` (
  `customer_username` VARCHAR(50) NOT NULL,
  `driver_username` VARCHAR(50) DEFAULT NULL,
  `requested_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `started_at` DATETIME DEFAULT NULL,
  `pickup_address` VARCHAR(255) NOT NULL,
  `destination_address` VARCHAR(255) NOT NULL,
  `status` ENUM('requested', 'accepted', 'in_progress', 'completed', 'cancelled', 'expired') NOT NULL DEFAULT 'requested',
  `fare_amount` DECIMAL(10,2) DEFAULT NULL CHECK (`fare_amount` >= 0),
  `duration_seconds` INT DEFAULT NULL CHECK (`duration_seconds` >= 0),
  `commission_amount` DECIMAL(10,2) DEFAULT NULL CHECK (`commission_amount` >= 0),
  `commission_charged_at` DATETIME DEFAULT NULL,
  `seats_needed` INT NOT NULL DEFAULT 1 CHECK (`seats_needed` > 0),
  PRIMARY KEY (`customer_username`, `requested_at`),
  CONSTRAINT `fk_ride_customer` FOREIGN KEY (`customer_username`) REFERENCES `customers` (`username`),
  CONSTRAINT `fk_ride_driver` FOREIGN KEY (`driver_username`) REFERENCES `drivers` (`username`)
);

CREATE INDEX `idx_status_requested` ON `ride_requests` (`status`, `requested_at`);
CREATE INDEX `idx_driver_rides` ON `ride_requests` (`driver_username`, `status`);
CREATE INDEX `idx_customer_rides` ON `ride_requests` (`customer_username`, `status`);

-- PROCEDURE

DELIMITER //

-- Gestisce il login verificando le credenziali per clienti, tassisti e manager
CREATE PROCEDURE `sp_login`(
  IN p_username VARCHAR(50),
  IN p_password VARCHAR(255)
)
BEGIN
  DECLARE v_hash CHAR(64);
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  
  IF p_username IS NULL OR p_username = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username non puo essere vuoto';
  END IF;
  
  IF p_password IS NULL OR p_password = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password non puo essere vuota';
  END IF;
  
  IF LENGTH(p_username) < 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username deve essere almeno 3 caratteri';
  END IF;
  
  SET v_hash = SHA2(p_password, 256);

  IF EXISTS (SELECT username FROM customers WHERE username = p_username AND password_hash = v_hash) THEN
    SELECT 
      first_name, 
      last_name, 
      username,
      password_hash AS password,
      'customer' AS role,
      created_at,
      phone,
      credit_card_number,
      NULL AS license_number,
      NULL AS vehicle_plate,
      NULL AS seats
    FROM customers WHERE username = p_username AND password_hash = v_hash;
  ELSEIF EXISTS (SELECT username FROM drivers WHERE username = p_username AND password_hash = v_hash) THEN
    SELECT 
      first_name, 
      last_name, 
      username,
      password_hash AS password,
      'driver' AS role,
      created_at,
      NULL AS phone,
      credit_card_number,
      license_number,
      vehicle_plate,
      seats
    FROM drivers WHERE username = p_username AND password_hash = v_hash;
  ELSEIF EXISTS (SELECT username FROM managers WHERE username = p_username AND password_hash = v_hash) THEN
    SELECT 
      first_name, 
      last_name, 
      username,
      password_hash AS password,
      'manager' AS role,
      created_at,
      NULL AS phone,
      NULL AS credit_card_number,
      NULL AS license_number,
      NULL AS vehicle_plate,
      NULL AS seats
    FROM managers WHERE username = p_username AND password_hash = v_hash;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Credenziali non valide';
  END IF;
  COMMIT;
END //

-- Registra un nuovo cliente nel sistema
CREATE PROCEDURE `sp_register_customer`(
  IN p_first_name VARCHAR(50),
  IN p_last_name VARCHAR(50),
  IN p_username VARCHAR(50),
  IN p_password VARCHAR(255),
  IN p_phone VARCHAR(30),
  IN p_credit_card VARCHAR(32)
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  START TRANSACTION;

  IF p_first_name IS NULL OR p_first_name = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nome non puo essere vuoto';
  END IF;
  
  IF p_last_name IS NULL OR p_last_name = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cognome non puo essere vuoto';
  END IF;
  
  IF p_username IS NULL OR p_username = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username non puo essere vuoto';
  END IF;
  
  IF p_password IS NULL OR p_password = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password non puo essere vuota';
  END IF;
  
  IF p_phone IS NULL OR p_phone = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Telefono non puo essere vuoto';
  END IF;
  
  IF p_credit_card IS NULL OR p_credit_card = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carta di credito non puo essere vuota';
  END IF;
  
  IF LENGTH(p_username) < 3 OR LENGTH(p_username) > 20 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username deve essere tra 3 e 20 caratteri';
  END IF;
  
  IF p_username NOT REGEXP '^[a-zA-Z0-9_]+$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username puo contenere solo lettere, numeri e underscore';
  END IF;
  
  IF LENGTH(p_password) < 6 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password deve essere almeno 6 caratteri';
  END IF;
  
  IF p_phone NOT REGEXP '^[0-9]+$' OR LENGTH(p_phone) < 8 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato telefono non valido';
  END IF;
  
  IF p_credit_card NOT REGEXP '^[0-9]{16}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carta di credito deve essere 16 cifre';
  END IF;
  
  INSERT INTO customers (first_name, last_name, username, password_hash, phone, credit_card_number)
  VALUES (p_first_name, p_last_name, p_username, SHA2(p_password, 256), p_phone, p_credit_card);
  COMMIT;
END //

-- Registra un nuovo tassista nel sistema
CREATE PROCEDURE `sp_register_driver`(
  IN p_first_name VARCHAR(50),
  IN p_last_name VARCHAR(50),
  IN p_username VARCHAR(50),
  IN p_password VARCHAR(255),
  IN p_license VARCHAR(30),
  IN p_plate VARCHAR(20),
  IN p_credit_card VARCHAR(32),
  IN p_seats INT
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  START TRANSACTION;
  IF p_first_name IS NULL OR p_first_name = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nome non puo essere vuoto';
  END IF;
  
  IF p_last_name IS NULL OR p_last_name = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cognome non puo essere vuoto';
  END IF;
  
  IF p_username IS NULL OR p_username = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username non puo essere vuoto';
  END IF;
  
  IF p_password IS NULL OR p_password = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password non puo essere vuota';
  END IF;
  
  IF p_license IS NULL OR p_license = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patente non puo essere vuota';
  END IF;
  
  IF p_plate IS NULL OR p_plate = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Targa non puo essere vuota';
  END IF;
  
  IF p_credit_card IS NULL OR p_credit_card = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carta di credito non puo essere vuota';
  END IF;
  
  IF LENGTH(p_username) < 3 OR LENGTH(p_username) > 20 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username deve essere tra 3 e 20 caratteri';
  END IF;
  
  IF p_username NOT REGEXP '^[a-zA-Z0-9_]+$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username puo contenere solo lettere, numeri e underscore';
  END IF;
  
  IF LENGTH(p_password) < 6 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password deve essere almeno 6 caratteri';
  END IF;
  
  IF p_credit_card NOT REGEXP '^[0-9]{16}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carta di credito deve essere 16 cifre';
  END IF;
  
  IF p_seats IS NULL OR p_seats < 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero posti deve essere maggiore di 0';
  END IF;
  
  IF LENGTH(p_license) < 5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero patente non valido';
  END IF;
  
  IF LENGTH(p_plate) < 5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Targa non valida';
  END IF;
  
  INSERT INTO drivers (first_name, last_name, username, password_hash, license_number, vehicle_plate, credit_card_number, seats)
  VALUES (p_first_name, p_last_name, p_username, SHA2(p_password, 256), p_license, p_plate, p_credit_card, p_seats);
  COMMIT;
END //

-- Crea una nuova richiesta di corsa per un cliente
CREATE PROCEDURE `sp_request_ride`(
  IN p_customer_username VARCHAR(50),
  IN p_pickup VARCHAR(255),
  IN p_dest VARCHAR(255),
  IN p_seats_needed INT
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  IF EXISTS (SELECT customer_username, requested_at FROM ride_requests WHERE customer_username = p_customer_username AND status IN ('requested', 'accepted', 'in_progress')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hai gia una richiesta attiva';
  END IF;

  INSERT INTO ride_requests (customer_username, pickup_address, destination_address, seats_needed, status)
  VALUES (p_customer_username, p_pickup, p_dest, p_seats_needed, 'requested');
  COMMIT;
END //

-- Mostra ai tassisti tutte le richieste in attesa con nome cliente
-- Nota: READ UNCOMMITTED potrebbe essere tollerabile a scapito della possibile non validità della lista
CREATE PROCEDURE `sp_list_active_requests`()
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    NULL AS driver_first_name,
    NULL AS driver_last_name,
    NULL AS driver_license,
    NULL AS driver_plate,
    NULL AS driver_credit_card,
    NULL AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  WHERE r.status = 'requested' AND r.driver_username IS NULL
  ORDER BY r.requested_at ASC;
  COMMIT;
END //

-- Permette a un tassista di accettare una corsa disponibile
CREATE PROCEDURE `sp_accept_ride`(
  IN p_driver_username VARCHAR(50),
  IN p_customer_username VARCHAR(50),
  IN p_requested_at DATETIME
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
  START TRANSACTION;
  IF EXISTS (SELECT customer_username, requested_at FROM ride_requests WHERE driver_username = p_driver_username AND status IN ('accepted', 'in_progress')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hai gia una corsa attiva';
  END IF;

  IF EXISTS (
    SELECT r.customer_username, r.requested_at FROM ride_requests r
    CROSS JOIN drivers d
    WHERE r.customer_username = p_customer_username 
      AND r.driver_username IS NULL 
      AND r.requested_at = p_requested_at
      AND d.username = p_driver_username
      AND d.seats < r.seats_needed
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il tuo veicolo non ha abbastanza posti per questa corsa';
  END IF;

  UPDATE ride_requests 
  SET driver_username = p_driver_username, status = 'accepted'
  WHERE customer_username = p_customer_username 
    AND driver_username IS NULL 
    AND requested_at = p_requested_at 
    AND status = 'requested';

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Corsa non disponibile o gia accettata';
  END IF;
  COMMIT;
END //

-- Permette al tassista di annullare l'accettazione se la corsa non è partita
CREATE PROCEDURE `sp_cancel_ride_by_driver`(
  IN p_driver_username VARCHAR(50),
  IN p_customer_username VARCHAR(50),
  IN p_requested_at DATETIME
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  UPDATE ride_requests 
  SET status = 'cancelled'
  WHERE customer_username = p_customer_username 
    AND (driver_username = p_driver_username OR (driver_username IS NULL AND p_driver_username IS NULL OR p_driver_username = ''))
    AND requested_at = p_requested_at 
    AND status = 'accepted';

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossibile cancellare la corsa';
  END IF;
  COMMIT;
END //

-- Permette al cliente di cancellare la propria richiesta
CREATE PROCEDURE `sp_cancel_ride_by_user`(
  IN p_customer_username VARCHAR(50),
  IN p_driver_username VARCHAR(50),
  IN p_requested_at DATETIME
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  UPDATE ride_requests 
  SET status = 'cancelled'
  WHERE customer_username = p_customer_username 
    AND (driver_username = p_driver_username OR (driver_username IS NULL AND (p_driver_username IS NULL OR p_driver_username = '')))
    AND requested_at = p_requested_at 
    AND status IN ('requested', 'accepted');

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossibile cancellare la corsa (gia in corso o completata)';
  END IF;
  COMMIT;
END //

-- Segnala che il cliente è a bordo e la corsa è iniziata
CREATE PROCEDURE `sp_start_ride`(
  IN p_driver_username VARCHAR(50),
  IN p_customer_username VARCHAR(50),
  IN p_requested_at DATETIME
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  UPDATE ride_requests 
  SET status = 'in_progress', started_at = NOW()
  WHERE customer_username = p_customer_username 
    AND driver_username = p_driver_username 
    AND requested_at = p_requested_at 
    AND status = 'accepted';

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossibile avviare la corsa';
  END IF;
  COMMIT;
END //

-- Conclude la corsa, registra l'importo e calcola la commissione
CREATE PROCEDURE `sp_complete_ride`(
  IN p_driver_username VARCHAR(50),
  IN p_customer_username VARCHAR(50),
  IN p_requested_at DATETIME,
  IN p_fare DECIMAL(10,2)
)
BEGIN
  DECLARE v_duration INT;
  DECLARE v_comm DECIMAL(10,2);
  DECLARE v_start DATETIME;
  SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
  START TRANSACTION;
  
  SELECT started_at INTO v_start FROM ride_requests 
  WHERE customer_username = p_customer_username 
    AND driver_username = p_driver_username 
    AND requested_at = p_requested_at;

  SET v_duration = TIMESTAMPDIFF(SECOND, v_start, CURRENT_TIMESTAMP);
  SET v_comm = ROUND(p_fare * 0.03, 2);

  UPDATE ride_requests 
  SET status = 'completed', 
      fare_amount = p_fare,
      duration_seconds = v_duration,
      commission_amount = v_comm
  WHERE customer_username = p_customer_username 
    AND driver_username = p_driver_username 
    AND requested_at = p_requested_at 
    AND status = 'in_progress';

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossibile completare la corsa';
  END IF;
  COMMIT;
END //

-- Ottiene la corsa attiva del cliente
-- Nota: READ UNCOMMITTED potrebbe essere tollerabile a scapito della possibile non validità della lista
CREATE PROCEDURE `sp_get_customer_active_ride`(
  IN p_customer_username VARCHAR(50)
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    d.first_name AS driver_first_name,
    d.last_name AS driver_last_name,
    d.license_number AS driver_license,
    d.vehicle_plate AS driver_plate,
    d.credit_card_number AS driver_credit_card,
    d.seats AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  LEFT JOIN drivers d ON r.driver_username = d.username
  WHERE r.customer_username = p_customer_username 
    AND r.status IN ('requested', 'accepted', 'in_progress')
  ORDER BY r.requested_at DESC
  LIMIT 1;
  COMMIT;
END //

-- Ottiene la corsa attiva del tassista
-- Nota: READ UNCOMMITTED potrebbe essere tollerabile a scapito della possibile non validità della lista
CREATE PROCEDURE `sp_get_driver_active_ride`(
  IN p_driver_username VARCHAR(50)
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    d.first_name AS driver_first_name,
    d.last_name AS driver_last_name,
    d.license_number AS driver_license,
    d.vehicle_plate AS driver_plate,
    d.credit_card_number AS driver_credit_card,
    d.seats AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  JOIN drivers d ON r.driver_username = d.username
  WHERE r.driver_username = p_driver_username 
    AND r.status IN ('accepted', 'in_progress')
  ORDER BY r.requested_at DESC
  LIMIT 1;
  COMMIT;
END //

-- Lista le corse cancellabili dal cliente
-- Nota: READ UNCOMMITTED potrebbe essere tollerabile a scapito della possibile non validità della lista
CREATE PROCEDURE `sp_get_customer_cancellable_rides`(
  IN p_customer_username VARCHAR(50)
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    d.first_name AS driver_first_name,
    d.last_name AS driver_last_name,
    d.license_number AS driver_license,
    d.vehicle_plate AS driver_plate,
    d.credit_card_number AS driver_credit_card,
    d.seats AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  LEFT JOIN drivers d ON r.driver_username = d.username
  WHERE r.customer_username = p_customer_username 
    AND r.status IN ('requested', 'accepted')
  ORDER BY r.requested_at DESC;
  COMMIT;
END //

-- Lista le corse cancellabili dal tassista
-- Nota: READ UNCOMMITTED potrebbe essere tollerabile a scapito della possibile non validità della lista
CREATE PROCEDURE `sp_get_driver_cancellable_rides`(
  IN p_driver_username VARCHAR(50)
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    d.first_name AS driver_first_name,
    d.last_name AS driver_last_name,
    d.license_number AS driver_license,
    d.vehicle_plate AS driver_plate,
    d.credit_card_number AS driver_credit_card,
    d.seats AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  JOIN drivers d ON r.driver_username = d.username
  WHERE r.driver_username = p_driver_username 
    AND r.status = 'accepted'
  ORDER BY r.requested_at DESC;
  COMMIT;
END //

-- Storico corse del cliente
-- Nota: READ COMMITTED potrebbe essere applicato se si vuole garantire la correttezza dei dati
-- essendo i dati proposti non critici e sui quali non si effettuano decisioni/modifiche ritengo READ UNCOMMITTED accettabile.
CREATE PROCEDURE `sp_get_customer_ride_history`(
  IN p_customer_username VARCHAR(50),
  IN p_limit INT
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  START TRANSACTION;
  IF p_limit IS NULL OR p_limit <= 0 THEN
    SET p_limit = 10;
  END IF;
  
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    d.first_name AS driver_first_name,
    d.last_name AS driver_last_name,
    d.license_number AS driver_license,
    d.vehicle_plate AS driver_plate,
    d.credit_card_number AS driver_credit_card,
    d.seats AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  LEFT JOIN drivers d ON r.driver_username = d.username
  WHERE r.customer_username = p_customer_username 
    AND r.status = 'completed'
  ORDER BY r.requested_at DESC
  LIMIT p_limit;
  COMMIT;
END //

-- Storico corse del tassista
-- Nota: READ COMMITTED potrebbe essere applicato se si vuole garantire la correttezza dei dati
-- essendo i dati proposti non critici e sui quali non si effettuano decisioni/modifiche ritengo READ UNCOMMITTED accettabile.
CREATE PROCEDURE `sp_get_driver_ride_history`(
  IN p_driver_username VARCHAR(50),
  IN p_limit INT
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  START TRANSACTION;
  IF p_limit IS NULL OR p_limit <= 0 THEN
    SET p_limit = 10;
  END IF;
  
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    d.first_name AS driver_first_name,
    d.last_name AS driver_last_name,
    d.license_number AS driver_license,
    d.vehicle_plate AS driver_plate,
    d.credit_card_number AS driver_credit_card,
    d.seats AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  JOIN drivers d ON r.driver_username = d.username
  WHERE r.driver_username = p_driver_username 
    AND r.status = 'completed'
  ORDER BY r.requested_at DESC
  LIMIT p_limit;
  COMMIT;
END //

-- Genera il report aggregato per i manager
CREATE PROCEDURE `sp_manager_report`()
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  START TRANSACTION;
  SELECT * FROM v_manager_report;
  COMMIT;
END //

-- Lista le commissioni completate ma non ancora riscosse
CREATE PROCEDURE `sp_manager_list_uncollected_commissions`()
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  SELECT 
    r.*,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.phone AS customer_phone,
    c.credit_card_number AS customer_credit_card,
    d.first_name AS driver_first_name,
    d.last_name AS driver_last_name,
    d.license_number AS driver_license,
    d.vehicle_plate AS driver_plate,
    d.credit_card_number AS driver_credit_card,
    d.seats AS driver_seats
  FROM ride_requests r
  JOIN customers c ON r.customer_username = c.username
  JOIN drivers d ON r.driver_username = d.username
  WHERE r.status = 'completed' AND r.commission_charged_at IS NULL;
  COMMIT;
END //

-- Segna una commissione come riscossa con successo
CREATE PROCEDURE `sp_manager_mark_commission_charged`(
  IN p_customer_username VARCHAR(50),
  IN p_driver_username VARCHAR(50),
  IN p_requested_at DATETIME
)
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;
  UPDATE ride_requests
  SET commission_charged_at = NOW()
  WHERE customer_username = p_customer_username 
    AND driver_username = p_driver_username 
    AND requested_at = p_requested_at 
    AND status = 'completed' AND commission_charged_at IS NULL;
  
  IF ROW_COUNT() = 0 THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Commissione gia riscossa o corsa non valida';
  END IF;
  COMMIT;
END //

DELIMITER ;

-- EVENTI

-- Controlla ogni minuto le richieste scadute (più vecchie di 2 minuti)
CREATE EVENT `evt_expire_rides`
ON SCHEDULE EVERY 1 MINUTE
DO
  UPDATE ride_requests 
  SET status = 'expired'
  WHERE status = 'requested' AND requested_at < (NOW() - INTERVAL 2 MINUTE);

CREATE VIEW `v_manager_report` AS
SELECT 
  d.username,
  d.first_name, 
  d.last_name,
  d.license_number,
  d.vehicle_plate,
  d.credit_card_number,
  d.seats,
  NULL AS password,
  COUNT(r.customer_username) as accepted_rides,
  SUM(r.fare_amount - r.commission_amount) as total_earnings,
  SUM(r.commission_amount) as total_commission
FROM drivers d
LEFT JOIN ride_requests r ON d.username = r.driver_username AND r.status = 'completed'
GROUP BY d.username;

CREATE USER IF NOT EXISTS 'guest'@'localhost' IDENTIFIED BY 'guest';
CREATE USER IF NOT EXISTS 'customer'@'localhost' IDENTIFIED BY 'customer';
CREATE USER IF NOT EXISTS 'driver'@'localhost' IDENTIFIED BY 'driver';
CREATE USER IF NOT EXISTS 'manager'@'localhost' IDENTIFIED BY 'manager';

-- Permessi Guest
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_login TO 'guest'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_register_customer TO 'guest'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_register_driver TO 'guest'@'localhost';

-- Permessi Customer
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_request_ride TO 'customer'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_cancel_ride_by_user TO 'customer'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_get_customer_active_ride TO 'customer'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_get_customer_cancellable_rides TO 'customer'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_get_customer_ride_history TO 'customer'@'localhost';

-- Permessi Driver
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_list_active_requests TO 'driver'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_accept_ride TO 'driver'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_start_ride TO 'driver'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_complete_ride TO 'driver'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_cancel_ride_by_driver TO 'driver'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_get_driver_active_ride TO 'driver'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_get_driver_cancellable_rides TO 'driver'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_get_driver_ride_history TO 'driver'@'localhost';

-- Permessi Manager
GRANT SELECT ON taxi_manager.v_manager_report TO 'manager'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_manager_report TO 'manager'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_manager_list_uncollected_commissions TO 'manager'@'localhost';
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_manager_mark_commission_charged TO 'manager'@'localhost';

FLUSH PRIVILEGES;
