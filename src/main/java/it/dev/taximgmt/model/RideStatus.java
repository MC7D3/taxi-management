package it.dev.taximgmt.model;

public enum RideStatus {
    REQUESTED("requested"),
    ACCEPTED("accepted"),
    IN_PROGRESS("in_progress"),
    COMPLETED("completed"),
    CANCELLED("cancelled"),
    EXPIRED("expired");

    private final String name;

    RideStatus(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public static RideStatus fromString(String status) {
        if (status == null)
            throw new IllegalArgumentException("RideStatus not found");

        for (RideStatus rs : RideStatus.values()) {
            if (rs.getName().equals(status.toLowerCase())) {
                return rs;
            }
        }
        throw new IllegalArgumentException("RideStatus not found");
    }
}
