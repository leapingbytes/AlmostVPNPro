package ch.ethz.ssh2;

import java.io.IOException;

public class ProxyException extends IOException {

	/**
	 * 
	 */
	private static final long serialVersionUID = -1806895819938354814L;
	
	Throwable _cause;

	public ProxyException( String msg ) {
		super( msg );
	}
	
	public ProxyException( String msg, Throwable cause ) {
		super( msg );
		_cause = cause;
	}
	
	public Throwable cause() {
		return _cause;
	}
}
