package it.dev.taximgmt.model.entity;

public class Route {
    private String pickupAddress;
    private String destinationAddress;
    private int seatsNeeded;

    public Route(String pickupAddress, String destinationAddress, int seatsNeeded) {
        this.pickupAddress = pickupAddress;
        this.destinationAddress = destinationAddress;
        this.seatsNeeded = seatsNeeded;
    }

    public String getPickupAddress() {
        return pickupAddress;
    }

    public void setPickupAddress(String pickupAddress) {
        this.pickupAddress = pickupAddress;
    }

    public String getDestinationAddress() {
        return destinationAddress;
    }

    public void setDestinationAddress(String destinationAddress) {
        this.destinationAddress = destinationAddress;
    }

    public int getSeatsNeeded() {
        return seatsNeeded;
    }

    public void setSeatsNeeded(int seatsNeeded) {
        this.seatsNeeded = seatsNeeded;
    }
}
