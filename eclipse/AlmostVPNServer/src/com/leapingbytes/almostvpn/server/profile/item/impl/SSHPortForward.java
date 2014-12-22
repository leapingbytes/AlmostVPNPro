package com.leapingbytes.almostvpn.server.profile.item.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.util.ResourceAllocator;

public class SSHPortForward extends BaseProfileItem {
	private static final Log log = LogFactory.getLog( SSHPortForward.class );
	
	public static final int	LOCAL = 1;
	public static final int	REMOTE = 2;
	
	SSHSession	_session;
	int			_direction;
	int			_srcPort;
	boolean		_srcPortWasAllocated = false;
	String		_dstHost;
	boolean		_useDstHostAsIs = false;
	int			_dstPort;
	
	boolean		_bindToAddressWasAllocated = false;
	String		_bindToAddress = "127.0.0.1";
	
	boolean 	_portLocked = false;
	
	public SSHPortForward( SSHSession session, int direction, int srcPort, String dstHost, int dstPort ) {		
		this( session, direction, srcPort, dstHost, dstPort, false );
	}
	public SSHPortForward( SSHSession session, int direction, int srcPort, String dstHost, int dstPort, boolean useDstHostAsIs ) {				
		_session = session;
		_direction = direction;
		_srcPort = srcPort;				
		_dstHost = dstHost;
		_useDstHostAsIs = useDstHostAsIs;
		if(( ! _useDstHostAsIs ) && session.actualHostName().equals( _dstHost )) {
			_dstHost = "127.0.0.1";
		}
		_dstPort = dstPort;
	}
	
//	public int hashCode() {
//		return title().hashCode() + _session.hashCode();
//	}
//
//	public boolean equals( Object o ) {
//		if( ! super.equals( o )) {
//			return false;
//		}
//		
//		SSHPortForward other = (SSHPortForward)o;
//		
//		return _session.equals( other._session );
//	}
	
	public boolean equals( Object o ) {
		if( o instanceof SSHPortForward ) {
			SSHPortForward that = (SSHPortForward) o;
			
			if( this._srcPort == 0 || this._bindToAddress == null ) {
				return false;
			}
			if( this._srcPort != that._srcPort ) {
				return false;
			}

			if( ! this._bindToAddress.equals( that._bindToAddress )) {
				return false;
			}
			
			if( this._dstPort != that._dstPort )  {
				return false;
			}
			
			if( ! this._dstHost.equals( that._dstHost )) {
				return false;
			}
			
			return true;
		} else {
			return false;
		}
	}
	

	public String _title() {
		try {
			return ( _direction == LOCAL ?"-L " : "-R " ) + 
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
			if( ! ResourceAllocator.lockPortOnAddress( _bindToAddress, _srcPort )) {
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
	
	public SSHPortForward setBindToAddress( String v ) throws ProfileException {
		if( _portLocked ) {
			throw new ProfileException( "setBindToAddress : Can not change bind to address after src port have been locked");
		}
		_bindToAddress = v;
		return this;
	}

	public void start() throws ProfileException {
		if( isStartable()) {
			startDone( "Establishing tunnel '" + title() + "'" );
			if( _direction == LOCAL ) {
				_session.getSession().addLocalTunnel( bindToAddress(), srcPort(), _dstHost, _dstPort );
			} else {
				_session.getSession().addRemoteTunnel( "127.0.0.1", srcPort(), _dstHost, _dstPort );
			}			
		}
	}

	public void stop() throws ProfileException {
		ProfileException pe = null;
		if( isStoppable()) {
			try {
				if( _direction == LOCAL ) {
					_session.getSession().delLocalTunnel( bindToAddress(), srcPort() );
				} else {
					_session.getSession().delRemoteTunnel( srcPort() );
				}
			} catch ( ProfileException e ) {
				pe = e;
			}
			stopDone( "Canceled tunnel '" + title() + "'" );
		}
		if( _portLocked ) {
			ResourceAllocator.releasePortOnAddress( _bindToAddress, srcPort() );
		}
		if( _srcPortWasAllocated ) {
			_srcPort = 0;
		}
		if( _bindToAddressWasAllocated ) {
			ResourceAllocator.releaseAddress( _bindToAddress );
		}
		_portLocked = _srcPortWasAllocated = _bindToAddressWasAllocated = false;
		if( pe != null ) {
			throw pe;
		}
	}
}
