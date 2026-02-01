package it.dev.taximgmt.view;

import java.sql.SQLException;
import java.util.List;

import it.dev.taximgmt.controller.CustomerController;
import it.dev.taximgmt.controller.RideController;
import it.dev.taximgmt.model.entity.Ride;
import it.dev.taximgmt.model.entity.TaxiDriver;

public class CustomerView implements View {

	@Override
	public void present() {
		boolean running = true;
		while (running) {
			System.out.println("\nMenu Cliente:");
			System.out.println("1) Richiedi corsa");
			System.out.println("2) Cancella corsa");
			System.out.println("3) Visualizza corsa attiva");
			System.out.println("4) Storico corse");
			System.out.println("0) Esci");

			String choice = prompts.prompt("Scelta");
			try {
				switch (choice) {
					case "1":
						requestRide();
						break;
					case "2":
						cancelRide();
						break;
					case "3":
						viewActiveRide();
						break;
					case "4":
						viewHistory();
						break;
					case "0":
						running = false;
						break;
					default:
						System.out.println("Scelta non valida");
				}
			} catch (SQLException e) {
				System.out.println("Errore: " + (e.getMessage() != null ? e.getMessage() : "Operazione fallita"));
			}
		}
	}

	private void requestRide() throws SQLException {
		String pickup = prompts.prompt("Indirizzo di partenza");
		String destination = prompts.prompt("Indirizzo di destinazione");
		int seats = prompts.promptInt("Posti necessari");
		CustomerController.requestRide(pickup, destination, seats);
		System.out.println("Richiesta inviata con successo!");
	}

	private void cancelRide() throws SQLException {
		List<Ride> cancellable = RideController.getCancellableRides();
		if (cancellable.isEmpty()) {
			System.out.println("Nessuna corsa cancellabile.");
			return;
		}

		System.out.println("Seleziona corsa da cancellare:");
		for (int i = 0; i < cancellable.size(); i++) {
			Ride r = cancellable.get(i);
			String driverInfo = r.getDriver() != null ? r.getDriver().getUsername() : "In attesa";
			System.out.println(
					(i + 1) + ") " + r.getRoute().getPickupAddress() + " -> " + r.getRoute().getDestinationAddress()
							+ " | Autista: " + driverInfo);
		}
		System.out.println("0) Torna indietro");

		int idx = prompts.promptInt("Scelta") - 1;
		if (idx >= 0 && idx < cancellable.size()) {
			Ride selected = cancellable.get(idx);
			TaxiDriver driver = selected.getDriver() != null ? selected.getDriver() : null;
			CustomerController.cancelRideByUser(driver, selected.getTiming().getRequestedAt());
			System.out.println("Corsa cancellata con successo.");
		}
	}

	private void viewActiveRide() throws SQLException {
		Ride active = RideController.getActiveRide();
		if (active == null) {
			System.out.println("Nessuna corsa attiva.");
		} else {
			System.out.println("\nDettagli Corsa:");
			System.out.println("Status: " + active.getStatus());
			System.out.println("Percorso: " + active.getRoute().getPickupAddress() + " -> "
					+ active.getRoute().getDestinationAddress());
			if (active.getDriver() != null) {
				System.out.println(
						"Autista: " + active.getDriver().getFirstName() + " " + active.getDriver().getLastName());
				System.out.println("Auto: " + active.getDriver().getCar().getVehiclePlate());
			} else {
				System.out.println("Autista: in ricerca...");
			}
			System.out.println("Richiesta il: " + active.getTiming().getRequestedAt());
		}
	}

	private void viewHistory() throws SQLException {
		List<Ride> history = RideController.getRideHistory(10);
		if (history.isEmpty()) {
			System.out.println("Nessuna corsa completata nello storico.");
		} else {
			System.out.println("\nStorico Corse:");
			for (Ride r : history) {
				System.out.println(String.format("%s -> %s | Fare: %.2f | Durata: %ds",
						r.getRoute().getPickupAddress(), r.getRoute().getDestinationAddress(),
						r.getPricing().getFareAmount(), r.getTiming().getDurationSeconds()));
			}
		}
	}
}
