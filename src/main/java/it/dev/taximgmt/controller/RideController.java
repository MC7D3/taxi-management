package it.dev.taximgmt.controller;

import java.sql.SQLException;
import java.util.List;

import it.dev.taximgmt.db.DAOFactory;
import it.dev.taximgmt.model.Session;
import it.dev.taximgmt.model.entity.Customer;
import it.dev.taximgmt.model.entity.Ride;
import it.dev.taximgmt.model.entity.TaxiDriver;
import it.dev.taximgmt.model.entity.User;

public class RideController {

	public static Ride getActiveRide() throws SQLException {
		User user = Session.getInstance().getLoggedUser();
		if (user instanceof Customer) {
			return DAOFactory.getCustomerDao(Session.getInstance().getDbSession()).getActiveRide(user.getUsername());
		} else if (user instanceof TaxiDriver) {
			return DAOFactory.getDriverDao(Session.getInstance().getDbSession()).getActiveRide(user.getUsername());
		}
		return null;
	}

	public static List<Ride> getCancellableRides() throws SQLException {
		User user = Session.getInstance().getLoggedUser();
		if (user instanceof Customer) {
			return DAOFactory.getCustomerDao(Session.getInstance().getDbSession())
					.getCancellableRides(user.getUsername());
		} else if (user instanceof TaxiDriver) {
			return DAOFactory.getDriverDao(Session.getInstance().getDbSession())
					.getCancellableRides(user.getUsername());
		}
		return List.of();
	}

	public static List<Ride> getRideHistory(int limit) throws SQLException {
		User user = Session.getInstance().getLoggedUser();
		if (user instanceof Customer) {
			return DAOFactory.getCustomerDao(Session.getInstance().getDbSession()).getRideHistory(user.getUsername(),
					limit);
		} else if (user instanceof TaxiDriver) {
			return DAOFactory.getDriverDao(Session.getInstance().getDbSession()).getRideHistory(user.getUsername(),
					limit);
		}
		return List.of();
	}
}
