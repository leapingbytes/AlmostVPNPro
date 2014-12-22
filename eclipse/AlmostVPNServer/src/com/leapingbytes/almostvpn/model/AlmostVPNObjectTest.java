package com.leapingbytes.almostvpn.model;

import com.leapingbytes.jcocoa.NSDictionary;

public class AlmostVPNObjectTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		AVPNConfiguration.loadFromFile( 
			"/Users/atchijov/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist" 
		);
		
		NSDictionary profile = AVPNConfiguration.profileWithName( "Secure-Tunnel" );
		
		System.out.println( "Profile : " + profile.objectForKey( "name") );
		int profileChildIdx = 0;
		while( true ) {
			NSDictionary profileChild = (NSDictionary) profile.objectAtPath( "children/" + profileChildIdx );
			if( profileChild == null ) {
				break;
			}
			profileChildIdx++;
			System.out.println( "  " + profileChild.objectForKey( "class-name" ) + " : " + profileChild.objectForKey( "name") );			
		}
		
		NSDictionary[] children = (NSDictionary[]) profile.objectsAtPath( "children/*", NSDictionary.class );
		
		System.out.println( "Profile : " + profile.objectForKey( "name") );
		for( int i = 0; i < children.length; i++ ) {
			System.out.println( "  " + children[i].objectForKey( "class-name" ) + " : " + children[i].objectForKey( "name") );			
		}
	}
}
