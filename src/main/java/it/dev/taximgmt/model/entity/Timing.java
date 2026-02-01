package it.dev.taximgmt.model.entity;

import java.sql.Timestamp;

public class Timing {
    private Timestamp requestedAt;
    private Timestamp startedAt;
    private Integer durationSeconds;

    public Timing(Timestamp requestedAt, Timestamp startedAt, Integer durationSeconds) {
        this.requestedAt = requestedAt;
        this.startedAt = startedAt;
        this.durationSeconds = durationSeconds;
    }

    public Timestamp getRequestedAt() {
        return requestedAt;
    }

    public void setRequestedAt(Timestamp requestedAt) {
        this.requestedAt = requestedAt;
    }

    public Timestamp getStartedAt() {
        return startedAt;
    }

    public void setStartedAt(Timestamp startedAt) {
        this.startedAt = startedAt;
    }

    public Integer getDurationSeconds() {
        return durationSeconds;
    }

    public void setDurationSeconds(Integer durationSeconds) {
        this.durationSeconds = durationSeconds;
    }
}
