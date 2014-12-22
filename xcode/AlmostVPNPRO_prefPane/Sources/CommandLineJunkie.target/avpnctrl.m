//
//  avpnctrl.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 12/6/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#include "ServerHelper.h"

void usage() {
	printf("\nUSAGE:\n");
	printf("  avpnctrl\n");
	printf("    list\n");	
	printf("    state <profile name>\n");	
	printf("    start <profile name>\n");	
	printf("    startAll\n");	
	printf("    stop <profile name>\n");	
	printf("    stopAll\n");	
	printf("    wait <profile name> <running|idle|fail>\n");	
}

NSString* getProfileState( NSString* profileName ) {
	NSArray* profiles = [ ServerHelper status ];
	for( int i = 0; i < [ profiles count ]; i++ ) {
		NSString* name = [[ profiles objectAtIndex: i ] objectForKey: @"name" ];
		NSString* state = [[ profiles objectAtIndex: i ] objectForKey: @"state" ];
		if( name == nil ) {
			continue;
		}
		if( [ name isEqual: profileName ] ) {
			return state;
		}
	}
	
	return @"idle";
}

BOOL waitForProfile( NSString* profileName, NSString* targetSate, int timeout ) {
	if( timeout == 0 ) {	
		while( YES ) {
			NSString* state = getProfileState( profileName );
			
			if( [ state isEqual: targetSate ] ) {
				return YES;
			}
			sleep( 1 );
		}
	} else {
		for( int i = 0; i < timeout; i++ ) {
			NSString* state = getProfileState( profileName );
			
			if( [ state isEqual: targetSate ] ) {
				return YES;
			}
			sleep( 1 );
		}
	}
	
	return NO;
}

int main( int argc, char** argv ) {
	if( argc <= 1 ) {
		usage();
		return -1;
	} 
	
	int rc = 0;
	NSAutoreleasePool* poll = [[ NSAutoreleasePool alloc ] init ];

	char* command = argv[ 1 ];

	if( strcmp( command, "list" ) == 0 ) {
		NSArray* profiles = [ ServerHelper status ];
		for( int i = 0; i < [ profiles count ]; i++ ) {
			NSString* name = [[ profiles objectAtIndex: i ] objectForKey: @"name" ];
			NSString* state = [[ profiles objectAtIndex: i ] objectForKey: @"state" ];
			if( name == nil ) {
				continue;
			}
			puts( [[ NSString stringWithFormat: @"%@|%@", name, state ] UTF8String ] );
		}
	} else if( strcmp( command, "startAll" ) == 0 ) {
		NSArray* profiles = [ ServerHelper status ];
		for( int i = 0; i < [ profiles count ]; i++ ) {
			NSString* name = [[ profiles objectAtIndex: i ] objectForKey: @"name" ];
			if( name == nil ) {
				continue;
			}
			NSString* state = [[ profiles objectAtIndex: i ] objectForKey: @"state" ];
			if( [ state isEqual: @"idle" ] || [ state isEqual: @"paused" ] ) {
				[ ServerHelper startProfileAndWait: name ];
			}
		}
	} else if( strcmp( command, "stopAll" ) == 0 ) {
		NSArray* profiles = [ ServerHelper status ];
		for( int i = 0; i < [ profiles count ]; i++ ) {
			NSString* name = [[ profiles objectAtIndex: i ] objectForKey: @"name" ];
			if( name == nil ) {
				continue;
			}
			NSString* state = [[ profiles objectAtIndex: i ] objectForKey: @"state" ];
			if( [ state isEqual: @"running" ] || [ state isEqual: @"failed" ] ) {
				[ ServerHelper stopProfileAndWait: name ];
			}
		}
	} else if( argc <= 2 ) {
		usage();
		return -1;
	} else {
		NSString* profileName = [ NSString stringWithCString: argv[ 2 ] ];
		if( strcmp( command, "start" ) == 0 ) {
			[ ServerHelper startProfileAndWait: profileName ];
		} else if( strcmp( command, "stop" ) == 0 ) {
			[ ServerHelper stopProfileAndWait: profileName ];
		} else if( strcmp( command, "state" ) == 0 ) {
			puts( [ getProfileState( profileName ) UTF8String ] );
		} else if( argc <= 3 ) {
			usage();
			return -1;
		} else {
			NSString* targetState = [ NSString stringWithCString: argv[ 3 ] ];
			int timeout = argc <= 4 ? 0 :[[ NSString stringWithCString: argv[ 4 ] ] intValue ];
			if( strcmp( command, "wait" ) == 0 ) {
				rc = waitForProfile( profileName, targetState, timeout ) ? 0 : 1;
			} else {
				usage();
				return -1;
			}
		}
	}
	
	[ poll drain ];
	return rc;
}
