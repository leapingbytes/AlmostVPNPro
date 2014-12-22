//
//  BonjourManager.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 6/14/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "BonjourManager.h"
#import "PathLocator.h"
#import "AlmostVPNModel.h"

@interface BonjourManager (Private) 
- (NSDictionary*) lookupDefinitionForKey: (NSString*) key withValue: (NSString*) value;
- (NSDictionary*) typeDefinition: (NSString*) type;
- (NSString*) titleForType: (NSString*) v;
- (NSString*) typeForTitle: (NSString*) v;
- (void) setupCustomPropertiesFor: (AlmostVPNBonjour*) o;
- (void) discoverServiceFor: (AlmostVPNBonjour*)o;
@end 

@implementation BonjourManager (Private)
- (NSDictionary*) lookupDefinitionForKey: (NSString*) key withValue: (NSString*) value {
	for( int i = 0; i < [ _types count ]; i++ ) {
		NSDictionary* typeDef = [ _types objectAtIndex: i ];
		if( [ value isEqual: [ typeDef objectForKey: key ]] ) {
			return typeDef;
		}
	}
	return nil;
}

- (NSDictionary*) typeDefinition: (NSString*) type {
	return [ self lookupDefinitionForKey: @"type" withValue: type ];
}

- (NSString*) titleForType: (NSString*) v {
	NSDictionary* typeDef = [ self lookupDefinitionForKey: @"type" withValue: v ];
	return [ typeDef objectForKey: @"title" ];
}

- (NSString*) typeForTitle: (NSString*) v {
	NSDictionary* typeDef = [ self lookupDefinitionForKey: @"title" withValue: v ];
	return [ typeDef objectForKey: @"type" ];
}

- (void) flushAllPropertiesFor: (AlmostVPNBonjour*) o {
	[ o setProperties: [ NSMutableDictionary dictionary ]];
	[ o setCustomProperties: [ NSMutableArray array ]];
	[ o setPort: @"" ];
}

- (void) setupCustomPropertiesFor: (AlmostVPNBonjour*) o {
	NSDictionary* typeDef = [ self lookupDefinitionForKey: @"type" withValue: [ o type ]];
	
	if( typeDef == nil ) {
		return;
	}

	NSDictionary* propertiesDef = [ typeDef objectForKey: @"properties" ];
	propertiesDef = propertiesDef == nil ? [ NSDictionary dictionary ] : propertiesDef; 
	
	NSMutableDictionary* allProperties = [ o properties ];
	NSMutableArray* customProperties = [ o customProperties ];
	
	allProperties = allProperties != nil ? allProperties : [ NSMutableDictionary dictionary ];
	customProperties = customProperties != nil ? customProperties : [ NSMutableArray array ];
	
	NSEnumerator* keys = [ propertiesDef keyEnumerator ];
	id key;
	while(( key = [ keys nextObject ]) != nil ) {
		id value = [ propertiesDef objectForKey: key ];
		
		if( [ value rangeOfString: @"${" ].location != 0 ) {
			// This is "not custom" property
			[ allProperties setObject: value forKey: key ];
		} else {
			if( [ allProperties objectForKey: key ] == nil ) {
				[ allProperties setObject: @"" forKey: key ];
			}
			NSMutableDictionary* customPropertyDef = [ NSMutableDictionary dictionary ];
			[ customProperties addObject: customPropertyDef ];
			value = [ value substringFromIndex: 2 ]; // get  rid of "${"
			if( [ value rangeOfString: @"?" ].location == 0 ) {
				value = [ value substringFromIndex: 1 ]; // get rid of "?"
				value = [ value substringToIndex: [ value length ] - 1 ]; // get rid of "}"
				NSString* prompt;
				NSString* defaultValue = @"";
				if( [ value rangeOfString: @"=" ].location != NSNotFound ) {
					NSArray* parts = [ value componentsSeparatedByString: @"=" ];
					prompt = [ parts objectAtIndex: 0 ];
					defaultValue = [ allProperties objectForKey: key ];
					defaultValue = [ defaultValue length ] == 0 ? [ parts objectAtIndex: 1 ] : defaultValue;
				} else {
					prompt = value;
					defaultValue = [ allProperties objectForKey: key ];
				}
				[ customPropertyDef setObject: key forKey: @"key" ];
				[ customPropertyDef setObject: [ NSString stringWithFormat: @"%@:", prompt ] forKey: @"label" ];	
				[ customPropertyDef setObject: defaultValue forKey: @"value" ];		
				@try {
					[ allProperties unbind: key ];
					[ customPropertyDef unbind: @"value" ];
				} @catch( NSException* e ) {
					// do nothing
				}
				[ allProperties bind: key toObject: customPropertyDef withKeyPath: @"value" options: nil ];		
				[ customPropertyDef bind: @"value" toObject: allProperties withKeyPath: key options: nil ];
			} else {
				NSLog( @"ERROR : Variables have not been implemented yet" );
			}
		}
	}
	[ o setProperties: allProperties ];
	[ o setCustomProperties: customProperties ];	
	
	if ( [[ o port ] length ] == 0 ) {
		[ o setName: [ typeDef objectForKey: @"defaultName" ]];
		[ o setPort: [ typeDef objectForKey: @"port" ]];
	}	
} 


- (void) discoverServiceFor: (AlmostVPNBonjour*)o {
	NSNetServiceBrowser *serviceBrowser;
 
	serviceBrowser = [[NSNetServiceBrowser alloc] init];
	[ _hotBonjourObjects addObject: o ];
	[serviceBrowser setDelegate: self ];
	[serviceBrowser searchForServicesOfType: [ o type ] inDomain:@""];
}

#pragma mark NSNetServiceBrowser delegate 
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
	[ netService setDelegate: self ];
	[ netService resolveWithTimeout: 5.0 ];
	[ netService retain ];
//	[ self netServiceDidResolveAddress: netService ];
}

#pragma mark NSNetService delegate 
- (void)netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict {
	NSLog( @"Fail to resolve : %@\n", netService );
//	[ netService release ];
}

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
	for( int i = 0; i < [ _hotBonjourObjects count ]; i++ ) {
		AlmostVPNBonjour* o = [ _hotBonjourObjects objectAtIndex: i ];

		NSString* targetHostName = [[ o parent ] name ];
		NSString* serviceHostName = [ netService hostName ];
				
		if( 
			[ targetHostName isEqual: serviceHostName ] || 
			[[ NSString stringWithFormat: @"%@.local.", targetHostName ] isEqual: serviceHostName ]
		) {
			NSArray* addresses = [ netService addresses ];
			NSData* address0 = [ addresses objectAtIndex: 0 ];
			const struct sockaddr_in* addr = [ address0 bytes ];
			NSDictionary* txtRecord = [ NSNetService dictionaryFromTXTRecordData: [ netService TXTRecordData ]];
			
			NSString* port = [ NSString stringWithFormat: @"%d", ntohs( addr->sin_port )];
			
			[ o setName: [ netService name ]];
			[ o setPort: port ];
			
			NSMutableDictionary* properties = [ o properties ];
			NSEnumerator* keys = [ txtRecord keyEnumerator ];
			NSString* key;
			while(( key = [ keys nextObject ] ) != nil ) {
				NSData* realValueData = [ txtRecord objectForKey: key ];
				NSString* realValue = [[ NSString alloc ] initWithBytes: [ realValueData bytes ] length: [ realValueData length ] encoding: NSUTF8StringEncoding ];
				if( realValue != nil ) {
					[ properties setObject: realValue forKey: key ];
				}
			}
			
			[ o setProperties: properties ];
			[ o setCustomProperties: [ o customProperties ]];	

			[ _hotBonjourObjects removeObject: o ];
			break;
		}
	}	
//	[ netService release ];
}
@end

@implementation BonjourManager 
- (id) init {
	self = [ super init ];
	
	_types = [ NSArray arrayWithContentsOfFile: [ PathLocator pathForResource: @"BonjourDefinitions.plist" ]];
	NSArray* customDefs = [ NSArray arrayWithContentsOfFile: 
		[ NSString 
			stringWithFormat: @"%@/com.leapingbytes.AlmostVPNPRO.BonjourDefinitions.plist", 
			[[ PathLocator preferencesPath ] stringByDeletingLastPathComponent ]
		]
	];
	if( customDefs != nil ) {
		_types = [ _types mutableCopy ];
		[ (NSMutableArray*)_types addObjectsFromArray: customDefs ];
	}
	_hotBonjourObjects = [[ NSMutableArray alloc ] init ];
	
	return self;
}

- (NSArray*) types {	
	return _types;
}

#pragma mark <AlmostVPNObjectDelegate>
- (void) objectWasInitWithDictionary: (AlmostVPNObject*) o {
	// Forget customProperties. They will be re-created 
	[ (AlmostVPNBonjour*)o setCustomProperties: [ NSMutableArray array ]];
	[ self setupCustomPropertiesFor: (AlmostVPNBonjour*)o ];
}

- (id) property: (NSString*) n ofObject: (id) o {
	if( [ @"title" isEqual: n ] ) {
		return [ self titleForType: [ (AlmostVPNBonjour*)o type ]];
	} else if( [ @"customProperties" isEqual: n ] ) {
		[ self setupCustomPropertiesFor: o ];
		return [ o customProperties ];
	} else {
		return IGNORE_DELEGATE;
	}
}

- (id) setValue: (id) v forProperty: (NSString*) n ofObject: (id) o {
	if( [ @"parent-uuid" isEqual: n ] ) {
		[ self discoverServiceFor: o ];
		return IGNORE_DELEGATE;
	} else 	if( [ @"title" isEqual: n ] ) {
		NSString* oldType = [ o type ];
		[ (AlmostVPNBonjour*)o setType: [ self typeForTitle: v ]];
		if( ! [ oldType isEqual: [ o type ]] ) {
			[ self flushAllPropertiesFor: o ];
			[ self setupCustomPropertiesFor: o ];
			[ self discoverServiceFor: o ];
		}
		return nil;
	} else if( [ @"type" isEqual: n ] ) {
		NSString* oldType = [ o type ];
		[ (AlmostVPNBonjour*)o setType: v ];
		if( ! [ oldType isEqual: [ o type ]] ) {
			[ self flushAllPropertiesFor: o ];
			[ self setupCustomPropertiesFor: o ];
			[ self discoverServiceFor: o ];
		}
		return nil;
	}
	return IGNORE_DELEGATE;
}
@end
