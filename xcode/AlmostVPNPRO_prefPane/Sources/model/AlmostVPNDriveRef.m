//
//  AlmostVPNDriveRef.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 3/22/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNDriveRef.h"

#define _MOUNT_ON_START_KEY_	@"mount-on-start"
#define _USE_BONJOUR_KEY_		@"use-bonjour"

@implementation AlmostVPNDriveRef
- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ aDictionary objectForKey: _MOUNT_ON_START_KEY_ ] forKey: _MOUNT_ON_START_KEY_ ];	
	[ self setObject: [ aDictionary objectForKey: _USE_BONJOUR_KEY_ ] forKey: _USE_BONJOUR_KEY_ ];	

	[ AlmostVPNDriveRef performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	
	return self;
}

- (id) mountOnStart {
	return [ self booleanObjectForKey: _MOUNT_ON_START_KEY_ ];
}

- (void) setMountOnStart: (id) v {
	[ self setBooleanObject: v forKey: _MOUNT_ON_START_KEY_ ];
}

- (id) useBonjour {
	return [ self booleanObjectForKey: _USE_BONJOUR_KEY_ ];
}

- (void) setUseBonjour: (id) v {
	[ self setBooleanObject: v forKey: _USE_BONJOUR_KEY_ ];
}

@end
