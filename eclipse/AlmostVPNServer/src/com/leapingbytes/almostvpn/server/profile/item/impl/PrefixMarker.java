package com.leapingbytes.almostvpn.server.profile.item.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;

public class PrefixMarker extends CompoundMarker {
	private static final Log log = LogFactory.getLog( PrefixMarker.class );
	
	private static final PrefixMarker _singleton = new PrefixMarker();
	
	private PrefixMarker() {
		super( "::prefix::");
	}
	
	public static PrefixMarker marker() {
		return _singleton;
	}
	
	public static void addPrefixItem( IProfileItem item ) {
		_singleton.addItem( item );
	}

	public BaseProfileItem setPrerequisit(IProfileItem v) {
		// DO NOTHING BUT COMPLAIN
		log.error( "setPrerequisit : Can not set prerequisit for ::prefix:: marker" );
		return this;
	}
	
	
}
