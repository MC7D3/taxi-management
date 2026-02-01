package it.dev.taximgmt.model;

import it.dev.taximgmt.db.DbSession;
import it.dev.taximgmt.model.entity.User;

public class Session {
	private static Session instance;
	private User loggedUser;
	private DbSession dbSession;

	private Session() {
	}

	public static Session getInstance() {
		if (instance == null) {
			instance = new Session();
		}
		return instance;
	}

	public User getLoggedUser() {
		return loggedUser;
	}

	public void setLoggedUser(User loggedUser) {
		this.loggedUser = loggedUser;
	}

	public DbSession getDbSession() {
		return dbSession;
	}

	public void setDbSession(DbSession dbSession) {
		this.dbSession = dbSession;
	}

}
