//
//  AlmostVPNConfiguration.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/12/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNConfiguration.h"
#import "AlmostVPNProfile.h"
#import "AlmostVPNLocalhost.h"

#import "LBServer.h"
#import "LBService.h"

#define _CONFIGURATION_KEY_		@"configuration"

#define _VERSION_KEY_			@"version"
#define _USER_NAME_KEY_			@"user-name"
#define _USER_HOME_KEY_			@"user-home"
#define _APP_SUPPORT_PATH_KEY_	@"application-support-path"
#define _RESOURCES_PATH_KEY_	@"resources-path"
#define _PREFERENCES_PATH_KEY_	@"preferences-path"
#define _KEYCHAIN_PATH_KEY_		@"keychain-path"
#define _SECURE_STORE_PATH_KEY_	@"secure-store"

#define _FULL_NAME_KEY_			@"full-name"
#define _EMAIL_KEY_				@"email"

#define _RUN_DYNAMIC_PROXY_		@"run-dynamic-proxy"
#define _DYNAMIC_PROXY_PORT_	@"dynamic-proxy-port"
#define _SHARE_DYNAMIC_PROXY_	@"share-dynamic-proxy"
#define _CONTROL_SYSTEM_SETTINGS_ @"control-system-settings"


#define _LOG_INITIALLY_FROZEN_	@"log-initially-frozen"
#define _MAX_LOG_SIZE_			@"max-log-size"
#define _TRAFFIC_INITIALLY_FROZEN_	@"traffic-initially-frozen"

static NSString*	_keys_[] = {
	_CONFIGURATION_KEY_,
//	_USER_NAME_KEY_,
//	_USER_HOME_KEY_,
//	_APP_SUPPORT_PATH_KEY_,
//	_RESOURCES_PATH_KEY_,
//	_PREFERENCES_PATH_KEY_,
//	_KEYCHAIN_PATH_KEY_,
//	_SECURE_STORE_PATH_KEY_,
//	_FULL_NAME_KEY_,
//	_EMAIL_KEY_,
//	_RUN_DYNAMIC_PROXY_,
//	_DYNAMIC_PROXY_PORT_,
//	_SHARE_DYNAMIC_PROXY_,
	nil
};

static AlmostVPNConfiguration* _sharedInstance = nil;

@implementation AlmostVPNConfiguration
#pragma mark Singleton support
+ (AlmostVPNConfiguration*) sharedInstance {
	@synchronized( self ) {
		if( _sharedInstance == nil ) {
			_sharedInstance = [[ AlmostVPNConfiguration alloc ] init ];
		}
	}
	return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
        }
    }
    return _sharedInstance;
}
 
- (id)retain {
    return self;
}
 
- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
 
- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark initialize

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self initKeys: _keys_ fromDictionary: aDictionary ];

	[ AlmostVPNConfiguration performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];
	return self;
}

- (void) bootstrap {
	AlmostVPNLocalhost* localhost = [ AlmostVPNLocalhost sharedInstance ];
	[ self addChild: localhost ];
	[ localhost bootstrap ];
}

#pragma mark IO

- (void) loadFromFile: (NSString*) filePath {
	NSDictionary* asDictionary = [ NSDictionary dictionaryWithContentsOfFile: filePath ];
	[ AlmostVPNObject reInitialize ];
	[ self removeAllObjects ];
	[ self initWithDictionary: asDictionary ];
	// 
	// Load known-servers/known-services
	//
	NSArray* anArray = [ asDictionary objectForKey: @"known-servers" ];
	[ LBServer rememberFromPreferences: anArray ];
	anArray = [ asDictionary objectForKey: @"known-services" ];
	[ LBService rememberFromPreferences: anArray ];	
}

- (void) saveToFile: (NSString*) filePath {
	@synchronized ( self ) {
		id ssp = [ AlmostVPNObject secureStorageProvider ];
		[ AlmostVPNObject setSecureStorageProvider: nil ];
		
		NSMutableArray* anArray = [ NSMutableArray array ];
		[ LBServer serversToPreferences: anArray ];
		[ _embeddedDictionary setObject: anArray forKey: @"known-servers" ];
		anArray = [ NSMutableArray array ];
		[ LBService servicesToPreferences: anArray ];
		[ _embeddedDictionary setObject: anArray forKey: @"known-services" ];
		
		[ _embeddedDictionary writeToFile: filePath atomically: YES ];
		[ AlmostVPNObject setSecureStorageProvider: ssp ];
	}
}

#pragma mark Top Level Objects

- (int) countProfiles {
	return [[ self profiles ] count ];
}

 - (NSArray*) profiles {
	return [ self childrenKindOfClass: [ AlmostVPNProfile class ]];
 }

- (int) countLocations {
	return [[ self locations ] count ];
}

- (NSArray*) locations {
	//
	// Need to use "childrenMemberOfClas" instead of "childrenKindOfClass" 
	// to filter out localhost which is "AlmostVPNLocalHost : AlmostVPNLocation"
	//
	return [ self childrenMemberOfClass: [ AlmostVPNLocation class ]];
}

- (AlmostVPNLocalhost*) localHost {
	NSArray* localHostArray = [ self childrenKindOfClass: [ AlmostVPNLocalhost class ]];
	switch( [ localHostArray count ] ) {
		case 0 : return nil;
		case 1 : return [ localHostArray objectAtIndex: 0 ];
		default :
			NSLog( @"ERROR : -[AlmostVPNConfiguration localHost] : more then one localhost object\n" );
			return [ localHostArray objectAtIndex: 0 ];
	}
}

#pragma mark configuration

- (NSMutableDictionary*) configuration {
	NSMutableDictionary* result = [ self objectValueForKey: _CONFIGURATION_KEY_ ];
	if( result == nil ) {
		result = [[ NSMutableDictionary alloc ] init ];
		[ self setObject: result forKey: _CONFIGURATION_KEY_ ];
	}
	return result;
}

- (void) setConfiguration: (NSMutableDictionary*) v {
}

- (id) configPropertyValue: (NSString*) name {
	NSDictionary* config = [ self configuration ];
	NSString* result = [ config objectForKey: name ];
	if( result == nil ) {
		NSString* result = [ self stringValueForKey: name ];
		if( result != nil ) {
			[ (NSMutableDictionary*)config setObject: result forKey: name ];
			[ self removeObjectForKey: name ];
		}
	}
	return result;
}

- (void) setValue: (id) v forConfigProperty: (NSString*) name {
	NSMutableDictionary* config = (NSMutableDictionary*)[ self configuration ];
	[ config setObject: v forKey: name ];
}

- (NSString*) version{
	return [ self configPropertyValue: _VERSION_KEY_ ];
}
- (void) setVersion: (NSString*) v {
	[ self setValue: v forConfigProperty: _VERSION_KEY_ ];
}

- (NSString*) userName {
	return [ self configPropertyValue: _USER_NAME_KEY_ ];
}
- (void) setUserName: (NSString*) v {
	[ self setValue: v forConfigProperty: _USER_NAME_KEY_ ];
}

- (NSString*) userHome {
	return [ self configPropertyValue: _USER_HOME_KEY_ ];
}
- (void) setUserHome: (NSString*) v {
	[ self setValue: v forConfigProperty: _USER_HOME_KEY_ ];
}

- (NSString*) applicationSupportPath {
	return [[ self configPropertyValue: _APP_SUPPORT_PATH_KEY_ ] stringByAbbreviatingWithTildeInPath ];
}
- (void) setApplicationSupportPath: (NSString*) v {
	[ self setValue: [ v stringByExpandingTildeInPath ] forConfigProperty: _APP_SUPPORT_PATH_KEY_ ];
}

- (NSString*) resourcesPath {
	return [[ self configPropertyValue: _RESOURCES_PATH_KEY_ ] stringByAbbreviatingWithTildeInPath ];
}
- (void) setResourcesPath: (NSString*) v {
	[ self setValue: [ v stringByExpandingTildeInPath ] forConfigProperty: _RESOURCES_PATH_KEY_ ];
}

- (NSString*) preferencesPath {
	return [[ self configPropertyValue: _PREFERENCES_PATH_KEY_ ] stringByAbbreviatingWithTildeInPath ];
}
- (void) setPreferencesPath: (NSString*) v {
	[ self setValue: [ v stringByExpandingTildeInPath ] forConfigProperty: _PREFERENCES_PATH_KEY_ ];
}

- (NSString*) keychainPath {
	return [[ self configPropertyValue: _KEYCHAIN_PATH_KEY_ ] stringByAbbreviatingWithTildeInPath ];
}
- (void) setKeychainPath: (NSString*) v {
	[ self setValue: [ v stringByExpandingTildeInPath ] forConfigProperty: _KEYCHAIN_PATH_KEY_ ];
}

- (NSString*) secureStorePath {
	return [[ self configPropertyValue: _SECURE_STORE_PATH_KEY_ ] stringByAbbreviatingWithTildeInPath ];
}
- (void) setSecureStorePath: (NSString*) v {
	[ self setValue: [ v stringByExpandingTildeInPath ] forConfigProperty: _SECURE_STORE_PATH_KEY_ ];
}


- (NSString*) fullName {
	return [ self configPropertyValue: _FULL_NAME_KEY_ ];
}
- (void) setFullName: (NSString*) v {
	[ self setValue: v forConfigProperty: _FULL_NAME_KEY_ ];
}

- (NSString*) email {
	return [ self configPropertyValue: _EMAIL_KEY_ ];
}
- (void) setEmail: (NSString*) v {
	[ self setValue: v forConfigProperty: _EMAIL_KEY_ ];
}

- (id) runDynamicProxy {
	NSString* result = [ self configPropertyValue: _RUN_DYNAMIC_PROXY_ ]; 
	return [ NSNumber numberWithBool: [ result isEqual: @"yes" ]];
}

- (void) setRunDynamicProxy: (id) v {
	[ self setValue: ( [ v boolValue ] ? @"yes" : @"no" ) forConfigProperty: _RUN_DYNAMIC_PROXY_ ];
}

- (id) shareDynamicProxy {
	NSString* result = [ self configPropertyValue: _SHARE_DYNAMIC_PROXY_ ]; 
	return [ NSNumber numberWithBool: [ result isEqual: @"yes" ]];
}

- (void) setShareDynamicProxy: (id) v {
	[ self setValue: ( [ v boolValue ] ? @"yes" : @"no" ) forConfigProperty: _SHARE_DYNAMIC_PROXY_ ];
}

- (id) dynamicProxyPort {
	NSString* result = [ self configPropertyValue: _DYNAMIC_PROXY_PORT_ ]; 
	if( result == nil ) {
		result = @"1080";
		[ self setDynamicProxyPort: result ];
	}
	return result;
}

- (void) setDynamicProxyPort: (id) v {
	[ self setValue: v forConfigProperty: _DYNAMIC_PROXY_PORT_ ];
}


- (id) controlSystemSettings {
	NSString* result = [ self configPropertyValue: _CONTROL_SYSTEM_SETTINGS_ ]; 
	return [ NSNumber numberWithBool: [ result isEqual: @"yes" ]];
}

- (void) setControlSystemSettings: (id) v {
	[ self setValue: ( [ v boolValue ] ? @"yes" : @"no" ) forConfigProperty: _CONTROL_SYSTEM_SETTINGS_ ];
}




- (id) logInitiallyFrozen {
	NSString* result = [ self configPropertyValue: _LOG_INITIALLY_FROZEN_ ]; 
	return [ NSNumber numberWithBool: [ result isEqual: @"yes" ]];
}

- (void) setLogInitiallyFrozen: (id) v {
	[ self setValue: ( [ v boolValue ] ? @"yes" : @"no" ) forConfigProperty: _LOG_INITIALLY_FROZEN_ ];
}

- (id) maxLogSize {
	NSString* result = [ self configPropertyValue: _MAX_LOG_SIZE_ ]; 
	if( result == nil ) {
		result = @"1024";
		[ self setMaxLogSize: result ];
	}
	return result;
}

- (void) setMaxLogSize: (id) v {
	[ self setValue: v forConfigProperty: _MAX_LOG_SIZE_ ];
}

- (id) trafficInitiallyFrozen {
	NSString* result = [ self configPropertyValue: _TRAFFIC_INITIALLY_FROZEN_ ]; 
	return [ NSNumber numberWithBool: [ result isEqual: @"yes" ]];
}

- (void) setTrafficInitiallyFrozen: (id) v {
	[ self setValue: ( [ v boolValue ] ? @"yes" : @"no" ) forConfigProperty: _TRAFFIC_INITIALLY_FROZEN_ ];
}

@end
