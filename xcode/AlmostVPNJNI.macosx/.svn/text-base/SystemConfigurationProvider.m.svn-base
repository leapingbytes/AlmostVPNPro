/*
 *  SystemConfigurationProvider.c
 *  AlmostVPNJNI.macosx
 *
 *  Created by andrei tchijov on 8/7/06.
 *  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
 *
 */

#include <Cocoa/Cocoa.h>
#include <sys/cdefs.h>
#include <CoreFoundation/CoreFoundation.h>
#include <SystemConfiguration/SCDynamicStore.h>
#include <SystemConfiguration/SCDynamicStoreCopyDHCPInfo.h>

#include "com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider.h"
#include "Tools/SCHelper.h"

typedef signed char		BOOL; 
#define YES             (BOOL)1
#define NO              (BOOL)0


JNIEXPORT jstring JNICALL 
	Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_getConfigurationObject 
	(
  		JNIEnv* env, 
  		jobject this, 
		jstring jDomain, 
		jstring jObject
	)
{
	const char* domain = (*env)->GetStringUTFChars( env, jDomain, NULL );
	const char* object = (*env)->GetStringUTFChars( env, jObject, NULL );

	NSAutoreleasePool* pool = [[ NSAutoreleasePool alloc ] init ];
	
	NSString* key = [ NSString stringWithCString: domain ];
	NSDictionary* dictionary = [ SCHelper objectForKey: key ];
	
	NSString* value = nil;
	if( dictionary == nil ) {
		NSLog( @"scutil : No such object : %@\n", key );
	} else {
		NSString* valueKey = [ NSString stringWithCString: object length: strlen( object ) ];
		value = [[ dictionary objectForKey: valueKey ] description ];
		if( value == nil ) {
			NSLog( @"scutil : Fail to get %@.%@\n", key, valueKey );
		}
	}
	
	jstring result = value == nil ? nil : (*env)->NewStringUTF( env, [ value cStringUsingEncoding: NSUTF8StringEncoding ] );
	
	[ pool release ];

	(*env)->ReleaseStringUTFChars( env, jDomain, domain );
	(*env)->ReleaseStringUTFChars( env, jObject, object );
	
	return result;
}

JNIEXPORT void JNICALL 
	Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_setProxyEnabled 
	(
  		JNIEnv* env, 
  		jobject this, 
		jstring jProxyName,
		jboolean jOnOff
	)
{
	const char* proxyName = (*env)->GetStringUTFChars( env, jProxyName, NULL );
	NSAutoreleasePool* pool = [[ NSAutoreleasePool alloc ] init ];

	[ SCHelper setProxyEnabled: [ NSString stringWithCString: proxyName ] to: (BOOL)jOnOff ];

	[ pool release ];

	(*env)->ReleaseStringUTFChars( env, jProxyName, proxyName );
}

JNIEXPORT void JNICALL 
	Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_setProxyHost
	(
  		JNIEnv* env, 
  		jobject this, 
		jstring jProxyName,
		jstring jHostName
	)
{
	const char* proxyName = (*env)->GetStringUTFChars( env, jProxyName, NULL );
	const char* hostName = (*env)->GetStringUTFChars( env, jHostName, NULL );
	NSAutoreleasePool* pool = [[ NSAutoreleasePool alloc ] init ];

	NSMutableDictionary* networkGlobalProxies = [[ SCHelper objectForKey: @"State:/Network/Global/Proxies" ] mutableCopy ];
	[ networkGlobalProxies setObject:  [ NSString stringWithCString: hostName ] forKey: [ NSString stringWithFormat: @"%sProxy", proxyName ]];
	[ SCHelper setObject: networkGlobalProxies forKey: @"State:/Network/Global/Proxies" ];

	[ pool release ];

	(*env)->ReleaseStringUTFChars( env, jProxyName, proxyName );
	(*env)->ReleaseStringUTFChars( env, jHostName, hostName );
}

JNIEXPORT void JNICALL 
	Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_setProxyPort
	(
  		JNIEnv* env, 
  		jobject this, 
		jstring jProxyName,
		jint port
	)
{
	const char* proxyName = (*env)->GetStringUTFChars( env, jProxyName, NULL );
	NSAutoreleasePool* pool = [[ NSAutoreleasePool alloc ] init ];

	NSMutableDictionary* networkGlobalProxies = [[ SCHelper objectForKey: @"State:/Network/Global/Proxies" ] mutableCopy ];
	[ networkGlobalProxies setObject:  [ NSNumber numberWithInt: port ] forKey: [ NSString stringWithFormat: @"%sPort", proxyName ]];
	[ SCHelper setObject: networkGlobalProxies forKey: @"State:/Network/Global/Proxies" ];

	[ pool release ];

	(*env)->ReleaseStringUTFChars( env, jProxyName, proxyName );
}

JNIEXPORT jstring JNICALL 
	Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_getDHCPOption 
	(
  		JNIEnv* env, 
  		jobject this, 
		jint optionNumber
	)
{
	NSAutoreleasePool* pool = [[ NSAutoreleasePool alloc ] init ];

	CFDictionaryRef dhcp = SCDynamicStoreCopyDHCPInfo( nil, nil );
	
	jstring result; 
	if( dhcp == nil ) {
		result = nil;
	} else {
		CFDataRef valueData = DHCPInfoGetOptionData( dhcp, optionNumber );
		
		const char* valueBytes = [ (NSData*)valueData bytes ];
		const int valueLength =   [ (NSData*)valueData length ];
		
		char* value = malloc( valueLength + 1 );
		strncpy( value, valueBytes, valueLength );
		value[ valueLength ] = 0;
		
		result = value == nil ? nil : (*env)->NewStringUTF( env, value );
		
		free( value );
	}
	
	[ pool release ];

	return result;
}


