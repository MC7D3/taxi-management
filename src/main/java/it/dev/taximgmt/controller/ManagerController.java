package it.dev.taximgmt.controller;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import it.dev.taximgmt.db.DAOFactory;
import it.dev.taximgmt.model.ReportRow;
import it.dev.taximgmt.model.entity.Customer;
import it.dev.taximgmt.model.entity.Ride;
import it.dev.taximgmt.model.entity.TaxiDriver;
import it.dev.taximgmt.model.Session;

public class ManagerController {

    public static List<ReportRow> getReport() throws SQLException {
        return DAOFactory.getManagerDao(Session.getInstance().getDbSession()).report();
    }

    public static List<Ride> getUncollectedCommissions() throws SQLException {
        return DAOFactory.getManagerDao(Session.getInstance().getDbSession()).listUncollectedCommissions();
    }

    public static void markCommissionCharged(Customer customer, TaxiDriver driver, Timestamp requestedAt)
            throws SQLException {
        DAOFactory.getManagerDao(Session.getInstance().getDbSession()).markCommissionCharged(customer.getUsername(),
                driver.getUsername(), requestedAt);
    }

}
