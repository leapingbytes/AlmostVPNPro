package com.leapingbytes.almostvpn.server.profile;

public class ProfileException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = 2834065371247889483L;
	
	boolean _ignoreCause = false;

	public ProfileException() {
		super();
	}

	public ProfileException(String message) {
		super(message);
	}

	public ProfileException(String message, Throwable cause) {
		super(message, cause);
	}
	public ProfileException(String message, boolean ignoreCauseMessage, Throwable cause) {
		super(message, cause);
		_ignoreCause = ignoreCauseMessage;
	}
	
	public String getLocalizedMessage() {
		if( _ignoreCause || this.getCause() == null ) {
			return super.getLocalizedMessage();
		} else {
			
			return this.getCause().getLocalizedMessage();
		}
	}
	public String toString() {
		return "ProfileException : " + this.getLocalizedMessage();
	}
}
