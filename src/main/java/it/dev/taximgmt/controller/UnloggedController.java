package it.dev.taximgmt.controller;

import java.sql.SQLException;

import it.dev.taximgmt.db.DAOFactory;
import it.dev.taximgmt.model.AuthException;
import it.dev.taximgmt.model.Session;
import it.dev.taximgmt.model.entity.User;

public class UnloggedController {

	public static boolean authenticate(String username, String password) {
		try {
			User user = DAOFactory.getAuthDao(Session.getInstance().getDbSession()).login(username, password);

			if (user == null) {
				return false;
			}

			Session.getInstance().setLoggedUser(user);
			return true;
		} catch (SQLException e) {
			return false;
		}

	}

	public static void registerCustomer(String firstName, String lastName, String username, String password,
			String phone, String cc) throws AuthException {
		try {
			User user = DAOFactory.getAuthDao(Session.getInstance().getDbSession()).registerCustomer(firstName,
					lastName, username, password,
					phone, cc);

			if (user == null) {
				throw new AuthException();
			}

			Session.getInstance().setLoggedUser(user);
		} catch (SQLException e) {
			throw new AuthException(e);
		}

	}

	public static void registerDriver(String firstName, String lastName, String username, String password,
			String drivingLicense, String plate, String cc, int seats) throws AuthException {
		try {
			User user = DAOFactory.getAuthDao(Session.getInstance().getDbSession()).registerDriver(firstName, lastName,
					username, password,
					drivingLicense, plate, cc, seats);

			if (user == null) {
				throw new AuthException();
			}

			Session.getInstance().setLoggedUser(user);
		} catch (SQLException e) {
			throw new AuthException(e);
		}

	}

}
