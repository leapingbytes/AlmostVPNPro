//
//  AlmostVPNLocalTunnel.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 12/10/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNModel.h"

#define _SOURCE_PORT_KEY_ @"source-port"
#define _SOURCE_LOCATION_KEY_ @"source-location-uuid"

#define _USE_HOST_NAME_AS_IS_KEY	@"use-host-name-as-is"
#define _SHARE_WITH_OTHERS_KEY		@"share-with-others"

@implementation AlmostVPNTunnel
+(void) initialize {
	[self 
		setKeys:[NSArray arrayWithObjects:@"sourceLocation", nil ]	
		triggerChangeNotificationsForDependentKey:@"isLocalTunnel"
	];
	[self 
		setKeys:[NSArray arrayWithObjects:@"sourceLocation", nil ]	
		triggerChangeNotificationsForDependentKey:@"isRemoteTunnel"
	];
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self setObject: [ aDictionary objectForKey: _SOURCE_PORT_KEY_ ] forKey: _SOURCE_PORT_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _SOURCE_LOCATION_KEY_ ] forKey: _SOURCE_LOCATION_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _USE_HOST_NAME_AS_IS_KEY ] forKey: _USE_HOST_NAME_AS_IS_KEY ];
	[ self setObject: [ aDictionary objectForKey: _SHARE_WITH_OTHERS_KEY ] forKey: _SHARE_WITH_OTHERS_KEY ];
	
	[ AlmostVPNTunnel performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (NSString*) name {
	AlmostVPNService* service = (AlmostVPNService*)[ self referencedObject ];
	AlmostVPNHost* host = (AlmostVPNHost*)[ service parent ];
	
	return [ NSString stringWithFormat: @"%@@%@", [ service name ], [ host name ]];
}

- (AlmostVPNLocation*) sourceLocation {
	NSString* uuid = [ self stringValueForKey: _SOURCE_LOCATION_KEY_ ];
	AlmostVPNLocation* result = (AlmostVPNLocation*)[ AlmostVPNObject findObjectWithUUID: uuid ];
	return result;
}

- (id) isLocalTunnel {
	return  [ NSNumber numberWithBool: [[ self sourceLocation ] isEqual: [ AlmostVPNLocalhost sharedInstance ]]];
}

- (id) isRemoteTunnel {
	return  [ NSNumber numberWithBool: ! [[ self sourceLocation ] isEqual: [ AlmostVPNLocalhost sharedInstance ]]];
}

- (void) setSourceLocation: (AlmostVPNLocation*) v {
	[ self setStringValue: [ v uuid ] forKey: _SOURCE_LOCATION_KEY_ ];
	
	if ( [[ self isRemoteTunnel ] boolValue ] ) {
		[ self setShareWithOthers: [ NSNumber numberWithBool: NO ]];
	}
}

- (NSString*) sourcePort {
	return [ self stringValueForKey: _SOURCE_PORT_KEY_ ];
}

- (void) setSourcePort: (NSString*) v {
	[ self setStringValue: v forKey: _SOURCE_PORT_KEY_ ];
}

- (id) useHostNameAsIs {
	return [ self booleanObjectForKey: _USE_HOST_NAME_AS_IS_KEY ];
}

- (void) setUseHostNameAsIs: (id) v {
	[ self setBooleanObject: v forKey: _USE_HOST_NAME_AS_IS_KEY ];
}

- (id) shareWithOthers {
	return [ self booleanObjectForKey: _SHARE_WITH_OTHERS_KEY ];
}

- (void) setShareWithOthers: (id) v {
	[ self setBooleanObject: v forKey: _SHARE_WITH_OTHERS_KEY ];
}

@end
