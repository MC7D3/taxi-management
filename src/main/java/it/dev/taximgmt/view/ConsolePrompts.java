package it.dev.taximgmt.view;

import java.util.Scanner;

import it.dev.taximgmt.db.DbCredentials;

public class ConsolePrompts {
	private final Scanner scan;

	public ConsolePrompts(){
		this.scan = new Scanner(System.in);
	}

    public String prompt(String label) {
        System.out.print(label + ": ");
        return scan.nextLine().trim();
    }

    public int promptInt(String label) {
        System.out.print(label + ": ");
        return Integer.parseInt(scan.nextLine().trim());
    }

    public double promptDouble(String label) {
        System.out.print(label + ": ");
        return Double.parseDouble(scan.nextLine().trim());
    }

    public DbCredentials promptDbCredentials(String userLabel, String passLabel) {
        String user = prompt(userLabel);
        String pass = prompt(passLabel);
        return new DbCredentials(user, pass);
    }
}
