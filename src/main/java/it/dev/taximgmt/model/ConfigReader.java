package it.dev.taximgmt.model;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

public class ConfigReader {
	Properties conf;

	public ConfigReader(String path) throws IOException {
		File confFile = new File(path);
		this.conf = new Properties();
		conf.load(new FileReader(confFile));
	}


	public String readJdbcUrl() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.conf.url");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
	}

	public String readJdbcDriver() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.conf.jdbcdriver");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
	}

	public String readDriverUsername() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.driver.username");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
	}

	public String readDriverPassword() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.driver.password");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
	}

	public String readGuestUsername() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.guest.username");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
	}

	public String readGuestPassword() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.guest.password");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
	}


    public String readCustomerUsername() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.customer.username");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
    }


    public String readCustomerPassword() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.customer.password");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
    }


    public String readManagerUsername() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.manager.username");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
    }


    public String readManagerPassword() throws PropertyNotFoundException {
		String res = conf.getProperty("jdbc.manager.password");
		if (res != null)
			return res;
		throw new PropertyNotFoundException();
    }
}
