package it.dev.taximgmt.model.entity;

import it.dev.taximgmt.model.RideStatus;

public class Ride {
    private final Customer customer;
    private final TaxiDriver driver;
    private Route route;
    private RideStatus status;
    private Timing timing;
    private Pricing pricing;

    public Ride(Customer customer, TaxiDriver driver, Route route, RideStatus status, Timing timing, Pricing pricing) {
        this.customer = customer;
        this.driver = driver;
        this.route = route;
        this.status = status;
        this.timing = timing;
        this.pricing = pricing;
    }

    public Customer getCustomer() {
        return customer;
    }

    public TaxiDriver getDriver() {
        return driver;
    }

    public Route getRoute() {
        return route;
    }

    public void setRoute(Route route) {
        this.route = route;
    }

    public RideStatus getStatus() {
        return status;
    }

    public void setStatus(RideStatus status) {
        this.status = status;
    }

    public Timing getTiming() {
        return timing;
    }

    public void setTiming(Timing timing) {
        this.timing = timing;
    }

    public Pricing getPricing() {
        return pricing;
    }

    public void setPricing(Pricing pricing) {
        this.pricing = pricing;
    }
}
