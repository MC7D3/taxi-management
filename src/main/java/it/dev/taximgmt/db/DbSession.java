package it.dev.taximgmt.db;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import it.dev.taximgmt.model.ConfigReader;
import it.dev.taximgmt.model.PropertyNotFoundException;

public class DbSession implements AutoCloseable {
    private final Connection conn;
	private static String url;

	static{
		try {
			ConfigReader reader = new ConfigReader("configuration.properties");
			DbSession.url = reader.readJdbcUrl();
		} catch (IOException | PropertyNotFoundException e) {
			throw new IllegalStateException(e);
		}


	}

    private DbSession(Connection conn) {
        this.conn = conn;
    }

    public static DbSession open(DbCredentials creds) throws SQLException {
        return new DbSession(DriverManager.getConnection(url, creds.getUsername(), creds.getPassword()));
    }

	public static DbSession openUnlogged() throws IOException, SQLException {
		return open(DbCredentials.getGuestUser());

	}

	public Connection getConnection(){
		return conn;
	}

    @Override
    public void close() throws SQLException {
        conn.close();
    }
}
