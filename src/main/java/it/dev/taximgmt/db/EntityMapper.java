package it.dev.taximgmt.db;

import java.sql.ResultSet;
import java.sql.SQLException;
import it.dev.taximgmt.model.entity.*;
import it.dev.taximgmt.model.RideStatus;

public class EntityMapper {

        public static Customer mapCustomer(ResultSet rs) throws SQLException {
                return new Customer(
                                rs.getString("first_name"),
                                rs.getString("last_name"),
                                rs.getString("username"),
                                rs.getString("password"),
                                rs.getString("phone"),
                                rs.getString("credit_card_number"));
        }

        public static TaxiDriver mapDriver(ResultSet rs) throws SQLException {
                Car car = new Car(rs.getString("vehicle_plate"), rs.getString("credit_card_number"),
                                rs.getInt("seats"));

                return new TaxiDriver(
                                rs.getString("first_name"),
                                rs.getString("last_name"),
                                rs.getString("username"),
                                rs.getString("password"),
                                rs.getString("license_number"),
                                car);
        }

        public static Manager mapManager(ResultSet rs) throws SQLException {
                return new Manager(
                                rs.getString("first_name"),
                                rs.getString("last_name"),
                                rs.getString("username"),
                                rs.getString("password"));
        }

        public static Ride mapRide(ResultSet rs) throws SQLException {
                // Map Customer (assuming standard aliases or specific columns)
                Customer customer = new Customer(
                                rs.getString("customer_first_name"),
                                rs.getString("customer_last_name"),
                                rs.getString("customer_username"),
                                null, // password not needed in ride detail
                                rs.getString("customer_phone"),
                                rs.getString("customer_credit_card"));

                // Map Driver (if exists)
                TaxiDriver driver = null;
                String dUser = rs.getString("driver_username");
                if (dUser != null) {
                        Car car = new Car(
                                        rs.getString("driver_plate"),
                                        null,
                                        rs.getInt("driver_seats"));
                        driver = new TaxiDriver(
                                        rs.getString("driver_first_name"),
                                        rs.getString("driver_last_name"),
                                        dUser,
                                        null,
                                        rs.getString("driver_license"),
                                        car);
                }

                Route route = new Route(
                                rs.getString("pickup_address"),
                                rs.getString("destination_address"),
                                rs.getInt("seats_needed"));

                Timing timing = new Timing(
                                rs.getTimestamp("requested_at"),
                                rs.getTimestamp("started_at"),
                                rs.getObject("duration_seconds") != null ? rs.getInt("duration_seconds") : null);

                Pricing pricing = new Pricing(
                                rs.getDouble("fare_amount"),
                                rs.getDouble("commission_amount"));

                return new Ride(customer, driver, route, RideStatus.fromString(rs.getString("status")), timing,
                                pricing);
        }
}
