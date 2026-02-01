package it.dev.taximgmt.db.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import it.dev.taximgmt.model.entity.Ride;
import it.dev.taximgmt.db.EntityMapper;

public class DriverDao {
	private Connection conn;

	public DriverDao(Connection conn) {
		this.conn = conn;
	}

	public List<Ride> listActiveRequests() throws SQLException {
		List<Ride> list = new ArrayList<>();
		try (CallableStatement cs = conn.prepareCall("{call sp_list_active_requests()}")) {
			try (ResultSet rs = cs.executeQuery()) {
				while (rs.next()) {
					list.add(EntityMapper.mapRide(rs));
				}
			}
		}
		return list;
	}

	public void acceptRide(String driverUsername, String customerUsername, Timestamp requestedAt) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_accept_ride(?, ?, ?)}")) {
			cs.setString(1, driverUsername);
			cs.setString(2, customerUsername);
			cs.setTimestamp(3, requestedAt);
			cs.execute();
		}
	}

	public void cancelRideByDriver(String driverUsername, String customerUsername, Timestamp requestedAt)
			throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_cancel_ride_by_driver(?, ?, ?)}")) {
			cs.setString(1, driverUsername);
			cs.setString(2, customerUsername);
			cs.setTimestamp(3, requestedAt);
			cs.execute();
		}
	}

	public void startRide(String driverUsername, String customerUsername, Timestamp requestedAt) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_start_ride(?, ?, ?)}")) {
			cs.setString(1, driverUsername);
			cs.setString(2, customerUsername);
			cs.setTimestamp(3, requestedAt);
			cs.execute();
		}
	}

	public void completeRide(String driverUsername, String customerUsername, Timestamp requestedAt, double fare)
			throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_complete_ride(?, ?, ?, ?)}")) {
			cs.setString(1, driverUsername);
			cs.setString(2, customerUsername);
			cs.setTimestamp(3, requestedAt);
			cs.setDouble(4, fare);
			cs.execute();
		}
	}

	public Ride getActiveRide(String username) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_get_driver_active_ride(?)}")) {
			cs.setString(1, username);
			try (ResultSet rs = cs.executeQuery()) {
				if (rs.next()) {
					return EntityMapper.mapRide(rs);
				}
			}
		}
		return null;
	}

	public List<Ride> getCancellableRides(String username) throws SQLException {
		List<Ride> list = new ArrayList<>();
		try (CallableStatement cs = conn.prepareCall("{call sp_get_driver_cancellable_rides(?)}")) {
			cs.setString(1, username);
			try (ResultSet rs = cs.executeQuery()) {
				while (rs.next()) {
					list.add(EntityMapper.mapRide(rs));
				}
			}
		}
		return list;
	}

	public List<Ride> getRideHistory(String username, int limit) throws SQLException {
		List<Ride> list = new ArrayList<>();
		try (CallableStatement cs = conn.prepareCall("{call sp_get_driver_ride_history(?, ?)}")) {
			cs.setString(1, username);
			cs.setInt(2, limit);
			try (ResultSet rs = cs.executeQuery()) {
				while (rs.next()) {
					list.add(EntityMapper.mapRide(rs));
				}
			}
		}
		return list;
	}
}
