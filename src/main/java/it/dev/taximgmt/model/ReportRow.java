package it.dev.taximgmt.model;

import it.dev.taximgmt.model.entity.TaxiDriver;

public class ReportRow {
    private final TaxiDriver driver;
    private final int acceptedRides;
    private final float totalEarnings;
    private final float totalCommission;

    public ReportRow(TaxiDriver driver, int acceptedRides,
            float totalEarnings, float totalCommission) {
        this.driver = driver;
        this.acceptedRides = acceptedRides;
        this.totalEarnings = totalEarnings;
        this.totalCommission = totalCommission;
    }

    public TaxiDriver getDriver() {
        return driver;
    }

    public int getAcceptedRides() {
        return acceptedRides;
    }

    public float getTotalEarnings() {
        return totalEarnings;
    }

    public float getTotalCommission() {
        return totalCommission;
    }
}
