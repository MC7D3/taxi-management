package it.dev.taximgmt.model;

public class PropertyNotFoundException extends Exception {
	private static final String DEF_MSG = "the specified property is not found or doenst exist";
	public PropertyNotFoundException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public PropertyNotFoundException(Throwable cause) {
		this(DEF_MSG, cause);
	}

	public PropertyNotFoundException() {
		super(DEF_MSG);
	}
	
}
