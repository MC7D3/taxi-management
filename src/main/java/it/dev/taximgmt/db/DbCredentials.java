package it.dev.taximgmt.db;

import java.io.IOException;

import it.dev.taximgmt.model.ConfigReader;
import it.dev.taximgmt.model.PropertyNotFoundException;

public class DbCredentials {
	private final String username;
	private final String password;

	public DbCredentials(String username, String password) {
		this.username = username;
		this.password = password;
	}

	public String getUsername() {
		return username;
	}

	public String getPassword() {
		return password;
	}

	public static DbCredentials getGuestUser() throws IOException {
		try {
			ConfigReader reader = new ConfigReader("configuration.properties");
			return new DbCredentials(reader.readGuestUsername(), reader.readGuestPassword());
		} catch (PropertyNotFoundException e) {
			throw new IOException(e);
		}
	}

	public static DbCredentials getDriverUser() throws IOException {
		try {
			ConfigReader reader = new ConfigReader("configuration.properties");
			return new DbCredentials(reader.readDriverUsername(), reader.readDriverPassword());
		} catch (PropertyNotFoundException e) {
			throw new IOException(e);
		}
	}

	public static DbCredentials getCustomerUser() throws IOException {
		try {
			ConfigReader reader = new ConfigReader("configuration.properties");
			return new DbCredentials(reader.readCustomerUsername(), reader.readCustomerPassword());
		} catch (PropertyNotFoundException e) {
			throw new IOException(e);
		}
	}

	public static DbCredentials getManagerUser() throws IOException {
		try {
			ConfigReader reader = new ConfigReader("configuration.properties");
			return new DbCredentials(reader.readManagerUsername(), reader.readManagerPassword());
		} catch (PropertyNotFoundException e) {
			throw new IOException(e);
		}
	}

}
