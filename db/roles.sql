USE taxi_manager;

CREATE ROLE role_customer;
CREATE ROLE role_driver;
CREATE ROLE role_manager;
CREATE ROLE role_guest;

-- Ruolo guest (non autenticato)
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_register_customer TO role_guest;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_register_driver TO role_guest;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_login_customer TO role_guest;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_login_driver TO role_guest;

-- Ruolo cliente
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_request_ride TO role_customer;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_cancel_ride_by_user TO role_customer;

-- Ruolo tassista
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_list_active_requests TO role_driver;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_accept_ride TO role_driver;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_start_ride TO role_driver;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_complete_ride TO role_driver;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_cancel_ride_by_driver TO role_driver;

-- Ruolo manager
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_manager_report TO role_manager;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_manager_list_uncollected_commissions TO role_manager;
GRANT EXECUTE ON PROCEDURE taxi_manager.sp_manager_mark_commission_charged TO role_manager;

-- Utenti DB per ruolo (sostituire le password)
CREATE USER IF NOT EXISTS 'app_guest'@'%' IDENTIFIED BY 'CHANGE_ME';
GRANT role_guest TO 'app_guest'@'%';
SET DEFAULT ROLE role_guest FOR 'app_guest'@'%';

CREATE USER IF NOT EXISTS 'app_customer'@'%' IDENTIFIED BY 'CHANGE_ME';
GRANT role_customer TO 'app_customer'@'%';
SET DEFAULT ROLE role_customer FOR 'app_customer'@'%';

CREATE USER IF NOT EXISTS 'app_driver'@'%' IDENTIFIED BY 'CHANGE_ME';
GRANT role_driver TO 'app_driver'@'%';
SET DEFAULT ROLE role_driver FOR 'app_driver'@'%';

CREATE USER IF NOT EXISTS 'app_manager'@'%' IDENTIFIED BY 'CHANGE_ME';
GRANT role_manager TO 'app_manager'@'%';
SET DEFAULT ROLE role_manager FOR 'app_manager'@'%';
