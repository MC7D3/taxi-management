package it.dev.taximgmt.view;

import java.sql.SQLException;

import it.dev.taximgmt.controller.UnloggedController;
import it.dev.taximgmt.model.AuthException;

public class AuthView implements View {

    @Override
    public void present() {
        boolean running = true;
        while (running) {
            System.out.println("\nMenu principale:");
            System.out.println("1) Login");
            System.out.println("2) Registrazione cliente");
            System.out.println("3) Registrazione tassista");
            System.out.println("0) Esci");

            String choice = prompts.prompt("Scelta");
            try {
                switch (choice) {
                    case "1":
                        running = login();
                        break;
                    case "2":
                        running = registerCustomer();
                        break;
                    case "3":
                        running = registerDriver();
                        break;
                    case "0":
                        System.exit(0);
                    default:
                        System.out.println("Scelta non valida");
                }
            } catch (SQLException e) {
                // Gestione errori user-friendly in italiano
                String message = e.getMessage();
                if (message != null && !message.isEmpty()) {
                    System.out.println("Errore: " + message);
                } else if (e.getSQLState() != null && e.getSQLState().equals("23000")) {
                    System.out.println("Errore: Username, telefono o targa gia esistenti");
                } else {
                    System.out.println("Errore durante l'operazione. Riprova.");
                }
            }
        }
    }

    private boolean login() throws SQLException {
        String username = prompts.prompt("Username");
        String password = prompts.prompt("Password");
        boolean ret = UnloggedController.authenticate(username, password);
        if (ret) {
            System.out.println("Login effettuato con successo");
        } else {
            System.out.println("Credenziali errate");
        }
        return !ret;

    }

    private boolean registerCustomer() throws SQLException {
        String first = prompts.prompt("Nome");
        String last = prompts.prompt("Cognome");
        String username = prompts.prompt("Username");
        String password = prompts.prompt("Password");
        String phone = prompts.prompt("Telefono");
        String cc = prompts.prompt("Carta di credito (16 cifre)");

        try {
            UnloggedController.registerCustomer(first, last, username, password, phone, cc);
            return false;
        } catch (AuthException e) {
            System.out.println("ERRORE: " + e.getMessage());
            return true;
        }
    }

    private boolean registerDriver() throws SQLException {
        String first = prompts.prompt("Nome");
        String last = prompts.prompt("Cognome");
        String username = prompts.prompt("Username");
        String password = prompts.prompt("Password");
        String license = prompts.prompt("Patente");
        String plate = prompts.prompt("Targa");
        String cc = prompts.prompt("Carta di credito (16 cifre)");
        int seats = prompts.promptInt("Posti");

        try {
            UnloggedController.registerDriver(first, last, username, password, license, plate, cc, seats);
            return false;
        } catch (AuthException e) {
            System.out.println("ERRORE: " + e.getMessage());
            return true;
        }
    }
}
