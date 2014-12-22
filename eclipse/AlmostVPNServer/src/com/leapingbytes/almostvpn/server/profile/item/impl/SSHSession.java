package com.leapingbytes.almostvpn.server.profile.item.impl;

import java.net.InetAddress;
import java.net.UnknownHostException;

import com.leapingbytes.almostvpn.model.AVPNConfiguration;
import com.leapingbytes.almostvpn.server.profile.Profile;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.socks.DynamicProxy;
import com.leapingbytes.almostvpn.util.ssh.ISSHSession;
import com.leapingbytes.almostvpn.util.ssh.SSHSessionFactory;

public class SSHSession extends BaseProfileItem {

	SSHPortForward 	_tunnel;
	String			_hostName;
	String			_hostAddress;
	int				_port;
	String			_userName;
	
	String			_password = null;	
	String			_identityPath = null;
	String			_passphrase = null;
	
	ISSHSession		_session = null;
	
	int 			_timeout = 0;
	int				_keepAlive = 0;
	
	boolean			_runDynamicProxy = false;
	boolean			_shareDynamicProxy = false;
	int				_dynamicProxyPort = 1080;
	
	DynamicProxy	_dynamicProxy = null;
	
	public SSHSession( String hostName, int port, String userName ) throws ProfileException {
		this( null, hostName, port, userName );
	}
	
	public SSHSession( SSHPortForward tunnel, String hostName, int port, String userName ) throws ProfileException {
		setPrerequisit( tunnel );
		
		if( hostName == null ) {
			throw new ProfileException( "Can not create SSHSession. hostName is NULL" );
		}
		try {
			_hostAddress = InetAddress.getByName( hostName ).getHostAddress();
		} catch (UnknownHostException e) {
			throw new ProfileException( "Can not create SSHSession. Fail to resolve " + hostName + " to IP address", e );
		}
		_tunnel = tunnel;
		_hostName = hostName;
		_port = port == 0 ? 22 : port;
		_userName = userName;
	}
	
	public void setTimeout( int v ) {
		_timeout = v;
	}
	public int timeout() {
		return _timeout;
	}
	
	public void setKeepAlive( int v ) {
		_keepAlive = v;
	}
	public int keepAlive() {
		return _keepAlive;
	}
	
	public void setRunDynamicProxy( boolean v ) {
		_runDynamicProxy = v;
	}
	public boolean runDynamicProxy() {
		return _runDynamicProxy;
	}
	
	public void setShareDynamicProxy( boolean v ) {
		_shareDynamicProxy = v;
	}
	public boolean shareDynamicProxy() {
		return _shareDynamicProxy;
	}
	
	public void setDynamicProxyPort( int v ) {
		_dynamicProxyPort = v;
	}
	public int dynamicPorxyPort() {
		return _dynamicProxyPort;
	}

	public ISSHSession getSession() throws ProfileException {
		if( _session == null ) {
			_session = SSHSessionFactory.getSession(_userName, _hostAddress, _port, true );
		}
		if( _timeout > 0 ) {
			_session.setTimeout( _timeout*1000 );
		}
		if( _keepAlive > 0 ) {
			_session.setKeepAlive( _keepAlive );
		}
		_session.setPassword( _password );
		_session.addIdentity( _identityPath, _passphrase );

		return _session;
	}
	
	public String _title() {
		return userName() + "@" + hostName() + ":" + port();
	}
	
	public String hostName() {
		return _hostName;
	}
	
	public int port() {
		return _port;
	}
	
	public String userName() {
		return _userName;
	}
	
	public String actualHostName() {
		return _tunnel == null ? hostName() : _tunnel.bindToAddress();
	}
	
	public int actualPort() throws ProfileException {
		return _tunnel == null ? port() : _tunnel.srcPort();
	}

	public void start() throws ProfileException {
		if( isStartable()) {
			fireEvent( _WILL_START_EVENT_ );
			startDone( "Connecting to " + title());
			getSession();
			_session.start();
			_session.addListener( Profile.threadCurrentProfile());
			if( _runDynamicProxy ) {
				_dynamicProxy = DynamicProxy.start( _session, _shareDynamicProxy, _dynamicProxyPort, AVPNConfiguration.configurationProperty( "control-system-settings", "no" ).equals( "yes" ));
			}
			fireEvent( _DID_START_EVENT_ );
		}
	}

	public void stop() throws ProfileException {
		if( isStoppable() ) {
			fireEvent( _WILL_STOP_EVENT_ );
			_session.deleteListener( Profile.threadCurrentProfile());
			_session.stop();
			if( _dynamicProxy != null ) {
				_dynamicProxy.stop();
				_dynamicProxy = null;
			}
			fireEvent( _DID_STOP_EVENT_ );
		}
		stopDone( "Disconnected from " + title());
	}

	public void setPassword(String v) {
		_password = v;
	}

	public void setIdentity(String path, String passphrase) {
		_identityPath = path;
		_passphrase = passphrase;
	}

	public void setSOCKS5Proxy(String proxyHost, int proxyPort) throws ProfileException {
		getSession().setSOCKS5Proxy( proxyHost, proxyPort );
	}

	public void setHTTPProxy(String proxyHost, int proxyPort) throws ProfileException {
		getSession().setHTTPProxy( proxyHost, proxyPort );
	}
}
