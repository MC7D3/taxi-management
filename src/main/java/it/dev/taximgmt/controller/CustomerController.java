package it.dev.taximgmt.controller;

import java.sql.SQLException;
import java.sql.Timestamp;

import it.dev.taximgmt.db.DAOFactory;
import it.dev.taximgmt.model.Session;
import it.dev.taximgmt.model.entity.TaxiDriver;
import it.dev.taximgmt.model.entity.User;

public class CustomerController {

    public static void requestRide(String pickup, String destination, int seatsNeeded) throws SQLException {
        User customer = Session.getInstance().getLoggedUser();
        DAOFactory.getCustomerDao(Session.getInstance().getDbSession()).requestRide(customer.getUsername(), pickup,
                destination, seatsNeeded);
    }

    public static void cancelRideByUser(TaxiDriver driver, Timestamp requestedAt) throws SQLException {
        User customer = Session.getInstance().getLoggedUser();
        DAOFactory.getCustomerDao(Session.getInstance().getDbSession()).cancelRideByUser(customer.getUsername(),
                driver.getUsername(), requestedAt);
    }
}
