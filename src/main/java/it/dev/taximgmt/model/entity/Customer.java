package it.dev.taximgmt.model.entity;

public class Customer extends User {
	private String phone;
	private String creditCard;

	public Customer(String firstName, String lastName, String username, String password, String phone,
			String creditCard) {
		super(firstName, lastName, username, password);
		this.phone = phone;
		this.creditCard = creditCard;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getCreditCard() {
		return creditCard;
	}

	public void setCreditCard(String creditCard) {
		this.creditCard = creditCard;
	}

}
