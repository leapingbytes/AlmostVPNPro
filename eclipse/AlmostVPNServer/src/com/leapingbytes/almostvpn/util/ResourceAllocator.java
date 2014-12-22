package com.leapingbytes.almostvpn.util;

import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Stack;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ResourceAllocator {
	static final Log log = LogFactory.getLog( ResourceAllocator.class );
	
//	static String			_NETWORK_PREFFIX_ = "169.254";	// link-local address space 
	static String			_NETWORK_PREFFIX_ = "127.13";	// link-local address space 
	static int				_PORT_OFFSET_	  = 13000;	
	static int				_addressCount = 1;	
	
	static ArrayList		_addresses = new ArrayList();
	
	static {
		lockAddress( "127.0.0.1" );
		lockAddress( "0.0.0.0" );
	}
	
	public static String allocateAddress() {
		for( Iterator i = _addresses.iterator(); i.hasNext(); ) {
			Address a = (Address)i.next();
			
			if( ! a.isLocked()) {
				a.lock();
				return a.address();
			}
		}
		String result = allocateNewAddress();
		Address newAddress = new Address( result, true );
		newAddress.lock();		
		_addresses.add( newAddress );
		
		log.debug( "allocateAddress : " + result );
		return result;
	}
	
	public static boolean releaseAddress( String address ) {
		for( Iterator i = _addresses.iterator(); i.hasNext(); ) {
			Address a = (Address)i.next();
			if( address.equals( a.address())) {
				if( a.unlock() == 0 ) {
					if( ! a.isAuto()) {
						log.debug( "releaseAddress : " + address );
						i.remove();
					}
				}
				return true;
			}
		}		
		log.warn( "releaseAddress : address was not locked " + address );
		return false;
	}
	
	public static boolean lockAddress( String address ) {
		for( Iterator i = _addresses.iterator(); i.hasNext(); ) {
			Address a = (Address)i.next();
			if( address.equals( a.address())) {
				a.lock();
				log.debug( "lockAddress : address locked again " + address + " (" + a._lockCount + ")");
				return false;
			}
		}		
		Address newAddress = new Address( address, false );
		newAddress.lock();
		_addresses.add( newAddress );
		log.info( "lockAddress : new address locked " + address  );
		return true;
	}
	
	public static String allocatePortOnAddress( String address ) {
		return allocatePortOnAddress( address, "tcp" );
	}
	public static String allocatePortOnAddress( String address, String protocol ) {
		for( Iterator i = _addresses.iterator(); i.hasNext(); ) {
			Address a = (Address)i.next();
			if( address.equals( a.address())) {
				return a.allocatePort( protocol );
			}
		}		
		log.warn( "allocatePortOnAddress : can not find address " + address  );
		return null;		
	}
	
	public static boolean releasePortOnAddress( String address, int port ) {
		return releasePortOnAddress( address, port, "tcp" );
	}
	public static boolean releasePortOnAddress( String address, int port, String protocol  ) {
		return releasePortOnAddress( address, protocol + ":" + port );
	}
	public static boolean releasePortOnAddress( String address, String port  ) {
		for( Iterator i = _addresses.iterator(); i.hasNext(); ) {
			Address a = (Address)i.next();
			if( address.equals( a.address())) {
				return a.releasePort( port );
			}
		}		
		log.warn( "releasePortOnAddress : can not find address " + address  );
		return false;		
	}
	
	public static boolean lockPortOnAddress( String address, int port  ) {
		return lockPortOnAddress( address, port, "tcp" );
	}
	
	public static boolean lockPortOnAddress( String address, int port, String protocol  ) {
		return lockPortOnAddress( address, protocol + ":" + port );
	}
	
	public static boolean lockPortOnAddress( String address, String port  ) {
		for( Iterator i = _addresses.iterator(); i.hasNext(); ) {
			Address a = (Address)i.next();
			if( address.equals( a.address())) {
				return a.lockPort( port );
			}
		}		
		log.warn( "lockPortOnAddress : can not find address " + address  );
		return false;		
	}
	
	private static String allocateNewAddress() {
		synchronized( _NETWORK_PREFFIX_ ) {
			_addressCount++;
			return _NETWORK_PREFFIX_ + "." + ( _addressCount >> 8 ) + "." + ( _addressCount & 0xff );
		}
	}
	
	public static void printReport( PrintStream stream ) {
		stream.println( "ResourceAllocator : report : START ");
		for( int i = 0; i < _addresses.size(); i++ ) {
			Address a = (Address) _addresses.get( i );
			stream.println( "ResourceAllocator : " + a._address + "(" + a._lockCount + ":" + a._portCount + ")" );
			ArrayList ports = a._allocatedPorts;
			stream.println( "ResourceAllocator :   Allocated Ports" );
			for( int j = 0; j < ports.size(); j++ ) {
				stream.println( "ResourceAllocator :  " + ports.get( j ));
			}
			ports = new ArrayList( a._freePorts );
			stream.println( "ResourceAllocator :   Free Ports" );
			for( int j = 0; j < ports.size(); j++ ) {
				stream.println( "ResourceAllocator :  " + ports.get( j ));
			}
		}
		stream.println( "ResourceAllocator : report : END ");
	}
}

class Address {
	boolean		_auto;
	int			_lockCount = 0;
	String 		_address;
	int			_portCount = ResourceAllocator._PORT_OFFSET_;
	ArrayList	_allocatedPorts = new ArrayList();
	ArrayList	_lockedPorts = new ArrayList();
	Stack		_freePorts = new Stack();
	
	public Address( String address, boolean auto ) {
		_address = address;
		_auto = auto;
	}
	
	public String address() {
		return _address;
	}
	
	public boolean isAuto() {
		return _auto;
	}
	
	public String allocatePort() {
		return allocatePort( "tcp" );
	}
	public String allocatePort( String protocol ) {
		String result = null;
		if( _freePorts.size() > 0 ) {
			result = (String) _freePorts.pop();
			ResourceAllocator.log.debug( "Address.allocatePort : reuse port " + _address + ":" + result  );
		} else {
			int newPort = allocateNewPort();
			result = "" + newPort; 			
			ResourceAllocator.log.info( "Address.allocatePort : new port " + _address + ":" + result  );
		}		
		_allocatedPorts.add( protocol + ":" + result );
		return result;
	}
	
	public boolean releasePort( String port ) {
		if( _allocatedPorts.remove( port ) ) {
			if( ! _lockedPorts.remove( port )) {
				_freePorts.push( port.split(":")[1] );
			}
			ResourceAllocator.log.debug( "Address.releasePort : port released port " + _address + ":" + port  );
			return true;
		} else {
			ResourceAllocator.log.warn( "Address.releasePort : fail to find port " + _address + ":" + port  );
			return false;
		}
	}
	
	public boolean lockPort( String port ) {
		if( _allocatedPorts.contains( port )) {
			ResourceAllocator.log.warn( "Address.lockPort : port already locked " + _address + ":" + port  );
			return false;
		}
		ResourceAllocator.log.debug( "Address.lockPort : port locked " + _address + ":" + port  );
		_allocatedPorts.add( port );
		_lockedPorts.add( port );
		return true;
	} 
	
	public int lock() {
		_lockCount ++;
		return _lockCount;
	}
	
	public boolean isLocked() {
		return _lockCount > 0;
	}
	
	public int unlock() {
		_lockCount--;
		if( _lockCount < 0 ) {
			_lockCount = 0;
		}
		return _lockCount;
	}
	
	public boolean equals( Object o ) {
		if( o instanceof Address ) {
			return _address.equals( ((Address)o));
		}
		return false;
	}
	
	private int allocateNewPort() {
		_portCount++;
		return _portCount;
	}
}