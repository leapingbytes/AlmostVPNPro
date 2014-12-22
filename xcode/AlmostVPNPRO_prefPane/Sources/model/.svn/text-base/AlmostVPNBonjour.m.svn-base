//
//  AlmostVPNBonjour.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 6/14/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNBonjour.h"

#define	_TYPE_KEY_				@"type"
#define	_PORT_KEY_				@"port"
#define _PROPERTIES_KEY_		@"properties"
#define _CUSTOM_PROPERTIES_KEY_	@"custom-properties"

static NSString*	_keys_[] = {
	_TYPE_KEY_,
	_PORT_KEY_,
	_PROPERTIES_KEY_,
	_CUSTOM_PROPERTIES_KEY_,
	nil
};

#define	_BONJOUR_TITLE_KEY_		@"title"

@implementation AlmostVPNBonjour

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self initKeys: _keys_ fromDictionary: aDictionary ];
	
	[ AlmostVPNBonjour performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (void) bootstrap {
	[ super bootstrap ];
	[ self setType: @"_daap._tcp." ];
}

- (NSString*) type {
	return [ super stringValueForKey: _TYPE_KEY_ ];
}

- (void) setType: (NSString*) v {
	[ super setStringValue: v forKey: _TYPE_KEY_ ];
}

- (NSString*) port {
	return [ super stringValueForKey: _PORT_KEY_ ];
}

- (void) setPort: (NSString*) v {
	[ super setStringValue: v forKey: _PORT_KEY_ ];
}


- (id) properties {
	return [ super objectValueForKey: _PROPERTIES_KEY_ ];
}

- (void) setProperties: (id) v {
	[ super setObjectValue: v forKey: _PROPERTIES_KEY_ ];
}

- (id) customProperties {
	return [ super objectValueForKey: _CUSTOM_PROPERTIES_KEY_ ];
}

- (void) setCustomProperties: (id) v {
	[ super setObjectValue: v forKey: _CUSTOM_PROPERTIES_KEY_ ];
}

- (id) bonjourTitle {
	return [ super stringValueForKey: _BONJOUR_TITLE_KEY_ ];
}

- (void) setBonjourTitle: (id) v {
	[ super setStringValue: v forKey: _BONJOUR_TITLE_KEY_ ];
}

@end
