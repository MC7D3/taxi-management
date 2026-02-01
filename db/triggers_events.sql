USE taxi_manager;
DELIMITER //

CREATE TRIGGER trg_ride_before_insert
BEFORE INSERT ON ride_requests
FOR EACH ROW
BEGIN
  IF NEW.status IS NULL THEN
    SET NEW.status = 'requested';
  END IF;

  SET NEW.requested_at = COALESCE(NEW.requested_at, NOW());

  IF (SELECT COUNT(*) FROM ride_requests
      WHERE customer_id = NEW.customer_id
        AND status IN ('requested', 'accepted', 'in_progress')) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente con richiesta attiva esistente';
  END IF;
END//

CREATE TRIGGER trg_ride_before_update
BEFORE UPDATE ON ride_requests
FOR EACH ROW
BEGIN
  IF NEW.status = 'accepted' AND OLD.status = 'requested' THEN
    SET NEW.accepted_at = COALESCE(NEW.accepted_at, NOW());
  END IF;

  IF NEW.status = 'in_progress' AND OLD.status = 'accepted' THEN
    SET NEW.started_at = COALESCE(NEW.started_at, NOW());
  END IF;

  IF NEW.status = 'expired' AND OLD.status = 'requested' THEN
    SET NEW.expired_at = COALESCE(NEW.expired_at, NOW());
  END IF;

  IF NEW.status IN ('cancelled_by_user', 'cancelled_by_driver')
     AND OLD.status IN ('requested', 'accepted') THEN
    SET NEW.cancelled_at = COALESCE(NEW.cancelled_at, NOW());
  END IF;

  IF NEW.driver_id IS NOT NULL AND NEW.status IN ('accepted', 'in_progress') THEN
    IF (SELECT COUNT(*) FROM ride_requests
        WHERE driver_id = NEW.driver_id
          AND ride_id <> OLD.ride_id
          AND status IN ('accepted', 'in_progress')) > 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tassista con corsa attiva esistente';
    END IF;
  END IF;

  IF NEW.status = 'completed' THEN
    IF NEW.started_at IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Corsa non avviata';
    END IF;

    IF NEW.fare_amount IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Importo tassametro mancante';
    END IF;

    SET NEW.completed_at = COALESCE(NEW.completed_at, NOW());
    SET NEW.duration_seconds = TIMESTAMPDIFF(SECOND, NEW.started_at, NEW.completed_at);
    SET NEW.commission_amount = ROUND(NEW.fare_amount * 0.03, 2);
    SET NEW.paid_at = COALESCE(NEW.paid_at, NEW.completed_at);
  END IF;
END//

CREATE EVENT ev_expire_requests
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
  UPDATE ride_requests
  SET status = 'expired',
      expired_at = NOW()
  WHERE status = 'requested'
    AND requested_at < (NOW() - INTERVAL 2 MINUTE);
END//

DELIMITER ;