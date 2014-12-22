package com.leapingbytes.almostvpn.server.profile.item.impl;

import java.util.Hashtable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.util.Bonjour;
import com.leapingbytes.almostvpn.util.BonjourItem;

public class BonjourAd extends BaseProfileItem implements BonjourItem {
	private static final Log log = LogFactory.getLog( BonjourItem.class );
	
	String 				_type;
	String 				_name;
	String 				_ip4address;
	int 				_port;
	Hashtable	 		_properties;

	public BonjourAd( String type, String name, String ip4ddress, int port, Hashtable properties ) {	
		_type = type;
		_name = name;
		_ip4address = ip4ddress;
		_port = port;
		_properties = properties;
	}
	
	public void start() {
		log.debug( "start : " + title());
		Bonjour.announce( this );
		startDone( title() + " anounced" );
	}

	public void stop() {
		log.debug( "stop : " + title());
		Bonjour.withdraw( this );
		stopDone( title() + " withdrawn" );
	}

	public String _title() {
		return _name + "." + _type + "@" + _ip4address + ":" + _port;
	}

	public String bonjourAddress() {
		return _ip4address;
	}

	public String bonjourName() {
		return _name;
	}

	public int bonjourPort() {
		return _port;
	}

	public Hashtable bonjourProperties() {
		return _properties;
	}

	public String bonjourType() {
		return _type;
	}

}
