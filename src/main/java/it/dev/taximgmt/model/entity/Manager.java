package it.dev.taximgmt.model.entity;

public class Manager extends User {
    public Manager(String firstName, String lastName, String username, String passwordHash) {
        super(firstName, lastName, username, passwordHash);
    }
}
