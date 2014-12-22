//
//  AlmostVPNLocalHost.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNLocalhost.h"

static AlmostVPNLocalhost* _sharedInstance = nil;

#define _CAN_SUDO_KEY_		@"can-sudo"

@implementation AlmostVPNLocalhost
+ (AlmostVPNLocalhost*) sharedInstance {
	if( _sharedInstance == nil ) {
		NSArray* array = [ AlmostVPNObject objectsMemberOfClass: self ];
		switch( [ array count ] ) {
			case 0 :
				_sharedInstance = [[ self alloc ] init ];
				[ _sharedInstance setCanSUDO: NO ];
				break;
			case 1 :
				_sharedInstance = [ array objectAtIndex: 0 ];
				break;
			default :
				_sharedInstance = [ array objectAtIndex: 0 ];
				NSLog( @"More then one localhost : %@\n", array );
		}
	}
	return _sharedInstance;
}
- (id) initWithDictionary: (NSDictionary*) aDictionary {
	if( _sharedInstance != nil ) {
		self = _sharedInstance;
	}
	[ super initWithDictionary: aDictionary ];
	
	[ self setValue: [ aDictionary objectForKey: _CAN_SUDO_KEY_ ] forKey: _CAN_SUDO_KEY_ ];	

	[ AlmostVPNLocalhost performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];
	return self;
}

- (id) init {
	if( _sharedInstance == nil ) {
		self = [ super init ];
		[ self setObject: [[ NSHost currentHost ] name ] forKey: _NAME_KEY_ ];
		_sharedInstance = self;
	}
	return _sharedInstance;
}

- (void) bootstrap {
	[ super bootstrap ];
	[ self setName: [[ NSHost currentHost ] name ]];
}

- (NSString*) icon {
	return @"Localhost";
}

- (int) countIdentities {
	return [[ self identities ] count ];
}

- (NSArray*) identities {	
	if( [[ self children ] count ] == 0 ) {
		return [ NSArray array ];
	}
	if( [ self identityWithName: @"-none-" ] == nil ) {
		AlmostVPNIdentity* noIdentity = [[ AlmostVPNIdentity alloc ] init ];
		[ noIdentity setName: @"-none-" ];
		NSMutableArray* children = [ self children ];
		[ self willChangeValueForKey: @"identities" ];
		[ children insertObject: noIdentity atIndex: 0 ];
		[ self didChangeValueForKey: @"identities" ];
	}
	return [ self childrenKindOfClass: [ AlmostVPNIdentity class ]];
}

- (AlmostVPNIdentity*) defaultIdentity {
	NSArray* identities = [ self identities ];
	
	for( int i = 0; i < [ identities count ]; i++ ) {
		AlmostVPNIdentity* identity = [ identities objectAtIndex: i ];
		if( [[ identity isDefaultIdentity ] boolValue ] ) {
			return identity;
		}
	}
	if( [ identities count ] > 0 ) {
		[[ identities objectAtIndex: 0 ] setIsDefaultIdentity: [ NSNumber numberWithBool: YES ]];
		return [ identities objectAtIndex: 0 ];
	}
	
	return nil;
}

- (AlmostVPNIdentity*) identityWithName: (NSString*) name {
	NSArray* identities =  [ self childrenKindOfClass: [ AlmostVPNIdentity class ]];
	for( int i = 0; i < [ identities count ]; i++ ) {
		AlmostVPNIdentity* identity = [ identities objectAtIndex: i ];
		if( [[ identity name ] isEqual: name ] ) {
			return identity;
		}
	}
	return nil;
}

- (BOOL) canHaveChild: (NSString*) childKind {
	if( [ @"Location" isEqual: childKind ] ) {
		return NO;
	}
	return	[ super canHaveChild: childKind ] ||
			[ @"Identity" isEqual: childKind ]
	;
}

- (NSNumber*) canSUDO {
	return [ self booleanObjectForKey: _CAN_SUDO_KEY_ ];
}

- (void) setCanSUDO: (NSNumber*) v {
	[ self setBooleanObject: v forKey: _CAN_SUDO_KEY_ ];
}



@end
