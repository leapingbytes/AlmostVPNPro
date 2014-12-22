package com.leapingbytes.almostvpn.server.profile.configurator.spi;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.jcocoa.NSDictionary;

/**
 * 
 * @author atchijov
 *
 */
public interface IProfileConfigurator {
	/**
	 * Returns true if this Profile Configurator can configure AlmostVPN
	 * configuration entity described by definition
	 * @param definition description of AlmostVPN configuration entity
	 * @return true if can configure false otherwise
	 */
	public boolean canConfigure( NSDictionary definition );
	/**
	 * Configure AlmostVPN configuration entity described by definition.
	 * Can create 0 or more Porfile Items (and add them to current profile).
	 * Returns Profile Item which is garantied to be setup/started last among
	 * all Profile Items create by this configurator.
	 * @param definition description of AlmostVPN configuration entity
	 * @return "last" Profile Item.
	 * @throws ProfileException 
	 */
	public IProfileItem configure( NSDictionary definition ) throws ProfileException;
}
