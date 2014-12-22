package com.leapingbytes.almostvpn.util.ssh;

import java.util.ArrayList;

public abstract class SSHSessionBase implements ISSHSession {

	protected String		_sshUserName;
	protected String		_sshServerName;
	protected int			_sshPort;
	
	protected String		_sshPassword;
	
	protected SSHSessionBase( String userName, String sshServerName, int sshPort ) {
		_sshUserName = userName;
		_sshServerName = sshServerName;
		_sshPort = sshPort;
	}
	
	public void setPassword(String v) {
		_sshPassword = v;
	}
	
	public int sshPort() {
		return _sshPort;
	}

	public String sshServerName() {
		return _sshServerName;
	}

	public String sshUserName() {
		return _sshUserName;
	}
	
	public String toString() {
		return _sshUserName + "@" + _sshServerName + ":" + _sshPort;
	}

	/* ========================================================================
	 * Listener support 
	 * ======================================================================== */
	ArrayList _listeners = new ArrayList();	
	public boolean addListener( ISSHSession.IStateListener listener) {
		synchronized( _listeners ) {
			if( ! _listeners.contains( listener )) {
				_listeners.add( listener );
				return true;
			} else {
				return false;
			}
		}
	}
	
	public boolean deleteListener(ISSHSession.IStateListener listener) {
		synchronized( _listeners ) {
			return _listeners.remove( listener );
		}
	}

	protected void stateEvent( String comment, Throwable t ) {
		ArrayList snapshot = null;
		synchronized( _listeners ) {
			snapshot = (ArrayList) _listeners.clone();
		}
		for( int i = 0; i < snapshot.size(); i++ ) {
			((ISSHSession.IStateListener)snapshot.get( i )).event( this, comment, t);
		}
	}

	/* ========================================================================
	 * Proxy support 
	 * ======================================================================== */
	protected String		_proxyType = null;
	protected String		_proxyHost = null;
	protected int			_proxyPort = 0;
	
	public void setHTTPProxy(String proxyHost, int proxyPort) {
		_proxyType = "http";
		_proxyHost = proxyHost;
		_proxyPort = proxyPort;
	}

	public void setSOCKS5Proxy(String proxyHost, int proxyPort) {
		_proxyType = "socks";
		_proxyHost = proxyHost;
		_proxyPort = proxyPort;
	}

	/* ========================================================================
	 * Timeouts
	 * ======================================================================== */	
	protected int _keepAlive = 0;
	public int keepAlive() {
		return _keepAlive;
	}
	public void setKeepAlive(int v) {
		_keepAlive = v;
	}

	protected int	_timeout = 60*1000;	
	public int timeout() {
		return _timeout;
	}
	public void setTimeout(int v) {
		_timeout = v;
	}
}
