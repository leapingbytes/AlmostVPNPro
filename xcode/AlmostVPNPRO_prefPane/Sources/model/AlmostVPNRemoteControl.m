//
//  AlmostVPNRemoteControl.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/13/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNRemoteControl.h"
#import "AlmostVPNAccount.h"
#import "PathLocator.h"

#define _ACCOUNT_KEY_				@"account"

#define	_RC_TYPE_KEY_				@"type"
#define _PORT_KEY_					@"port"

#define _BIND_TO_LOCALHOST_KEY_		@"bind-to-localhost"

static NSString*	_keys_[] = {
	_RC_TYPE_KEY_,
	_PORT_KEY_,
	_BIND_TO_LOCALHOST_KEY_,
	nil
};

static NSString*	_rc_types_[] = {
	@"VNC",
	@"ARD",
	@"RDC",
	@"Shell",
	nil
};

@implementation AlmostVPNRemoteControl

+ (void) initialize {
	[self setKeys:[NSArray arrayWithObject:@"rcType"]	triggerChangeNotificationsForDependentKey:@"port" ];
}

- (NSString*) icon {
	return [ NSString stringWithFormat: @"smal%@", [ self rcTypeLabel ]];
}

- (NSString*) name {
	NSString* result = [ self rcTypeLabel ];
	[ self setObject: result forKey: @"name" ];
	return result;
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self setObject: [ AlmostVPNObject objectWithDictionary: [ aDictionary objectForKey: _ACCOUNT_KEY_ ]] forKey: _ACCOUNT_KEY_ ];
	[ self initKeys: _keys_ fromDictionary: aDictionary ];

	return self;
}

- (void) bootstrap {
	AlmostVPNAccount* account = [[ AlmostVPNAccount alloc ] init ];
	[ self setAccount: account ];
	[ account setUserName: NSUserName() ];
	[ account release ];

	[ self setRcType: @"VNC" ];
	[ self setBindToLocalhost: [ NSNumber numberWithBool: YES ]];
}

- (AlmostVPNAccount*) account {
	return [ self objectForKey: _ACCOUNT_KEY_ ];
}

- (void) setAccount: (AlmostVPNAccount*) anAccount {
	[ anAccount setOwner: self ];
	[ self setObject: anAccount forKey: _ACCOUNT_KEY_ ];
}

static NSArray* _rcTypes = nil;
+ (NSArray*) rcTypes {
	if( _rcTypes == nil ) {
		_rcTypes = [ NSArray arrayWithObjects: &(_rc_types_[0]) count: 4 ];
	}
	return _rcTypes;
}

- (id) rcType {
	NSString* s = [ self stringValueForKey: _RC_TYPE_KEY_ ];
	int r = 0;
	for( int i = 0;  _rc_types_[ i ] != nil; i++ ) {
		if( [ s isEqual: _rc_types_[ i ] ] ) {
			r = i;
			break;
		}
	}
	return [ NSNumber numberWithInt: r ];
}

- (NSString*) rcTypeLabel {
	return [ self stringValueForKey: _RC_TYPE_KEY_ ];
}

- (id) rcTypeIcon {
	return [ PathLocator imageNamed: [ self icon ]];
}

- (void) setRcType: (id) v {
	int r = [ v intValue ];
	NSString* s = _rc_types_[ r ];
	[ self setStringValue: s forKey: _RC_TYPE_KEY_ ];
	NSString* defaultPort = @"5900";
	switch( r ) {
		case 0 : defaultPort = @"5900"; break; // VNC
		case 1 : defaultPort = @"5900"; break; // ARD
		case 2 : defaultPort = @"3389"; break; // RDC
		case 3 : defaultPort = @"n/a"; break; // Shell
	}
	[ self setPort: defaultPort ];
}

- (id) port {
	return [ self intObjectForKey: _PORT_KEY_ ];
}

- (void) setPort: (id) v {
	[ self setIntObject: v forKey: _PORT_KEY_ ];
}

- (id) bindToLocalhost {
	return [ self booleanObjectForKey: _BIND_TO_LOCALHOST_KEY_ ];
}

- (void) setBindToLocalhost: (id) v {
	[ self setBooleanObject: v forKey: _BIND_TO_LOCALHOST_KEY_ ];
}

@end
