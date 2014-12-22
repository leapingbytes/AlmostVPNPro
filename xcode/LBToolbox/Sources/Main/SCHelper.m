//
//  SCHelper.m
//  TrafficWidgetPlugin
//
//  Created by andrei tchijov on 10/24/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "SCHelper.h"


@implementation SCHelper
SCDynamicStoreRef dynRef = nil;

+(SCDynamicStoreRef) getDynRef {
	if( dynRef == nil ) {
		dynRef=SCDynamicStoreCreate(kCFAllocatorSystemDefault, (CFStringRef)@"SCHelper", NULL, NULL);
	}
	return dynRef;
}

+(NSArray*) listKeys: (NSString*) pattern {
	SCDynamicStoreRef 	dynRef= [ self getDynRef ];
	NSArray* keys=(NSArray*)SCDynamicStoreCopyKeyList(dynRef,(CFStringRef) pattern );
	return keys;
}

+(NSDictionary*) objectForKey: (NSString*) key {
	SCDynamicStoreRef 	dynRef= [ self getDynRef ];
	NSDictionary* result = (NSDictionary*)SCDynamicStoreCopyValue(dynRef,(CFStringRef)key);
	return result;
}

+(BOOL) setObject: (NSDictionary*) anObject forKey: (NSString*) key {
	SCDynamicStoreRef 	dynRef= [ self getDynRef ];
	BOOL rc = SCDynamicStoreSetValue( dynRef, (CFStringRef)key, (CFPropertyListRef)anObject ) == TRUE;
	if( ! rc ) {
		NSLog( @"+[ SCHelper setObject:forKey: ] : Fail. \nanObject = %@\nkey=%@\n", anObject, key );
	}
	return rc;
}

////////////////////////////////////////

+ (NSString*)primaryInterface {
	NSDictionary* networkGlobalIP4 = [ self objectForKey: @"State:/Network/Global/IPv4" ];
	NSString* primaryInterfaceName = (NSString*)[ networkGlobalIP4 objectForKey: @"PrimaryInterface" ];
	return primaryInterfaceName;
}

+(NSString*)localAddress {	
	NSString* primaryInterfaceName = [ self primaryInterface ];
	NSString* primaryInterfaceKey = [ NSString stringWithFormat: @"State:/Network/Interface/%@/IPv4", primaryInterfaceName ];
	NSDictionary* primaryInterface = [ self objectForKey: primaryInterfaceKey ];
	NSArray* addresses = (NSArray*)[ primaryInterface objectForKey: @"Addresses" ];
	NSString* result = (NSString*)[ addresses objectAtIndex: 0 ];
	
	return result;
}

+(BOOL)isProxyEnabled: (NSString*) proxyName {
	NSDictionary* networkGlobalProxies = [ self objectForKey: @"State:/Network/Global/Proxies" ];
	NSObject* result = [ networkGlobalProxies objectForKey: [ NSString stringWithFormat: @"%@Enable", proxyName ]];
	return ( result != nil ) && ( [((NSNumber*)result) intValue ] != 0 );
}

+(void)setProxyEnabled: (NSString*) proxyName to: (BOOL) value {
	NSMutableDictionary* networkGlobalProxies = [[ self objectForKey: @"State:/Network/Global/Proxies" ] mutableCopy ];
	[ networkGlobalProxies setObject:  [ NSNumber numberWithInt: value ? 1 : 0 ] forKey: [ NSString stringWithFormat: @"%@Enable", proxyName ]];
	[ self setObject: networkGlobalProxies forKey: @"State:/Network/Global/Proxies" ];
}
@end
