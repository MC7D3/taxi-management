package it.dev.taximgmt;

import java.sql.SQLException;

import it.dev.taximgmt.db.DbCredentials;
import it.dev.taximgmt.db.DbSession;
import it.dev.taximgmt.model.Session;
import it.dev.taximgmt.model.entity.Customer;
import it.dev.taximgmt.model.entity.Manager;
import it.dev.taximgmt.model.entity.TaxiDriver;
import it.dev.taximgmt.view.AuthView;
import it.dev.taximgmt.view.CustomerView;
import it.dev.taximgmt.view.TaxiDriverView;
import it.dev.taximgmt.view.ManagerView;
import java.io.IOException;

public class Main {
	public static void main(String[] args) {
		try {
			Session.getInstance().setDbSession(DbSession.open(DbCredentials.getGuestUser()));
			AuthView authView = new AuthView();
			authView.present();

			if (Session.getInstance().getLoggedUser() != null) {
				switch (Session.getInstance().getLoggedUser()) {
					case Customer customer:
						Session.getInstance().setDbSession(DbSession.open(DbCredentials.getCustomerUser()));
						CustomerView customerView = new CustomerView();
						customerView.present();
						break;
					case TaxiDriver taxiDriver:
						Session.getInstance().setDbSession(DbSession.open(DbCredentials.getDriverUser()));
						TaxiDriverView taxiDriverView = new TaxiDriverView();
						taxiDriverView.present();
						break;
					case Manager manager:
						Session.getInstance().setDbSession(DbSession.open(DbCredentials.getManagerUser()));
						ManagerView managerView = new ManagerView();
						managerView.present();
						break;
					default:
						System.out.println("ERRORE: Ruolo non riconosciuto");
						break;
				}
			}
		} catch (SQLException e) {
			System.out.println("ERRORE: impossibile stabilire una connessione con il database");
		} catch (IOException e) {
			System.out.println("ERRORE: impossibile leggere la configurazione di configuration.properties");
		}
	}
}
