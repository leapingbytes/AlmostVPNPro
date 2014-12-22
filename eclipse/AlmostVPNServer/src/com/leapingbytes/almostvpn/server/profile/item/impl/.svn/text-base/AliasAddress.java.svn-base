package com.leapingbytes.almostvpn.server.profile.item.impl;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.util.ResourceAllocator;

public class AliasAddress extends BaseProfileItem {
	
	String		_ip;
	boolean		_addressLocked = false;
	boolean 	_addressAllocated = false;
		
	Script		_script;

	public AliasAddress() {
		this( null );
	}
	
	public AliasAddress( String ip ) {
		_ip = ip;		
	}
	
	public String _title() {
		return ip();
	}
	
	public synchronized String ip() {
		if( ! _addressLocked ) {
			if( _ip == null ) {
				_ip = ResourceAllocator.allocateAddress();
				_addressAllocated = true;
			} else {
				ResourceAllocator.lockAddress( _ip );			
			}
			_addressLocked = true;
		}
		return _ip;
	}

	public synchronized void start() throws ProfileException {
		if( isStartable() ) {
			startDone( "Creating alias IP " + ip());
			_script = new Script(
				"createAlias " + ip(),
				"deleteAlias " + ip()
			);
			_script.start();
		}
	}

	public synchronized void stop() throws ProfileException {
		if( isStoppable() ) {
			_script.stop();
		}		
		stopDone( "Alias IP deleted " + ip());
		if( _addressLocked ) {
			ResourceAllocator.releaseAddress( _ip );
		}
		if( _addressAllocated ) {
			_ip =  null;
		}
		_addressAllocated = _addressLocked = false;
	}

}
