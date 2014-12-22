package com.leapingbytes.almostvpn.server.profile.item.spi;

import com.leapingbytes.almostvpn.server.profile.ProfileException;

/*
 * INIT -> start() -> RUNNING -> stop() -> STOPPED 
 */
public interface IProfileItem {
	public static final int	INIT 		= 1;
	public static final int RUNNING 	= 2;
	public static final int STOPPED 	= 3;

	/**
	 * returns true if this Profile Item depends on otherItem. 
	 * One item depends on another one if the other one needs to be running
	 * in order for the first one to be able to run.
	 * @param otherItem other Profile Item
	 * @return true or false
	 */
	public boolean dependsOn( IProfileItem otherItem );

	/**
	 * Reports current state of the profile item
	 * @return INIT|RUNNING|STOPPED
	 */
	public int	state();
	
	/**
	 * Called in order to start the profile item
	 * @throws ProfileException
	 */
	public void start() throws ProfileException;
	
	/**
	 * Called in order to stop the profile item
	 * @throws ProfileException
	 */
	public void stop() throws ProfileException;	

	/**
	 * Called on Profile Item when it needs to be dismiss 
	 * due to duplication. Usually result of Profile.add()
	 * 
	 * @throws ProfileException
	 */
	public void dismiss() throws ProfileException;
}
