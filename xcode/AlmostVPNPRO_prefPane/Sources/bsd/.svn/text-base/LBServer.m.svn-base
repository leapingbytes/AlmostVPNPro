//
//  LBServer.m
//  AlmostVPN
//
//  Created by andrei tchijov on 8/24/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//
#import <netdb.h>

#import "LBServer.h"
#import "LBToolbox/LBToolbox.h"

@implementation LBServer

static NSMutableArray*					_knownServers;

+ (void) initialize {
	_knownServers = [[ NSMutableArray array ] retain ];
}

+ (NSMutableArray*) knownServers {
	return _knownServers;
}

+ (void) setKnownServers: (NSMutableArray*) anArray {
	anArray = [ anArray mutableCopy ];
	[ _knownServers release ];
	_knownServers = anArray;
}

+ (void)rememberFromPreferences: (NSArray*) preferences {
	for( int i = 0; i < [ preferences count ]; i++ ) {
		id serverObject = [ preferences objectAtIndex: i ];
		[ LBServer rememberServer: [ serverObject objectForKey: @"name" ] withAddress: [ serverObject objectForKey: @"address" ]];
	}
}

+ (void)serversToPreferences: (NSMutableArray*) preferences {
	for( int i = 0; i < [ _knownServers count ]; i++ ) {
		id server = [ _knownServers objectAtIndex: i ];
		[ preferences addObject: [ NSDictionary dictionaryWithObjectsAndKeys: 
			[ server name ], @"name",
			[ server address ], @"address",			
			nil
			]];
	}
}

+ (void) rememberServer: (NSString*) name withAddress: (NSString*) address {
	if( [ name length ] == 0 && [ address length ] == 0 ) {
		return;
	}
	LBServer* newServer = [address length] == 0 ? [ LBServer serverWithName: name ] : [ LBServer serverWithName: name andAddress: address ];
	[ LBServer rememberServer: newServer ];
	[ newServer release ];	
}

+ (LBServer*) findServer: (NSString*) name {
	for( int i = 0; i < [ _knownServers count ]; i++ ) {
		LBServer* server = [ _knownServers objectAtIndex: i ];
		if( [ name isEqual: [ server name ]] || [ name isEqual: [ server address ]] ) {
			return server;
		}
	}
	LBServer* result = [ LBServer serverWithName: name ];
	[ self rememberServer: result ];
	return result;
}

+(void) rememberServer: (LBServer*) server {
	if( ! [ _knownServers containsObject: server ] ) {
		[ _knownServers addObject: server ];		
	}
}


+(NSString*)nameToAddress: (NSString*)value {
	NSString* result = [ self knownNameToAddress: value ];
	if( result == nil ) {
		result = [ self gethostbyname: value ];
	}
	return result;
}

+(NSString*) knownNameToAddress: (NSString*) value {
	for( int i = 0; i < [ _knownServers count ]; i++ ) {
		if( [[[ _knownServers objectAtIndex: i ] name ] isEqual: value ] ) {
			return [[ _knownServers objectAtIndex: i ] address ];
		}
	}
	return nil;
	
}

+(NSString*) knownAddresstoName: (NSString*) value {
	for( int i = 0; i < [ _knownServers count ]; i++ ) {
		if( [[[ _knownServers objectAtIndex: i ] address ] isEqual: value ] ) {
			return [[ _knownServers objectAtIndex: i ] name ];
		}
	}
	return nil;
	
}

+(NSString*) gethostbyname: (NSString*) value {
	struct hostent * hostEntryRef = gethostbyname( [ value  UTF8String ] );
	if( hostEntryRef == nil ) {
		return nil;
	}
	int address = ntohl( *(int*)(hostEntryRef->h_addr_list[0]));
	
	int ip1 = ( address >> 0 ) & 0xff;
	int ip2 = ( address >> 8 ) & 0xff;
	int ip3 = ( address >> 16 ) & 0xff;
	int ip4 = ( address >> 24 ) & 0xff;
	
	return [ NSString stringWithFormat: @"%d.%d.%d.%d", ip4, ip3, ip2, ip1 ];
}

+(NSString*) getnamebyhost: (NSString*) value {
	struct hostent * hostEntryRef = gethostbyname( [ value  UTF8String ] );
	if( hostEntryRef == nil ) {
		return nil;
	} else {
		return [ NSString stringWithCString: hostEntryRef->h_name ];
	}
}

+(NSString*)addressToName: (NSString*)value {
	NSString* result = [ self knownAddresstoName: value ];
	if( result == nil ) {
		result = [ self getnamebyhost: value ];
	}
	if( result == nil ) {
		result = value;
	}	
	return result;
}
	
+(id)serverWithName: (NSString*) name {
	if( [ name isEqual: [ LBServer nameToAddress: name ]] ) {
		return [ LBServer serverWithName: nil andAddress: name ];
	} else {
		return [ LBServer serverWithName: name andAddress: nil ];		
	}
}

+(id)serverWithAddress: (NSString*) address {
	return [ LBServer serverWithName: nil andAddress: address ];	
}

+(id)serverWithName: (NSString*) name andAddress: (NSString*) address {
	LBServer* newServer = [[ LBServer alloc ] init ];

	name = name != nil ? name : [ LBServer addressToName: address ];
	name = name != nil ? name : address;
	
	address = address != nil ? address : [ LBServer nameToAddress: name ];
	address = address != nil ? address : name;
	
	[ newServer setName: name ];
	[ newServer setAddress: address ];
	
	[ LBServer rememberServer: newServer ];
	
	return newServer;
}

-(id) init {
	[ self setResolved: NO ];
	return self;
}

-(id) copyWithZone: (NSZone*) zone {
	zone = zone == nil ? NSDefaultMallocZone() : zone;
	
	LBServer* copy = [[ LBServer allocWithZone: zone ] init ];
	
	copy->name = [ name copyWithZone: zone ];
	copy->address = [ address copyWithZone: zone ];
	
	return copy;
}

- (NSString*) description {
	return name;
}

- (NSString*) stringValue {
	return [ self name ];
}

- (void) fixResolved {
	[ self setResolved: name != nil && address != nil && ( ! [ name isEqual: address ] )];
}

- (NSString *)name {
	return name;
}
- (void)setName:(NSString *)value {
	if( name != value ) {
		[ name release ];
		name = [ value length ] == 0 ? nil : [ value copy ];
		[ self fixResolved ];
	}
}

- (NSString *)address {
	return address;
}
- (void)setAddress:(NSString *)value {
	if( address != value ) {
		[ address release ];
		address = [ value length ] == 0 ? nil : [ value copy ];
		[ self fixResolved ];
	}
}

- (NSColor*) addressColor {
	NSString* storedAddress = address;
	NSString* resolvedAddress = [ LBServer gethostbyname: name ];
	
	if( [ storedAddress length ] == 0 ) {
		return [ NSColor grayColor ];
	}
	if( [ resolvedAddress length ] == 0 ) {
		return [ NSColor blackColor ];
	}
	
	if( [ storedAddress length ] != 0 && [ storedAddress isEqual: resolvedAddress ] ) {
		return [ NSColor redColor ];
	}		
	if( [ storedAddress length ] != 0 && [ storedAddress isEqual: resolvedAddress ] ) {
		return [ NSColor orangeColor ];
	}		
	
	return [ NSColor blackColor ];
}


- (BOOL)resolved {
	return resolved;
}
- (BOOL)isResolved {
	return [ self resolved ];
}
- (void)setResolved: (BOOL) value {
	resolved = value;
}

- (BOOL) isEqual: (id) other {
	if( [ other isKindOfClass: [ NSString class ]] ) {
		other = [ LBServer findServer: other ];
	}
	return ( other != nil ) && [ other isKindOfClass: [ LBServer class ]] && ( [ name isEqual: [ other name ]]);
}

- (void) dealloc {
	[ name release ];
	[ address release ];
	[ super dealloc ];
}


//- (NSColor*) nameColor {
//	if ( [ self address ] != nil || assigned ) {
//		return [ NSColor blackColor ];
//	} else {
//		return [ NSColor redColor ];
//	}
//}
//
//- (NSColor*) addressColor {
//	NSString* nameToAddress = [ LBServer gethostbyname: name ];
//	if( assigned ) {
//		if(( nameToAddress != nil ) && ( ! [ nameToAddress isEqual: address ] )) {
//			return [ NSColor orangeColor ];
//		} else {
//			return [ NSColor blackColor ];
//		}
//	}
//	if( nameToAddress == nil && address == nil ) {
//		return [ NSColor redColor ];
//	}
//	return [ NSColor grayColor ];
//}
//
@end
@implementation LBServerResolvedToColorTransformer
+ (Class)transformedValueClass { return [NSColor self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	if( [ value intValue ] == 0 ) {
		return [ NSColor redColor ];
	} else {
		return [ NSColor blackColor ];
	}
}
@end
