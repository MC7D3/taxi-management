package it.dev.taximgmt.view;

import java.sql.SQLException;
import java.util.List;

import it.dev.taximgmt.controller.ManagerController;
import it.dev.taximgmt.model.ReportRow;
import it.dev.taximgmt.model.entity.Ride;

public class ManagerView implements View {

    @Override
    public void present() {
        boolean running = true;
        while (running) {
            System.out.println("\nMenu Manager:");
            System.out.println("1) Report autisti");
            System.out.println("2) Commissioni non riscosse");
            System.out.println("3) Riscuoti commissione");
            System.out.println("0) Esci");

            String choice = prompts.prompt("Scelta");
            try {
                switch (choice) {
                    case "1":
                        viewReport();
                        break;
                    case "2":
                        viewUncollectedCommissions();
                        break;
                    case "3":
                        collectCommission();
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

    private void viewReport() throws SQLException {
        List<ReportRow> report = ManagerController.getReport();
        if (report.isEmpty()) {
            System.out.println("Nessun dato disponibile.");
        } else {
            System.out.println("--- REPORT AGGREGATO AUTISTI ---");
            System.out.println("Autista | Corse Accettate | Guadagno Tassista (Netto) | Commissione Totale");
            for (ReportRow row : report) {
                System.out.println(String.format("%s %s (%s) | %d | %.2f | %.2f",
                        row.getDriver().getFirstName(),
                        row.getDriver().getLastName(),
                        row.getDriver().getUsername(),
                        row.getAcceptedRides(),
                        row.getTotalEarnings(),
                        row.getTotalCommission()));
            }
        }
    }

    private void viewUncollectedCommissions() throws SQLException {
        List<Ride> commissions = ManagerController.getUncollectedCommissions();
        if (commissions.isEmpty()) {
            System.out.println("Nessuna commissione da riscuotere.");
        } else {
            System.out.println("Cliente | Autista | Importo | Richiesta il");
            for (Ride ride : commissions) {
                System.out.println(String.format("%s | %s | %.2f | %s",
                        ride.getCustomer().getUsername(), ride.getDriver().getUsername(),
                        ride.getPricing().getCommissionAmount(), ride.getTiming().getRequestedAt()));
            }
        }
    }

    private void collectCommission() throws SQLException {
        List<Ride> commissions = ManagerController.getUncollectedCommissions();
        if (commissions.isEmpty()) {
            System.out.println("Nessuna commissione da riscuotere.");
            return;
        }

        for (int i = 0; i < commissions.size(); i++) {
            Ride r = commissions.get(i);
            System.out.println((i + 1) + ") Autista: " + r.getDriver().getUsername() + " | Cliente: "
                    + r.getCustomer().getUsername() + " | Importo: " + r.getPricing().getCommissionAmount());
        }
        System.out.println("0) Torna indietro");

        int idx = prompts.promptInt("Scelta") - 1;
        if (idx >= 0 && idx < commissions.size()) {
            Ride selected = commissions.get(idx);
            ManagerController.markCommissionCharged(
                    selected.getCustomer(),
                    selected.getDriver(),
                    selected.getTiming().getRequestedAt());
            System.out.println("Commissione riscossa con successo.");
        }
    }
}
