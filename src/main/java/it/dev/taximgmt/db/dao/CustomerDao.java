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

public class CustomerDao {
	private Connection conn;

	public CustomerDao(Connection conn) {
		this.conn = conn;
	}

	public void requestRide(String username, String pickup, String destination, int seatsNeeded) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_request_ride(?, ?, ?, ?)}")) {
			cs.setString(1, username);
			cs.setString(2, pickup);
			cs.setString(3, destination);
			cs.setInt(4, seatsNeeded);
			cs.execute();
		}
	}

	public void cancelRideByUser(String customerUsername, String driverUsername, Timestamp requestedAt)
			throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_cancel_ride_by_user(?, ?, ?)}")) {
			cs.setString(1, customerUsername);
			cs.setString(2, driverUsername);
			cs.setTimestamp(3, requestedAt);
			cs.execute();
		}
	}

	public Ride getActiveRide(String username) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_get_customer_active_ride(?)}")) {
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
		try (CallableStatement cs = conn.prepareCall("{call sp_get_customer_cancellable_rides(?)}")) {
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
		try (CallableStatement cs = conn.prepareCall("{call sp_get_customer_ride_history(?, ?)}")) {
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
