package com.leapingbytes.almostvpn.server.profile.configurator;

import com.leapingbytes.almostvpn.server.profile.Profile;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.spi.IProfileConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.jcocoa.NSDictionary;

public abstract class BaseConfigurator implements IProfileConfigurator {
	
	String			_className = null;
	
	NSDictionary 	_definition = null;
	
	protected BaseConfigurator( String className ) {
		_className = className;
	}
	
	public boolean canConfigure(NSDictionary definition) {
		return _className.equals( definition.objectForKey( "class-name" ));
	}

	public IProfileItem configure( NSDictionary definition) throws ProfileException {
		_definition = definition;
		
		return null;
	}

	public Profile profile() {
		return Profile.threadCurrentProfile();
	}
	
	public IProfileItem add( IProfileItem item ) throws ProfileException {
		return profile().addItem( item );
	}
}
