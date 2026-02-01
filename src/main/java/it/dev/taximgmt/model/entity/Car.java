package it.dev.taximgmt.model.entity;

import java.util.Objects;

public class Car {
    private String vehiclePlate;
    private String creditCard;
    private int seats;

    public Car(String vehiclePlate, String creditCard, int seats) {
        this.vehiclePlate = vehiclePlate;
        this.creditCard = creditCard;
        this.seats = seats;
    }

    public String getVehiclePlate() {
        return vehiclePlate;
    }

    public void setVehiclePlate(String vehiclePlate) {
        this.vehiclePlate = vehiclePlate;
    }

    public String getCreditCard() {
        return creditCard;
    }

    public void setCreditCard(String creditCard) {
        this.creditCard = creditCard;
    }

    public int getSeats() {
        return seats;
    }

    public void setSeats(int seats) {
        this.seats = seats;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        Car other = (Car) obj;
        return Objects.equals(vehiclePlate, other.vehiclePlate);
    }
}
