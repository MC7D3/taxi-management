package it.dev.taximgmt.view;

import java.sql.SQLException;
import java.util.List;

import it.dev.taximgmt.controller.DriverController;
import it.dev.taximgmt.controller.RideController;
import it.dev.taximgmt.model.RideStatus;
import it.dev.taximgmt.model.entity.Ride;

public class TaxiDriverView implements View {

	@Override
	public void present() {
		boolean running = true;
		while (running) {
			System.out.println("\nMenu Tassista:");
			System.out.println("1) Lista richieste attive");
			System.out.println("2) Accetta corsa");
			System.out.println("3) Avvia corsa");
			System.out.println("4) Completa corsa");
			System.out.println("5) Cancella corsa");
			System.out.println("6) Visualizza corsa attiva");
			System.out.println("7) Storico corse");
			System.out.println("0) Esci");

			String choice = prompts.prompt("Scelta");
			try {
				switch (choice) {
					case "1":
						listActiveRequests();
						break;
					case "2":
						acceptRide();
						break;
					case "3":
						startRide();
						break;
					case "4":
						completeRide();
						break;
					case "5":
						cancelRide();
						break;
					case "6":
						viewActiveRide();
						break;
					case "7":
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

	private void listActiveRequests() throws SQLException {
		List<Ride> requests = DriverController.listActiveRequests();
		if (requests.isEmpty()) {
			System.out.println("Nessuna richiesta attiva disponibile.");
		} else {
			System.out.println("Cliente | Pickup -> Destination | Data Richiesta");
			for (Ride r : requests) {
				System.out.println(String.format("%s %s (%s) | %s -> %s | Posti: %d | Data: %s",
						r.getCustomer().getFirstName(), r.getCustomer().getLastName(), r.getCustomer().getUsername(),
						r.getRoute().getPickupAddress(), r.getRoute().getDestinationAddress(),
						r.getRoute().getSeatsNeeded(), r.getTiming().getRequestedAt()));
			}
		}
	}

	private void acceptRide() throws SQLException {
		List<Ride> requests = DriverController.listActiveRequests();
		if (requests.isEmpty()) {
			System.out.println("Nessuna richiesta da accettare.");
			return;
		}

		System.out.println("Seleziona richiesta:");
		for (int i = 0; i < requests.size(); i++) {
			Ride r = requests.get(i);
			System.out.println(
					(i + 1) + ") " + r.getCustomer().getUsername() + " | " + r.getRoute().getPickupAddress() + " -> "
							+ r.getRoute().getDestinationAddress());
		}
		System.out.println("0) Annulla");

		int idx = prompts.promptInt("Numero corsa") - 1;
		if (idx >= 0 && idx < requests.size()) {
			Ride selected = requests.get(idx);
			DriverController.acceptRide(selected.getCustomer(), selected.getTiming().getRequestedAt());
			System.out.println("Corsa accettata!");
		}
	}

	private void startRide() throws SQLException {
		Ride active = RideController.getActiveRide();
		if (active != null && RideStatus.ACCEPTED.equals(active.getStatus())) {
			DriverController.startRide(active.getCustomer(), active.getTiming().getRequestedAt());
			System.out.println("Corsa avviata!");
		} else {
			System.out.println("Nessuna corsa da avviare.");
		}
	}

	private void completeRide() throws SQLException {
		Ride active = RideController.getActiveRide();
		if (active != null && RideStatus.IN_PROGRESS.equals(active.getStatus())) {
			double fare = prompts.promptDouble("Inserisci importo corsa");
			DriverController.completeRide(active.getCustomer(), active.getTiming().getRequestedAt(), fare);
			System.out.println("Corsa completata!");
		} else {
			System.out.println("Nessuna corsa in corso.");
		}
	}

	private void cancelRide() throws SQLException {
		List<Ride> cancellable = RideController.getCancellableRides();
		if (cancellable.isEmpty()) {
			System.out.println("Nessuna corsa cancellabile.");
			return;
		}

		for (int i = 0; i < cancellable.size(); i++) {
			Ride r = cancellable.get(i);
			System.out.println(
					(i + 1) + ") Cliente: " + r.getCustomer().getUsername() + " | " + r.getRoute().getPickupAddress()
							+ " -> " + r.getRoute().getDestinationAddress());
		}
		System.out.println("0) Torna indietro");

		int idx = prompts.promptInt("Scelta") - 1;
		if (idx >= 0 && idx < cancellable.size()) {
			Ride selected = cancellable.get(idx);
			DriverController.cancelRideByDriver(selected.getCustomer(), selected.getTiming().getRequestedAt());
			System.out.println("Corsa cancellata con successo.");
		}
	}

	private void viewActiveRide() throws SQLException {
		Ride active = RideController.getActiveRide();
		if (active == null) {
			System.out.println("Nessuna corsa attiva.");
		} else {
			System.out.println("\nDettagli Corsa:");
			System.out.println(
					"Cliente: " + active.getCustomer().getFirstName() + " " + active.getCustomer().getLastName());
			System.out.println("Status: " + active.getStatus());
			System.out.println("Percorso: " + active.getRoute().getPickupAddress() + " -> "
					+ active.getRoute().getDestinationAddress());
			System.out.println("Richiesta il: " + active.getTiming().getRequestedAt());
		}
	}

	private void viewHistory() throws SQLException {
		List<Ride> history = RideController.getRideHistory(10);
		if (history.isEmpty()) {
			System.out.println("Nessuna corsa nello storico.");
		} else {
			System.out.println("\nStorico:");
			for (Ride r : history) {
				System.out.println(String.format("Cliente: %s | %s -> %s | Fare: %.2f | Durata: %ds",
						r.getCustomer().getUsername(), r.getRoute().getPickupAddress(),
						r.getRoute().getDestinationAddress(),
						r.getPricing().getFareAmount(), r.getTiming().getDurationSeconds()));
			}
		}
	}
}
