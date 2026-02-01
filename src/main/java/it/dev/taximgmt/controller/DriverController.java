package it.dev.taximgmt.controller;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import it.dev.taximgmt.db.DAOFactory;
import it.dev.taximgmt.model.Session;
import it.dev.taximgmt.model.entity.Customer;
import it.dev.taximgmt.model.entity.Ride;
import it.dev.taximgmt.model.entity.User;

public class DriverController {

    public static List<Ride> listActiveRequests() throws SQLException {
        return DAOFactory.getDriverDao(Session.getInstance().getDbSession()).listActiveRequests();
    }

    public static void acceptRide(Customer customer, Timestamp requestedAt) throws SQLException {
        User driver = Session.getInstance().getLoggedUser();
        DAOFactory.getDriverDao(Session.getInstance().getDbSession()).acceptRide(driver.getUsername(),
                customer.getUsername(),
                requestedAt);
    }

    public static void cancelRideByDriver(Customer customer, Timestamp requestedAt) throws SQLException {
        User driver = Session.getInstance().getLoggedUser();
        DAOFactory.getDriverDao(Session.getInstance().getDbSession()).cancelRideByDriver(driver.getUsername(),
                customer.getUsername(), requestedAt);
    }

    public static void startRide(Customer customer, Timestamp requestedAt) throws SQLException {
        User driver = Session.getInstance().getLoggedUser();
        DAOFactory.getDriverDao(Session.getInstance().getDbSession()).startRide(driver.getUsername(),
                customer.getUsername(),
                requestedAt);
    }

    public static void completeRide(Customer customer, Timestamp requestedAt, double fare) throws SQLException {
        User driver = Session.getInstance().getLoggedUser();
        DAOFactory.getDriverDao(Session.getInstance().getDbSession()).completeRide(driver.getUsername(),
                customer.getUsername(),
                requestedAt, fare);
    }
}
