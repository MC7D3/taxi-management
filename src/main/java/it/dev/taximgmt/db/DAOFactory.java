package it.dev.taximgmt.db;

import it.dev.taximgmt.db.dao.AuthDao;
import it.dev.taximgmt.db.dao.CustomerDao;
import it.dev.taximgmt.db.dao.DriverDao;
import it.dev.taximgmt.db.dao.ManagerDao;

public class DAOFactory {

	public static AuthDao getAuthDao(DbSession session) {
		return new AuthDao(session.getConnection());
	}

	public static CustomerDao getCustomerDao(DbSession session) {
		return new CustomerDao(session.getConnection());
	}

	public static DriverDao getDriverDao(DbSession session) {
		return new DriverDao(session.getConnection());
	}

	public static ManagerDao getManagerDao(DbSession session) {
		return new ManagerDao(session.getConnection());
	}
}
