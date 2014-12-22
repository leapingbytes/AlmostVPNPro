//
//  AlmostVPNAccount.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNAccount.h"

#define _USER_NAME_KEY_		@"user-name"
#define _PASSWORD_KEY_		@"password"
#define _USE_PASSWORD_KEY_	@"use-password"
#define _ASK_PASSWORD_KEY_	@"ask-password"

@implementation AlmostVPNAccount
+ (void) initialize {
	[self 
		setKeys:[NSArray arrayWithObjects:@"usePassword", @"askPassword", nil ]	
		triggerChangeNotificationsForDependentKey:@"passwordEditable"
	];
	[self 
		setKeys:[NSArray arrayWithObjects:@"usePassword", @"askPassword", nil ]	
		triggerChangeNotificationsForDependentKey:@"password"
	];
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self setUserName: [ aDictionary objectForKey: _USER_NAME_KEY_ ]];
	[ self setPassword: [ aDictionary objectForKey: _PASSWORD_KEY_ ]];

	[ self setObject: [ aDictionary objectForKey: _USE_PASSWORD_KEY_ ] forKey: _USE_PASSWORD_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _ASK_PASSWORD_KEY_ ] forKey: _ASK_PASSWORD_KEY_ ];
	
	[ AlmostVPNAccount performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (void) bootstrap {
	[ self setUsePassword: [ NSNumber numberWithBool: YES ]];
}

+ (BOOL) isKeySecure: (id) aKey {
	return [ _PASSWORD_KEY_ isEqual: aKey ];
}

- (NSString*) userName {
	return [ self stringValueForKey: _USER_NAME_KEY_ ];
}

- (void) setUserName: (NSString*) value {
	[ self setStringValue: value forKey: _USER_NAME_KEY_ ];
}

- (NSString*) password {
	return [ self stringValueForKey: _PASSWORD_KEY_ ];
}
- (void) setPassword: (NSString*) value {
	[ self setStringValue: value forKey: _PASSWORD_KEY_ ];
	if( [ value length ] == 0 ) {
		[ self setUsePassword: [ NSNumber numberWithBool: NO ]];
	} else {
		[ self setUsePassword: [ NSNumber numberWithBool: YES ]];
	}
}

- (id) usePassword {
	return [ NSNumber numberWithBool: [[ self stringValueForKey: _PASSWORD_KEY_ ] length ] > 0 ];
}

- (id) passwordEditable {
//	BOOL usePassword = [[ self booleanObjectForKey: _USE_PASSWORD_KEY_ ] boolValue ];
//	BOOL askPassword = [[ self booleanObjectForKey: _ASK_PASSWORD_KEY_ ] boolValue ];
//	
//	return [ NSNumber numberWithBool: usePassword && ( ! askPassword )];
	BOOL askPassword = [[ self booleanObjectForKey: _ASK_PASSWORD_KEY_ ] boolValue ];
	
	return [ NSNumber numberWithBool: ! askPassword ];
}

- (void) setUsePassword: (id) value {
	[ self setBooleanObject: value forKey: _USE_PASSWORD_KEY_ ];
//	if( ! [ value boolValue ] ) {
//		[ self setPassword: @"" ];
//	}
}

- (id) askPassword {
	return [ self booleanObjectForKey: _ASK_PASSWORD_KEY_ ];
}
- (void) setAskPassword: (id) value {
	[ self setBooleanObject: value forKey: _ASK_PASSWORD_KEY_ ];
	if( [ value boolValue ] ) {
		[ self setPassword: @"@ASK@" ];
	} else {
		[ self setPassword: @"" ];
	}
}

- (AlmostVPNObject*) owner {
	return _owner;
}

- (void) setOwner: (AlmostVPNObject*) v {
	_owner = v;
}

@end
