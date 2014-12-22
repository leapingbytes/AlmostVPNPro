package com.leapingbytes.almostvpn.server.profile.item.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.util.ResourceAllocator;

public class SSHUdpPortForward extends SSHCommandPipe {
	private static final Log log = LogFactory.getLog( SSHUdpPortForward.class );

	public static final int	LOCAL = 1;
	public static final int	REMOTE = 2;
	
	int			_direction;
	int			_srcPort;
	boolean		_srcPortWasAllocated = false;
	String		_dstHost;
	boolean		_useDstHostAsIs = false;
	int			_dstPort;
	
	boolean		_bindToAddressWasAllocated = false;
	String		_bindToAddress = "127.0.0.1";
	
	boolean 	_portLocked = false;
	
	public SSHUdpPortForward(SSHSession session, 
			int direction, 
			int srcPort, 
			String dstHost, 
			int dstPort, 
			boolean useDstHostAsIs  
	) {
		super( session );
		
		_direction = direction;
		_srcPort = srcPort;				
		_dstHost = dstHost;
		_useDstHostAsIs = useDstHostAsIs;
		if(( ! _useDstHostAsIs ) && session.actualHostName().equals( _dstHost )) {
			_dstHost = "127.0.0.1";
		}
		_dstPort = dstPort;
	}
	public String _title() {
		try {
			return ( _direction == LOCAL ?"-Ludp " : "-Rudp " ) + 
				srcPort() + ":" + dstHost() + ":" + dstPort() +
				" ( " + _session.actualHostName() + " )";
		} catch (ProfileException e) {
			log.error( "title: Fail to build title", e );
			return null;
		}
	}
	
	public boolean isLocal() {
		return _direction == LOCAL;
	}
	
	public boolean isRemote() {
		return _direction == REMOTE;
	}
	
	public int srcPort() throws ProfileException {
		if( _srcPort == 0 ) {
			_srcPortWasAllocated = true;
			_srcPort = Integer.parseInt( ResourceAllocator.allocatePortOnAddress( bindToAddress()));
		} else if( ! _portLocked ) {
			if( ! ResourceAllocator.lockPortOnAddress( _bindToAddress, _srcPort, "udp" )) {
				throw new ProfileException( "Port conflict! Fail to lock port " + _srcPort + " on " + _bindToAddress );
			}
		}
		_portLocked = true;
		
		return _srcPort;
	}
	
	public String dstHost() {
		return _dstHost;
	}
	
	public int dstPort() {
		return _dstPort;
	}
	
	public String	bindToAddress() {
		if( _bindToAddress == null ) {
			_bindToAddressWasAllocated = true;
			_bindToAddress = ResourceAllocator.allocateAddress();
		}
		return _bindToAddress;
	}
	
	public SSHUdpPortForward setBindToAddress( String v ) throws ProfileException {
		if( _portLocked ) {
			throw new ProfileException( "setBindToAddress : Can not change bind to address after src port have been locked");
		}
		_bindToAddress = v;
		return this;
	}
	
	public void start() throws ProfileException {
		buildCommands();
		super.start();
	}
	
	private void buildCommands() throws ProfileException {
		String localCommand;
		String remoteCommand;
		if( _direction == LOCAL ) {
			localCommand = "/usr/bin/nc -u -l -p " + srcPort() + " -s " + bindToAddress();
			remoteCommand = "/usr/bin/nc -u -s 127.0.0.1 " + dstHost() + " " + dstPort();
		} else {
			localCommand = "/usr/bin/nc -u -s 127.0.0.1 " + dstHost() + " " + dstPort();
			remoteCommand = "/usr/bin/nc -u -l -p " + srcPort();
		}
		
		initialize( null, localCommand, remoteCommand );
	}
}
