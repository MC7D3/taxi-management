package it.dev.taximgmt.db.dao;

import java.sql.CallableStatement;
import java.sql.Connection;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import it.dev.taximgmt.model.ReportRow;
import it.dev.taximgmt.model.entity.Ride;
import it.dev.taximgmt.model.entity.TaxiDriver;
import it.dev.taximgmt.db.EntityMapper;

public class ManagerDao {
	private Connection conn;

	public ManagerDao(Connection conn) {
		this.conn = conn;
	}

	public List<Ride> listUncollectedCommissions() throws SQLException {
		List<Ride> list = new ArrayList<>();
		try (CallableStatement cs = conn.prepareCall("{call sp_manager_list_uncollected_commissions()}")) {
			try (ResultSet rs = cs.executeQuery()) {
				while (rs.next()) {
					list.add(EntityMapper.mapRide(rs));
				}
			}
		}
		return list;
	}

	public void markCommissionCharged(String customerUsername, String driverUsername, Timestamp requestedAt)
			throws SQLException {
		try (CallableStatement cs = conn.prepareCall("{call sp_manager_mark_commission_charged(?, ?, ?)}")) {
			cs.setString(1, customerUsername);
			cs.setString(2, driverUsername);
			cs.setTimestamp(3, requestedAt);
			cs.execute();
		}
	}

	public List<ReportRow> report() throws SQLException {
		List<ReportRow> report = new ArrayList<>();
		try (CallableStatement cs = conn.prepareCall("{call sp_manager_report()}")) {
			try (ResultSet rs = cs.executeQuery()) {
				while (rs.next()) {
					TaxiDriver driver = EntityMapper.mapDriver(rs);

					report.add(new ReportRow(
							driver,
							rs.getInt("accepted_rides"),
							rs.getFloat("total_earnings"),
							rs.getFloat("total_commission")));
				}
			}
		}
		return report;
	}

}
