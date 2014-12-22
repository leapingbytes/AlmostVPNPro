//
//  AlmostVPNBonjourRef.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 6/17/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNBonjourRef.h"

#define _LOCAL_PORT_KEY_		@"local-port"

@implementation AlmostVPNBonjourRef
- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ aDictionary objectForKey: _LOCAL_PORT_KEY_ ] forKey: _LOCAL_PORT_KEY_ ];	
	
	[ AlmostVPNBonjourRef performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	

	return self;
}

- (NSString*) localPort {
	return [ self stringValueForKey: _LOCAL_PORT_KEY_ ];
}

- (void) setLocalPort: (NSString*) port {
	[ self setStringValue: port forKey: _LOCAL_PORT_KEY_ ];
}

@end
