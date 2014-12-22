//
//  LBService.m
//  AlmostVPN
//
//  Created by andrei tchijov on 8/24/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <netdb.h>

#import "LBService.h"
#import "LBToolbox/LBToolbox.h"

@implementation LBService
static NSMutableArray*					_knownServices;

+(void)initialize {
	_knownServices = [[ NSMutableArray alloc ] init ];
	
	[ LBService serviceWithName: @"http" andNumber: 80 ];
	[ LBService serviceWithName: @"https" andNumber: 443 ];
	
	[ LBService serviceWithName: @"imap" andNumber: 143 ];
	[ LBService serviceWithName: @"imaps" andNumber: 993 ];
	[ LBService serviceWithName: @"pop3" andNumber: 110 ];
	[ LBService serviceWithName: @"pop3s" andNumber: 995 ];
	[ LBService serviceWithName: @"smtp" andNumber: 25 ];
	
	[ LBService serviceWithName: @"vnc" andNumber: 5900 ];
	[ LBService serviceWithName: @"ard" andNumber: 3238 ];		
	
	[ LBService serviceWithName: @"afp" andNumber: 548 ];		
	[ LBService serviceWithName: @"smb" andNumber: 139 ];	
		
	[ LBService serviceWithName: @"jabber/gtalk" andNumber: 5222 ];		
	[ LBService serviceWithName: @"AOL IM" andNumber: 5190 ];		
	[ LBService serviceWithName: @"Yahoo IM" andNumber: 5050 ];		

	[ LBService serviceWithName: @"mySQL" andNumber: 3306 ];		
	[ LBService serviceWithName: @"postgresql" andNumber: 5432 ];		
	[ LBService serviceWithName: @"MS SQL" andNumber: 1433 ];		

}

+ (void)rememberFromPreferences: (NSArray*) preferences {
	for( int i = 0; i < [ preferences count ]; i++ ) {
		id serviceObject = [ preferences objectAtIndex: i ];
		[ LBService rememberService: [ serviceObject objectForKey: @"name" ] withNumber: [[ serviceObject objectForKey: @"number" ] intValue ]];
	}
}

+ (void)servicesToPreferences: (NSMutableArray*) preferences {
	for( int i = 0; i < [ _knownServices count ]; i++ ) {
		id service = [ _knownServices objectAtIndex: i ];
		[ preferences addObject: [ NSDictionary dictionaryWithObjectsAndKeys: 
			[ service name ], @"name",
			[ NSString stringWithFormat: @"%d", [ service number ]], @"number",
			nil
		]];
	}
}

+ (NSMutableArray*) knownServices {
		return _knownServices;
}

+ (void) setKnownServices: (NSMutableArray*) anArray {
	anArray = [ anArray copy ];
	[ _knownServices release ];
	_knownServices = anArray;
}

+ (void) rememberService: (NSString*) name withNumber: (int) number {
	if( [ name length ] == 0 && number <= 0 ) {
		return;
	}
	LBService* newService = [ LBService serviceWithName: name andNumber: number ];
	[ LBService rememberService: newService ];
	[ newService release ];	
}

+(void) rememberService: (LBService*) service {
	if( ! [ _knownServices containsObject: service ] ) {
		[ _knownServices addObject: service ];
	}
}

+(int) nameToNumber: (NSString*) name {
	if( [ name intValue ] > 0 ) {
		return [ name intValue ];
	}
	int result = [ self knownNameToNumber: name ];
	if( result <= 0 ) {		
		result = [ LBService getservbyname: name ];
	}
	return result;
}

+(int) knownNameToNumber: (NSString*) name {
	for( int i = 0; i < [ _knownServices count ]; i++ ) {
		if( [[[ _knownServices objectAtIndex: i ] name ] isEqual: name ] ) {
			return [[ _knownServices objectAtIndex: i ] number ];
		}
	}
	return -1;
}

+(int) getservbyname: (NSString*) name {
	struct servent * serviceEntryPtr = getservbyname( [ name UTF8String ], "tcp" );		
	return serviceEntryPtr == nil ? -1 : serviceEntryPtr->s_port;
}

+(NSString*) numberToName: (int) number {
	NSString* result = [ self knownNumberToName: number ];
	if( result == nil ) {			
		result = [ self getservbyport: number ];
		if( result <= 0 ) {
			result = [ NSString stringWithFormat: @"%d", number ];
		}
	}	
	return result;
}

+(NSString*) knownNumberToName: (int) number {
	for( int i = 0; i < [ _knownServices count ]; i++ ) {
		if( [[ _knownServices objectAtIndex: i ] number ] == number ) {
			return [[ _knownServices objectAtIndex: i ] name ];
		}
	}
	return nil;
}

+(NSString*) getservbyport:(int) number {
	struct servent * serviceEntryPtr = getservbyport( number, "tcp" );		
	return serviceEntryPtr == nil ? nil : [ NSString stringWithCString: serviceEntryPtr->s_name ];		
}

+(id)serviceWithName: (NSString*) name {
	return [ LBService serviceWithName: name andNumber: 0 ];
}


+(id)serviceWithNumber: (int) number {
	return [ LBService serviceWithName: nil andNumber: number ];
}

/*
 Possible cases:
 1) name = "80" number  = 80
 2) name = "http" number = 80
 3) name = "http" number = 0
 4) name = nil number = 80
 */
+(id)serviceWithName: (NSString*) theName andNumber: (int) theNumber {
	LBService* newService = [[ LBService alloc ] init ];
	
	if( theName == nil ) {
		theName = [ LBService numberToName: theNumber ];
	} else if( theNumber <= 0 ) {
		theNumber = [ LBService nameToNumber: theName ];
	}
	[ newService setName: theName ];
	[ newService setNumber: theNumber ];
	
	[ LBService rememberService: newService ];
	
	return newService;
}

-(id) init {
	[ super init ];
	number = -1;
	return self;
}

-(id) copyWithZone: (NSZone*) zone {
	zone = zone == nil ? NSDefaultMallocZone() : zone;
	
	LBService* copy = [[ LBService allocWithZone: zone ] init ];
	
	copy->name = [ name copyWithZone: zone ];
	copy->number = number;
	
	return copy;
}

- (NSString*) description {
	return name;
}


-(NSString*) stringValue {
	return name;
}
-(int) intValue {
	return number;
}

- (NSString*) name {
	return name;
}

- (void) setValue: (NSString*) value {
	if( [ value intValue ] != 0 ) {
		[ self setNumber: [ value intValue ]];
	} else {
		[ self setName: value ];
	}
}

- (void) setName: (NSString*) value {
	if( name != value ) {
		[ name release ];
		name = [ value length ] == 0 ? nil : [ value copy ];
	}
}

- (int) number {
	return number;
}
- (void) setNumber: (int) value {
	number = value;
}

- (BOOL) isEqual: (id) other {
	return ( other != nil ) && [ other isKindOfClass: [ LBService class ]] && ( number == [ other number ]);
}

- (void) dealloc {
	[ name release ];
	[ super dealloc ];
}

@end
