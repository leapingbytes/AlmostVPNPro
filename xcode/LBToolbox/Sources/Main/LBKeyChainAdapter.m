//
//  LBKeychainAdapter.m
//  AlmostVPN
//
//  Created by andrei tchijov on 9/1/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#include <unistd.h>

#import "LBKeychainAdapter.h"

@interface LBKeychainAdapter (Private) 
+ (NSString*) describeOSStatus: (OSStatus) status ;
+ (NSString*) getKeychainPasswordCreateIfNotFound: (BOOL) createIfNotFound;
+ (NSString*) getKeychainPassword;
@end

@implementation LBKeychainAdapter

NSString* _icon = nil;
NSString* _keychainPath = nil;
NSArray*  _trustedApplications = nil;

NSMutableDictionary*	_passwords = nil;

+ (NSString*) getSecretOfType: (SecProtocolType)type forUser: (NSString*) userName atServer: (NSString*) server {
	_passwords = _passwords == nil ? [[ NSMutableDictionary alloc ] init ] : _passwords;
	NSString* aKey = [[ NSString alloc ] initWithFormat: @"%d-%@-%@", type, userName, server ];
	
	NSString* secret = [ _passwords objectForKey: aKey ];
	
	[ aKey release ];
	
	
	return secret;
}

+(void) saveSecret: (NSString*) secret ofType: (SecProtocolType) type forUser:  (NSString*) userName atServer: (NSString*) server {
	if( secret != nil ) {
		_passwords = _passwords == nil ? [[ NSMutableDictionary alloc ] init ] : _passwords;
		NSString* aKey = [[ NSString alloc ] initWithFormat: @"%d-%@-%@", type, userName, server ];
		
		[ _passwords setObject: secret forKey: aKey ];
	}
}


+ (NSString*) getIcon {
	return _icon;
}

+(void) setIcon: (NSString*) aValue {
	_icon = [ aValue copy ];
}

+ (NSString*) getKeychainPath {
	return _keychainPath;
}

+ (void) setKeychainPath: (NSString*)aPath {
	if( aPath != nil ) {
		[ _keychainPath release ];
		_keychainPath = [[ aPath copy ] retain ];
	}
}

+ (NSArray*) getTrustedApplications {
	return _trustedApplications;
}

+ (void)setTrustedApplications: (NSArray*) trustedApplications {
	_trustedApplications = [ trustedApplications copy ];
}

+ (SecAccessRef) createAccessWithLabel: (NSString*)label {
	OSStatus err;
    SecAccessRef access=nil;
    SecTrustedApplicationRef myself, tool;
	
    err = SecTrustedApplicationCreateFromPath(NULL, &myself);
	
	if( err != noErr ) {
		NSRunAlertPanel( @"Internal Error", @"Fail to get 'myself' application\n%@", @"OK", nil, nil, [ self describeOSStatus: err ] );
		return nil;
	}
	
	NSMutableArray* trustedApplications = [ NSMutableArray array ];
	[ trustedApplications addObject: (id)myself ];

	for( int i = 0; i < [ _trustedApplications count ]; i++ ) {
		err = SecTrustedApplicationCreateFromPath([[ _trustedApplications objectAtIndex: i  ] UTF8String ], &tool);
		if( err != noErr ) {
			NSRunAlertPanel( @"Internal Error", @"Fail to get 'almostVPNTool' application\n%@", @"OK", nil, nil, [ self describeOSStatus: err ] );
			return nil;
		}

		[ trustedApplications addObject: (id)tool ];
	}
	
    err = SecAccessCreate((CFStringRef)label, 
						  (CFArrayRef)trustedApplications, &access);
						  						  
    if (err) return nil;
    
	return access;
}

+ (NSString*) getKeychainPassword {
	return [ self getKeychainPasswordCreateIfNotFound: NO ];
}

+ (NSString*) getKeychainPasswordCreateIfNotFound: (BOOL) createIfNotFound {
	SecKeychainRef loginKeychain = (SecKeychainRef)nil;
	SecKeychainStatus status = 0;
	OSStatus err = SecKeychainCopyDefault( &loginKeychain );
	if( err == 0 && ( loginKeychain != nil )) {
		err = SecKeychainGetStatus( loginKeychain, &status );
	}
	if( err || ( status == 0 )) {
		NSRunAlertPanel( @"Internal Error", @"Fail to get 'default' keychain\n%@", @"OK", nil, nil, [ self describeOSStatus: err ] );
		if( loginKeychain != nil ) {
			CFRelease( loginKeychain );
		}
		return nil;		
	}

	NSString* result = [ self retrivePasswordOfType: kSecProtocolTypeSSH forAccount: @"almostVPN" onServer: @"almostVPN" forPath: @"" fromKeychain: loginKeychain ];
	if( result == nil && createIfNotFound ) {
		char	password[ 65 ];
		int offset = ' ';
		int range = '~' - ' ';
		srandom( time( nil ) & (long) result );
		for( int i = 0; i < 64; i++ ) {
			password[ i ] = offset + random() % range;
		}
		password[ 64 ] = 0;
//		result = [ NSString stringWithCString: password length: 64 ];
		result = [ NSString stringWithCString: password encoding: NSUTF8StringEncoding ];
		[ self savePassword: result ofType: kSecProtocolTypeSSH forAccount: @"almostVPN" onServer: @"almostVPN" forPath: @"" intoKeychain: loginKeychain ];
	}
	
	CFRelease( loginKeychain );
		
	return result;	
}

+ (SecKeychainRef) getKeychain {
	SecKeychainRef result = (SecKeychainRef)nil;
	SecKeychainStatus status = 0;
	const char* aPath = [[ self getKeychainPath ] UTF8String ];
	OSStatus err = SecKeychainOpen( aPath, &result );
	if( err == 0 && ( result != nil )) {
		SecKeychainGetStatus( result, &status );
	}
	if( err || ( status == 0 )) {

	// Keychain AlmostVPN does not exist need to create new one
		NSString* keychainPassword = [ self getKeychainPasswordCreateIfNotFound: YES ];	
		const char* password = [ keychainPassword UTF8String ];
		int	passwordLength = strlen( password );

		SecAccessRef initialAccess = [ LBKeychainAdapter createAccessWithLabel: @"AlmostVPN" ];
		err = SecKeychainCreate ( aPath, passwordLength, password, NO, initialAccess, &result );
		if( initialAccess ) CFRelease( initialAccess );
		if( err ) {
			result = nil;
		} else {
			SecKeychainUnlock( result, passwordLength, password, YES );
		}
	} else {
		// Keychain exist. If it is "secure" keychain, then we should be able to get Keychain Password
		// otherwise use "almostVPN" as a password
		NSString* keychainPassword = [ self getKeychainPasswordCreateIfNotFound: NO ];	
		keychainPassword = ( keychainPassword == nil ) ? @"almostVPN" : keychainPassword;
		const char* password = [ keychainPassword UTF8String ];
		int	passwordLength = strlen( password );
		SecKeychainUnlock( result, passwordLength, password, YES );
	}
	if( result == nil ) {
		NSLog( @"+[KeyChainAdaoter getKeychain] : ERROR : Fail to get AlmostVPN.keychain\n" );
	}
	return result;
}
+ (void) savePassword: (NSString*) password 
			   ofType: (SecProtocolType) type 
		   forAccount: (NSString*) account 
			 onServer: (NSString*) serverName 
			  forPath: (NSString*)path {
	SecKeychainRef		keychain = [ LBKeychainAdapter getKeychain ];
    [ self savePassword: password ofType: type forAccount: account onServer: serverName forPath: path intoKeychain: keychain ];
	CFRelease( keychain );
}

+ (void) savePassword: (NSString*) password 
			   ofType: (SecProtocolType) type 
		   forAccount: (NSString*) account 
			 onServer: (NSString*) serverName 
			  forPath: (NSString*)path
		 intoKeychain: (SecKeychainRef)keychain  {
	SecKeychainItemRef	itemRef = nil;
	OSStatus status = SecKeychainFindInternetPassword(
		keychain,
		[ serverName length ], [serverName UTF8String ],
		0, nil,
		[ account length ], [account UTF8String ],
		[ path length ], [ path UTF8String ],
		0,
		type,
		kSecAuthenticationTypeDefault,
		0, nil,
		&itemRef
	);
	
	if( itemRef != nil ) {
		status = SecKeychainItemModifyAttributesAndData(
			itemRef,
			nil,
			[password length ], [password UTF8String ]
		);
	} else {
		SecAccessRef access = [ LBKeychainAdapter createAccessWithLabel: @"AlmostVPN" ];
		
		int port = 0;
		SecProtocolType protocol = type;
		SecAuthenticationType authType = kSecAuthenticationTypeDefault;
		NSString* label = [ NSString stringWithFormat: @"%@@%@", account, serverName ];
		SecKeychainAttribute attrs[] = {
		{ kSecLabelItemAttr,	[ label length ],			(void*)[ label UTF8String ]},
		{ kSecAccountItemAttr,	[ account length ],			(void*)[ account UTF8String ] },
		{ kSecServerItemAttr,	[ serverName length ],		(void*)[ serverName UTF8String ]},
		{ kSecPortItemAttr,		sizeof(int),				(int *)&port },
		{ kSecProtocolItemAttr,	sizeof(SecProtocolType), 	(SecProtocolType *)&protocol },
		{ kSecAuthenticationTypeItemAttr,
			sizeof( SecAuthenticationType ), (SecAuthenticationType*)&authType }
			// { kSecPathItemAttr,		1,							"/" }
		};
		SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };
		status = SecKeychainItemCreateFromContent(
			kSecInternetPasswordItemClass,
			&attributes,
			[ password length ], [ password UTF8String ],
			keychain, 
			access,
			&itemRef
		);
		if (access) CFRelease(access);
	}
	if (itemRef) CFRelease(itemRef);		
	
	[ self saveSecret: password ofType: type forUser:account atServer:serverName ];
}

+ (NSString*) retrivePasswordOfType: (SecProtocolType) type forAccount: (NSString*) account onServer: (NSString*) serverName forPath: (NSString*)path {
	SecKeychainRef		keychain = [ LBKeychainAdapter getKeychain ];
	NSString* result = [ self retrivePasswordOfType: type forAccount: account onServer: serverName forPath: path fromKeychain: keychain ];
	CFRelease( keychain );
	return result;
}

+ (NSString*) retrivePasswordOfType: (SecProtocolType) type 
		                 forAccount: (NSString*) account 
						   onServer: (NSString*) serverName 
						    forPath: (NSString*)path 
					   fromKeychain: (SecKeychainRef)keychain {
	UInt32 length;
	void* data;
	
	NSString* result = [ self getSecretOfType: type forUser: account atServer:serverName ];
	
	if( result == nil ) {	
		OSStatus status = SecKeychainFindInternetPassword(
			keychain,
			[ serverName length ], [ serverName UTF8String ],
			0, nil,
			[ account length ], [ account UTF8String ],
			[ path length ], [ path UTF8String ],
			0,
			type,
			kSecAuthenticationTypeDefault,
			&length, &data,
			nil
		);	

		if( status ) {
			if( status != errSecItemNotFound ) {
				NSLog( @"retrivePasswordOfType : Fail to locate password %@@%@/%@ - error %@\n", account, serverName, path, [ self describeOSStatus: status ]);
			}
		} else {
			result = [ NSString stringWithCString: data encoding: NSUTF8StringEncoding ];

			[ self saveSecret: result ofType:type forUser: account atServer:serverName ];
		}	
	}
	return result;
}

+ (NSString*) askForPasswordForAccount: (NSString*) account onServer: (NSString*) serverName forPath: (NSString*) path {
	[ NSApplication sharedApplication ];
	SInt32 error = 0;
	NSDictionary* passwordNotificationDictionary = [ NSDictionary dictionaryWithObjectsAndKeys:
		@"", kCFUserNotificationTextFieldTitlesKey,
		@"AlmostVPN", kCFUserNotificationAlertHeaderKey, 
		[ NSString stringWithFormat: @"Please enter password for\n%@@%@/%@", account, serverName, ( path == nil ? @"" : path )], 
			kCFUserNotificationAlertMessageKey,
		@"OK", kCFUserNotificationDefaultButtonTitleKey,
		@"Cancel", kCFUserNotificationAlternateButtonTitleKey,
		_icon == nil ? nil : [ NSURL fileURLWithPath: _icon ],
		kCFUserNotificationIconURLKey,
		nil
	];
	CFUserNotificationRef passwordNotification = 
		CFUserNotificationCreate( nil,0.0,kCFUserNotificationStopAlertLevel | CFUserNotificationSecureTextField(0), &error, (CFDictionaryRef)passwordNotificationDictionary );
	
	CFOptionFlags responseFlags;
	SInt32 rc = CFUserNotificationReceiveResponse( passwordNotification, 0.0, &responseFlags );
	if( rc != 0 || ( responseFlags &  kCFUserNotificationAlternateResponse )) {
		return nil;
	} else {
		NSDictionary* resultsDictionary = (NSDictionary*)CFUserNotificationGetResponseDictionary( passwordNotification );
		NSString* result = [[ resultsDictionary objectForKey: (NSString*)kCFUserNotificationTextFieldValuesKey ] objectAtIndex: 0 ];
		return result;
	}
}
+ (void) forgetPasswordOfType: (SecProtocolType) type forAccount: (NSString*) account onServer: (NSString*) serverName forPath: (NSString*)path {
	SecKeychainRef		keychain = [ LBKeychainAdapter getKeychain ];
	[ self forgetPasswordOfType: type forAccount: account onServer: serverName forPath: path fromKeychain: keychain ];
	CFRelease( keychain );
}

+ (void)forgetPasswordOfType:(SecProtocolType)type forAccount:(NSString*)account onServer:(NSString*)serverName forPath:(NSString*)path fromKeychain: (SecKeychainRef) keychain {
	SecKeychainItemRef	itemRef = nil;
	OSStatus status = SecKeychainFindInternetPassword(
		keychain,
		[serverName length ], [serverName UTF8String ],
		0, nil,
		[account length ], [account UTF8String ],
		[ path length ], [ path UTF8String ],
		0,
		type,
		kSecAuthenticationTypeDefault,
		nil, nil,
		&itemRef
	);

	if( ! status ) {
		SecKeychainItemDelete( itemRef );
		CFRelease( itemRef );
	}	
	CFRelease( keychain );
}


+ (void) saveSSHPassword: (NSString*)password forAccount: (NSString*) account onServer: (NSString*) serverName {
	[ LBKeychainAdapter savePassword: password ofType: kSecProtocolTypeSSH forAccount: account onServer: serverName forPath: nil ];
}

+ (NSString*) retriveSSHPasswordForAccount: (NSString*) account onServer: (NSString*) serverName {
	return [ LBKeychainAdapter retrivePasswordOfType: kSecProtocolTypeSSH forAccount: account onServer: serverName forPath: nil ];
}

+ (void) forgetSSHPasswordForAccount: (NSString*) account onServer: (NSString*) serverName {
	[ LBKeychainAdapter forgetPasswordOfType: kSecProtocolTypeSSH forAccount: account onServer: serverName forPath: nil ];
}


+ (NSString*) describeOSStatus: (OSStatus) status {
	NSError* error = [ NSError errorWithDomain: NSOSStatusErrorDomain code: status userInfo: nil ];
	return [ error localizedDescription ];
}

@end
