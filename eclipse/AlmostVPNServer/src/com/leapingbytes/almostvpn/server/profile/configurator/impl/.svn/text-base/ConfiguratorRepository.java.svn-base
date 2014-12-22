package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import com.leapingbytes.almostvpn.server.profile.configurator.spi.IProfileConfigurator;
import com.leapingbytes.jcocoa.NSDictionary;
import com.leapingbytes.jcocoa.NSMutableArray;

public class ConfiguratorRepository {
	static NSMutableArray	_configurators = new NSMutableArray();
	
	static {
		ConfiguratorRepository.registerConfigurator( new SessionConfigurator());
		ConfiguratorRepository.registerConfigurator( new TunnelConfigurator());
		ConfiguratorRepository.registerConfigurator( new PrinterConfigurator());
		ConfiguratorRepository.registerConfigurator( new HostAliasConfigurator());
		ConfiguratorRepository.registerConfigurator( new DriveConfigurator());
		ConfiguratorRepository.registerConfigurator( new FileConfigurator());
		ConfiguratorRepository.registerConfigurator( new RemoteControlConfigurator());
		ConfiguratorRepository.registerConfigurator( new BonjourConfigurator());
	}
	
	public static void registerConfigurator( IProfileConfigurator configurator ) {
		_configurators.add( configurator );
	}
	
	public static IProfileConfigurator findConfigurator( NSDictionary definition ) {
		for( int i = 0; i < _configurators.count(); i++ ) {
			IProfileConfigurator configurator = (IProfileConfigurator) _configurators.objectAtIndex( i );
			if( configurator.canConfigure( definition )) {
				return configurator;
			}
		}
		return null;
	}
}
