//
//  AlmostVPNHost.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/4/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNHost.h"
#import "AlmostVPNResource.h"

#define _RESOLVABLE_KEY_	@"resolvable"
#define _ADDRESS_KEY_		@"address"
#define _ADDRESS_IPV6_KEY_	@"address-ipv6"

@implementation AlmostVPNHost
static id<HostResolver> _resolver;

+ (void) initialize {
	[self setKeys:[NSArray arrayWithObjects: @"name", nil ] triggerChangeNotificationsForDependentKey:@"address" ];
}

+(id<HostResolver>)resolver {
	return _resolver;
}

+(void) setResolver: (id<HostResolver>)v {
	_resolver = v;
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self setAddress: [ aDictionary objectForKey: _ADDRESS_KEY_ ]];
	
	[ AlmostVPNHost performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (BOOL) resolvable {
	return [ self booleanValueForKey: _RESOLVABLE_KEY_ ];
}

- (void) setResolvable: (BOOL) value {
	[ self setBooleanValue: value forKey: _RESOLVABLE_KEY_ ];
}

- (void) setName: (NSString*) v {
	if( [ @"localhost" isEqual: v ] ) {
		[[ NSSound soundNamed: @"Basso" ] play ];
		return;
	}
	[ self willChangeValueForKey: @"address" ];
	[ super setName: v ];
	[ self didChangeValueForKey: @"address" ];
}

- (NSString*) address {	
	NSString* result = [ self stringValueForKey: _ADDRESS_KEY_ ];
	if( result == nil ) {
		result = [ _resolver hostNameToAddress: [ self name ]];
	}
	return result;
}

- (void) setAddress: (NSString*) anAddress {
	if( anAddress == nil ) {
		[ self removeObjectForKey: _ADDRESS_KEY_ ];
	} else {
		[ self setStringValue: anAddress forKey: _ADDRESS_KEY_ ];
		[ _resolver rememberHostName: [ self name ] withAddress: [ self address ]];
	}
}

- (NSColor*) addressColor {
	NSString* storedAddress = [ self stringValueForKey: _ADDRESS_KEY_ ];
	NSString* resolvedAddress = [ _resolver hostNameToAddress: [ self name ]];
	
	if( [ storedAddress length ] == 0 ) {
		return [ NSColor grayColor ];
	}
	if( [ resolvedAddress length ] == 0 ) {
		return [ NSColor blackColor ];
	}	
	if( [ storedAddress length ] != 0 && ! [ storedAddress isEqual: resolvedAddress ] ) {
		return [ NSColor redColor ];
	}		
	if( [ storedAddress length ] != 0 && [ storedAddress isEqual: resolvedAddress ] ) {
		return [ NSColor orangeColor ];
	}		
	
	return [ NSColor blackColor ];
}

//- (NSString*) addressIPv6 {	
//	return [ self stringValueForKey: _ADDRESS_IPV6_KEY_ ];
//}
//
//- (void) setAddressIPv6: (NSString*) anAddress {
//	[ self setStringValue: anAddress forKey: _ADDRESS_IPV6_KEY_ ];
//}
//
- (NSArray*) resources {
	return [ self childrenKindOfClass: [ AlmostVPNResource class ]];
}

- (BOOL) canHaveChild: (NSString*) childKind {
	return	[ @"Service" isEqual: childKind ] || 
			[ @"Drive" isEqual: childKind ] || 
			[ @"Bonjour" isEqual: childKind ] ||
			[ @"RemoteControl" isEqual: childKind ] ||
			[ @"Printer" isEqual: childKind ]
	;
}

@end
