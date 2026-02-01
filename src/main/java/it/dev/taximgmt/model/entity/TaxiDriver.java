package it.dev.taximgmt.model.entity;

public class TaxiDriver extends User {
	private String licenseNumber;
	private Car car;

	public TaxiDriver(String firstName, String lastName, String username, String password, String licenseNumber,
			Car car) {
		super(firstName, lastName, username, password);
		this.licenseNumber = licenseNumber;
		this.car = car;
	}

	public String getLicenseNumber() {
		return licenseNumber;
	}

	public void setLicenseNumber(String licenseNumber) {
		this.licenseNumber = licenseNumber;
	}

	public Car getCar() {
		return car;
	}

	public void setCar(Car car) {
		this.car = car;
	}
}
