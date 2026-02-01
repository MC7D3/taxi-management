package it.dev.taximgmt.model;

import java.sql.SQLException;

public class AuthException extends Exception {
    public static final String DEF_MSG = "errore durante l'autenticazione";

    public AuthException() {
        super(DEF_MSG);
    }

    public AuthException(Exception cause) {
        super(cause.getMessage(), cause);
    }

    public AuthException(SQLException cause) {
        super(cause.getMessage().split(" ", 2)[1], cause);
    }
}
