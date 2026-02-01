package it.dev.taximgmt.model.entity;

public class Pricing {
    private double fareAmount;
    private double commissionAmount;

    public Pricing(double fareAmount, double commissionAmount) {
        this.fareAmount = fareAmount;
        this.commissionAmount = commissionAmount;
    }

    public double getFareAmount() {
        return fareAmount;
    }

    public void setFareAmount(double fareAmount) {
        this.fareAmount = fareAmount;
    }

    public double getCommissionAmount() {
        return commissionAmount;
    }

    public void setCommissionAmount(double commissionAmount) {
        this.commissionAmount = commissionAmount;
    }
}
