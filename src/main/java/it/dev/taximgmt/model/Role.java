package it.dev.taximgmt.model;

public enum Role {
	CUSTOMER("customer"),
	DRIVER("driver"),
	MANAGER("manager");

	private final String name;

	private Role(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public static Role fromName(String name) {
		if (name == null)
			throw new IllegalArgumentException("Role not found");

		for (Role role : Role.values()) {
			if (role.getName().equals(name.toLowerCase())) {
				return role;
			}
		}
		throw new IllegalArgumentException("Role not found");
	}
}
