USE taxi_manager;
DELIMITER //

CREATE PROCEDURE sp_register_driver(
  IN p_first_name VARCHAR(50),
  IN p_last_name VARCHAR(50),
  IN p_username VARCHAR(50),
  IN p_password VARCHAR(255),
  IN p_license_number VARCHAR(30),
  IN p_vehicle_plate VARCHAR(20),
  IN p_credit_card_number VARCHAR(32),
  IN p_seats INT
)
BEGIN
  INSERT INTO drivers (
    first_name, last_name, username, password_hash,
    license_number, vehicle_plate, credit_card_number, seats
  ) VALUES (
    p_first_name, p_last_name, p_username, SHA2(p_password, 256),
    p_license_number, p_vehicle_plate, p_credit_card_number, p_seats
  );
END//

CREATE PROCEDURE sp_register_customer(
  IN p_first_name VARCHAR(50),
  IN p_last_name VARCHAR(50),
  IN p_username VARCHAR(50),
  IN p_password VARCHAR(255),
  IN p_phone VARCHAR(30),
  IN p_credit_card_number VARCHAR(32)
)
BEGIN
  INSERT INTO customers (
    first_name, last_name, username, password_hash, phone, credit_card_number
  ) VALUES (
    p_first_name, p_last_name, p_username, SHA2(p_password, 256),
    p_phone, p_credit_card_number
  );
END//

CREATE PROCEDURE sp_login_customer(
  IN p_username VARCHAR(50),
  IN p_password VARCHAR(255)
)
BEGIN
  SELECT
    customer_id,
    first_name,
    last_name,
    username,
    phone,
    credit_card_number,
    'customer' AS role
  FROM customers
  WHERE username = p_username
    AND password_hash = SHA2(p_password, 256);
END//

CREATE PROCEDURE sp_login_driver(
  IN p_username VARCHAR(50),
  IN p_password VARCHAR(255)
)
BEGIN
  SELECT
    driver_id,
    first_name,
    last_name,
    username,
    license_number,
    vehicle_plate,
    credit_card_number,
    seats,
    'driver' AS role
  FROM drivers
  WHERE username = p_username
    AND password_hash = SHA2(p_password, 256);
END//

CREATE PROCEDURE sp_request_ride(
  IN p_customer_id INT,
  IN p_pickup_address VARCHAR(255),
  IN p_destination_address VARCHAR(255)
)
BEGIN
  DECLARE v_count INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;

  SELECT COUNT(*) INTO v_count
  FROM customers
  WHERE customer_id = p_customer_id
  FOR UPDATE;

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente inesistente';
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ride_requests
  WHERE customer_id = p_customer_id
    AND status IN ('requested', 'accepted', 'in_progress');

  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente con richiesta attiva';
  END IF;

  INSERT INTO ride_requests (
    customer_id, pickup_address, destination_address, status, requested_at
  ) VALUES (
    p_customer_id, p_pickup_address, p_destination_address, 'requested', NOW()
  );

  COMMIT;
END//

CREATE PROCEDURE sp_list_active_requests()
BEGIN
  SELECT ride_id, customer_id, pickup_address, destination_address, requested_at
  FROM ride_requests
  WHERE status = 'requested'
    AND requested_at >= (NOW() - INTERVAL 2 MINUTE)
  ORDER BY requested_at ASC;
END//

CREATE PROCEDURE sp_accept_ride(
  IN p_driver_id INT,
  IN p_ride_id INT
)
BEGIN
  DECLARE v_count INT DEFAULT 0;
  DECLARE v_status VARCHAR(20);
  DECLARE v_requested_at DATETIME;
  DECLARE v_not_found INT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;

  SELECT COUNT(*) INTO v_count
  FROM drivers
  WHERE driver_id = p_driver_id
  FOR UPDATE;

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tassista inesistente';
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ride_requests
  WHERE driver_id = p_driver_id
    AND status IN ('accepted', 'in_progress')
  FOR UPDATE;

  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tassista con corsa attiva';
  END IF;

  SELECT status, requested_at
  INTO v_status, v_requested_at
  FROM ride_requests
  WHERE ride_id = p_ride_id
  FOR UPDATE;

  IF v_not_found = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta inesistente';
  END IF;

  IF v_status <> 'requested' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta non accettabile';
  END IF;

  IF v_requested_at < (NOW() - INTERVAL 2 MINUTE) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta scaduta';
  END IF;

  UPDATE ride_requests
  SET status = 'accepted',
      driver_id = p_driver_id,
      accepted_at = NOW()
  WHERE ride_id = p_ride_id
    AND status = 'requested';

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta non accettabile';
  END IF;

  COMMIT;
END//

CREATE PROCEDURE sp_start_ride(
  IN p_driver_id INT,
  IN p_ride_id INT
)
BEGIN
  DECLARE v_status VARCHAR(20);
  DECLARE v_driver_id INT;
  DECLARE v_not_found INT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;

  SELECT status, driver_id
  INTO v_status, v_driver_id
  FROM ride_requests
  WHERE ride_id = p_ride_id
  FOR UPDATE;

  IF v_not_found = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta inesistente';
  END IF;

  IF v_driver_id <> p_driver_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tassista non associato';
  END IF;

  IF v_status <> 'accepted' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stato non valido per avvio';
  END IF;

  UPDATE ride_requests
  SET status = 'in_progress',
      started_at = NOW()
  WHERE ride_id = p_ride_id;

  COMMIT;
END//

CREATE PROCEDURE sp_complete_ride(
  IN p_driver_id INT,
  IN p_ride_id INT,
  IN p_fare_amount DECIMAL(10,2)
)
BEGIN
  DECLARE v_status VARCHAR(20);
  DECLARE v_driver_id INT;
  DECLARE v_not_found INT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_fare_amount IS NULL OR p_fare_amount < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Importo non valido';
  END IF;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;

  SELECT status, driver_id
  INTO v_status, v_driver_id
  FROM ride_requests
  WHERE ride_id = p_ride_id
  FOR UPDATE;

  IF v_not_found = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta inesistente';
  END IF;

  IF v_driver_id <> p_driver_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tassista non associato';
  END IF;

  IF v_status <> 'in_progress' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stato non valido per chiusura';
  END IF;

  UPDATE ride_requests
  SET status = 'completed',
      fare_amount = p_fare_amount,
      completed_at = NOW()
  WHERE ride_id = p_ride_id;

  COMMIT;
END//

CREATE PROCEDURE sp_cancel_ride_by_user(
  IN p_customer_id INT,
  IN p_ride_id INT
)
BEGIN
  DECLARE v_status VARCHAR(30);
  DECLARE v_customer_id INT;
  DECLARE v_not_found INT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;

  SELECT status, customer_id
  INTO v_status, v_customer_id
  FROM ride_requests
  WHERE ride_id = p_ride_id
  FOR UPDATE;

  IF v_not_found = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta inesistente';
  END IF;

  IF v_customer_id <> p_customer_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente non associato';
  END IF;

  IF v_status = 'requested' OR v_status = 'accepted' THEN
    UPDATE ride_requests
    SET status = 'cancelled_by_user',
        cancelled_at = NOW()
    WHERE ride_id = p_ride_id;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stato non cancellabile dal cliente';
  END IF;

  COMMIT;
END//

CREATE PROCEDURE sp_cancel_ride_by_driver(
  IN p_driver_id INT,
  IN p_ride_id INT
)
BEGIN
  DECLARE v_status VARCHAR(30);
  DECLARE v_driver_id INT;
  DECLARE v_not_found INT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;

  SELECT status, driver_id
  INTO v_status, v_driver_id
  FROM ride_requests
  WHERE ride_id = p_ride_id
  FOR UPDATE;

  IF v_not_found = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta inesistente';
  END IF;

  IF v_driver_id <> p_driver_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tassista non associato';
  END IF;

  IF v_status <> 'accepted' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stato non cancellabile dal tassista';
  END IF;

  UPDATE ride_requests
  SET status = 'requested',
      driver_id = NULL,
      accepted_at = NULL,
      driver_cancelled_at = NOW()
  WHERE ride_id = p_ride_id;

  COMMIT;
END//

CREATE PROCEDURE sp_manager_report()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_driver_id INT;
  DECLARE v_accepted INT DEFAULT 0;
  DECLARE v_earnings DECIMAL(10,2) DEFAULT 0;
  DECLARE v_commission DECIMAL(10,2) DEFAULT 0;

  DECLARE cur CURSOR FOR
    SELECT driver_id FROM drivers ORDER BY driver_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_driver_report (
    driver_id INT,
    accepted_rides INT,
    total_earnings DECIMAL(10,2),
    total_commission DECIMAL(10,2)
  ) ENGINE=MEMORY;

  TRUNCATE TABLE tmp_driver_report;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_driver_id;
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    SELECT COUNT(*)
    INTO v_accepted
    FROM ride_requests
    WHERE driver_id = v_driver_id
      AND accepted_at IS NOT NULL;

    SELECT
      COALESCE(SUM(fare_amount - commission_amount), 0),
      COALESCE(SUM(commission_amount), 0)
    INTO v_earnings, v_commission
    FROM ride_requests
    WHERE driver_id = v_driver_id
      AND status = 'completed';

    INSERT INTO tmp_driver_report (
      driver_id, accepted_rides, total_earnings, total_commission
    ) VALUES (
      v_driver_id, v_accepted, v_earnings, v_commission
    );
  END LOOP;
  CLOSE cur;

  SELECT r.driver_id, d.first_name, d.last_name,
         r.accepted_rides, r.total_earnings, r.total_commission
  FROM tmp_driver_report r
  JOIN drivers d ON d.driver_id = r.driver_id
  ORDER BY r.driver_id;
END//

CREATE PROCEDURE sp_manager_list_uncollected_commissions()
BEGIN
  SELECT ride_id, driver_id, commission_amount, completed_at
  FROM ride_requests
  WHERE status = 'completed'
    AND commission_charged_at IS NULL
  ORDER BY completed_at ASC;
END//

CREATE PROCEDURE sp_manager_mark_commission_charged(
  IN p_ride_id INT
)
BEGIN
  DECLARE v_status VARCHAR(30);
  DECLARE v_commission DECIMAL(10,2);
  DECLARE v_charged DATETIME;
  DECLARE v_not_found INT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  START TRANSACTION;

  SELECT status, commission_amount, commission_charged_at
  INTO v_status, v_commission, v_charged
  FROM ride_requests
  WHERE ride_id = p_ride_id
  FOR UPDATE;

  IF v_not_found = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Richiesta inesistente';
  END IF;

  IF v_status <> 'completed' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Commissione non applicabile';
  END IF;

  IF v_commission IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Commissione mancante';
  END IF;

  IF v_charged IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Commissione gia'' riscossa';
  END IF;

  UPDATE ride_requests
  SET commission_charged_at = NOW()
  WHERE ride_id = p_ride_id;

  COMMIT;
END//

DELIMITER ;
