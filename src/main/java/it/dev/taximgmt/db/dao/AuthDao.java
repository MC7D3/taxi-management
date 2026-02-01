package it.dev.taximgmt.db.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

import it.dev.taximgmt.model.Role;
import it.dev.taximgmt.model.entity.User;
import it.dev.taximgmt.db.EntityMapper;

public class AuthDao {
	private final Connection conn;

	public AuthDao(Connection conn) {
		this.conn = conn;
	}

	public User login(String username, String password) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("CALL sp_login(?, ?)")) {
			cs.setString(1, username);
			cs.setString(2, password);
			try (ResultSet rs = cs.executeQuery()) {
				if (!rs.next()) {
					return null;
				}
				Role role = Role.fromName(rs.getString("role"));

				switch (role) {
					case CUSTOMER:
						return EntityMapper.mapCustomer(rs);
					case DRIVER:
						return EntityMapper.mapDriver(rs);
					case MANAGER:
						return EntityMapper.mapManager(rs);
					default:
						return null;

				}
			}
		}

	}

	public User registerCustomer(String firstName, String lastName,
			String username, String password, String phone,
			String creditCard) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("CALL sp_register_customer(?, ?, ?, ?, ?, ?)")) {
			cs.setString(1, firstName);
			cs.setString(2, lastName);
			cs.setString(3, username);
			cs.setString(4, password);
			cs.setString(5, phone);
			cs.setString(6, creditCard);
			cs.execute();
			return login(username, password);
		}

	}

	public User registerDriver(String firstName, String lastName,
			String username, String password, String drivingLicense, String plate,
			String creditCard, int seats) throws SQLException {
		try (CallableStatement cs = conn.prepareCall("CALL sp_register_driver(?, ?, ?, ?, ?, ?, ?, ?)")) {
			cs.setString(1, firstName);
			cs.setString(2, lastName);
			cs.setString(3, username);
			cs.setString(4, password);
			cs.setString(5, drivingLicense);
			cs.setString(6, plate);
			cs.setString(7, creditCard);
			cs.setInt(8, seats);
			cs.execute();

			return login(username, password);
		}

	}
}
