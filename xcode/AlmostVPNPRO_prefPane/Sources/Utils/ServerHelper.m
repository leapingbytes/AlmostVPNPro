//
//  ServerHelper.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 3/14/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//
#include <unistd.h>

#import <Foundation/NSException.h>
#import "ServerHelper.h"

#import "AlmostVPNModel.h"
#import "LBToolbox/LBToolbox.h"

#import "PathLocator.h"
#import "ServerMonitor.h"

@interface ServerHelper(Private)
+ (NSArray*) sendCommandWithParams: (NSMutableDictionary*) params;
+ (NSArray*) sendCommandWithParams: (NSMutableDictionary*) params needToStartServer: (BOOL) startServer;
+ (NSString*) getResponseToCommandWithParams:(NSMutableDictionary*) params needToStartServer: (BOOL) startServer;
@end

static BOOL					_serverIsRunning = NO;
static NSString*			_avpnServerPath = NULL;
static NSMutableDictionary* _knownSecrets = NULL;

@implementation ServerHelper
+ (void) initialize {
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];

	_knownSecrets = [[ NSMutableDictionary alloc ] init ];	
}

+ (NSString*) avpnServerPath {
	return _avpnServerPath;
}

+ (void) sendSynchroEvent: (NSString*) event {
	[ self sendSynchroEvent: event startServer: NO ];
}

+ (void) sendSynchroEvent: (NSString*) event startServer: (BOOL) yesNo {
	[ self sendCommandWithParams:
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"event", @"action",
			event, @"event",
			[ NSNumber numberWithBool: yesNo ], @"start-server",
			nil
		]
	];
}

+ (void) sendEvent: (NSString*) event {
	[ self sendEvent: event startServer: NO ];
}

+ (void) sendEvent: (NSString*) event startServer: (BOOL) yesNo {
	[ NSThread 
		detachNewThreadSelector: @selector(sendCommandWithParams:) 
		toTarget: self 
		withObject: 
			[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
				@"event", @"action",
				event, @"event",
				[ NSNumber numberWithBool: yesNo ], @"start-server",
				nil
			]
	];
}

+ (void) startProfile: (NSString*) profileName {
	[ NSThread 
		detachNewThreadSelector: @selector(sendCommandWithParams:) 
		toTarget: self 
		withObject: 
			[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
				@"start", @"action",
				profileName, @"profile",
				nil
			]
	];
}

+ (void) startProfileAndWait: (NSString*) profileName {
	[ self sendCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"start", @"action",
			profileName, @"profile",
			nil
		]
	];
}

+ (void) stopProfile: (NSString*) profileName {
	[ NSThread 
		detachNewThreadSelector: @selector(sendCommandWithParams:) 
		toTarget: self 
		withObject: 
			[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
				@"stop", @"action",
				profileName, @"profile",
				nil
			]
	];
}

+ (void) stopProfileAndWait: (NSString*) profileName {
	[ self sendCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"stop", @"action",
			profileName, @"profile",
			nil
		]
	];
}

+ (void) pauseProfile: (NSString*) profileName {
	[ NSThread 
		detachNewThreadSelector: @selector(sendCommandWithParams:) 
		toTarget: self 
		withObject: 
			[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
				@"pause", @"action",
				profileName, @"profile",
				nil
			]
	];
}

+ (void) pauseProfileAndWait: (NSString*) profileName {
	[ self sendCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"pause", @"action",
			profileName, @"profile",
			nil
		]
	];
}

+ (void) resumeProfile: (NSString*) profileName {
	[ NSThread 
		detachNewThreadSelector: @selector(sendCommandWithParams:) 
		toTarget: self 
		withObject: 
			[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
				@"resume", @"action",
				profileName, @"profile",
				nil
			]
	];
}

+ (void) resumeProfileAndWait: (NSString*) profileName {
	[ self sendCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"resume", @"action",
			profileName, @"profile",
			nil
		]
	];
}

+ (NSArray*) status {
	NSArray* result = [ self sendCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"status", @"action",
			@"txt", @"report-format",
			nil
		]
	];
	
	return result;
}

+ (void) stopServer {
	[ self sendCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"exit", @"action",
			nil
		]
	];
}

+ (BOOL) serverIsRunning {
	return _serverIsRunning;
}

+ (void) saveSecret: (NSString*) secret withKey: (NSString*) key {
	if( secret == nil ) {
		return;
	}
	[ _knownSecrets setObject: @"YES" forKey: key ];
	[ ServerHelper getResponseToCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"save-secret", @"action",
			secret, @"value",
			key, @"key",
			nil
		]
		needToStartServer: YES 
	];	
}

+ (BOOL) checkSecretWithKey: (NSString*) key {

	NSString* result = [ _knownSecrets objectForKey: key ];
	
	if(  result != nil ) {
		return [ @"YES" isEqual: result ];
	}
	
	result = [ ServerHelper getResponseToCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"check-secret", @"action",
			key, @"key",
			nil
		]
		needToStartServer: YES 
	];	

	if( result != nil ) {
		[ _knownSecrets setObject: result forKey: key ];	
	}
	
	return [ result rangeOfString: @"YES" ].location == 0;
}

+ (void) forgetSecretWithKey: (NSString*) key {
	[ _knownSecrets removeObjectForKey: key ];
	
	[ ServerHelper getResponseToCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"forget-secret", @"action",
			key, @"key",
			nil
		]
		needToStartServer: YES 
	];	
}

+ (NSString*) saveRegistrationKey: (NSString*) registration forUser: (NSString*) name withEMail: (NSString*) email {
	NSString* result = [ ServerHelper getResponseToCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"save-registration", @"action",
			registration, @"registration",
			name, @"name",
			email, @"email",
			nil
		]
		needToStartServer: YES 
	];	
	
	return result;
}

+ (NSString*) verifyRegistrationForUser: (NSString*) name withEMail: (NSString*) email {
	NSString* result = [ ServerHelper getResponseToCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"verify-registration", @"action",
			name, @"name",
			email, @"email",
			nil
		]
		needToStartServer: YES 
	];	
	
	return result;
}

+ (NSString*) forgetRegistration {
	NSString* result = [ ServerHelper getResponseToCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"forget-registration", @"action",
			nil
		]
		needToStartServer: YES 
	];	
	
	return result;
}

+ (NSString*) testLocation: (NSString*) uuid  {
	NSString* result = [ ServerHelper getResponseToCommandWithParams: 
		[ NSMutableDictionary dictionaryWithObjectsAndKeys: 
			@"test-location", @"action",
			uuid, @"uuid",
			nil
		]
		needToStartServer: YES 
	];	
	
	return result;
}

#pragma mark ServerHelper(Private)
+ (void) startServer {
	@synchronized ( self ) {
		if( _serverIsRunning ) {
			return;
		}
		
		if( [ PathLocator almostVPNServerInstallPath ] == nil ) {
			NSLog( @"ServerHelper.startServer : almostVPNServerInstallPath == NULL\n" );
			return;
		}
		[ self startService ];
		
		for( int i = 0; i < 10; i++ ) {
			NSArray* status = [ self status ];
			if( status != nil ) {
				return;
			}
			sleep( 3 );
		}
		
		NSRunCriticalAlertPanel( 
			@"Fatal Problem", 
			@"Fail to start AlmostVPNServer.\n\n"
			 "Please contact Leaping Bytes, LLC\n\n"
			 "e-mail: support@leapingbytes.com\n"
			 "   web: http://www.leapingbytes.com/almostvpn", 
			 @"OK", nil, nil 
		);		
		_avpnServerPath = nil;
	}
}
+ (NSArray*) sendCommandWithParams: (NSMutableDictionary*) params {
	return [ self sendCommandWithParams: params needToStartServer: NO ];
}

static int _actionCount = 0;
+ (NSString*) getResponseToCommandWithParams:(NSMutableDictionary*) params needToStartServer: (BOOL) startServer {
	NSArray* allKeys = [ params allKeys ];
	NSMutableString* query = [ NSMutableString string ];
	
	for( int i = 0; i < [ allKeys count ]; i ++ ) {
		NSString* key = [ allKeys objectAtIndex: i ];
		NSString* value = [ params objectForKey: key ];
		if( i != 0 ) {
			[ query appendString: @"&" ];
		}
		/*
		  reserved    = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" |
                    "$" | ","
		*/
		NSString* escapedValue = CFURLCreateStringByAddingPercentEscapes(
			kCFAllocatorDefault,
			value,
			NULL,
			@";/?:@&=+$,",
			kCFStringEncodingUTF8
		);
		[ query appendFormat: @"%@=%@", key, escapedValue ];
		if( escapedValue != value ) {
			CFRelease( escapedValue );
		}
	}
	
	NSString* fullURL = [ NSString stringWithFormat: @"http://127.0.0.1:1313/almostvpn/control/do%d?%@", _actionCount++, query ];
	NSURL* serverURL = [[ NSURL URLWithString: fullURL ] retain ];	
	
	NSError* error;
	NSString* string = [ NSString stringWithContentsOfURL: serverURL ];
	if(( [ string length ] == 0 ) && startServer ) {
		[ self startServer ];
		for( int i = 0; i < 5 && [ string length ] == 0; i++ ) {
			string = [ NSString stringWithContentsOfURL: serverURL encoding: NSUTF8StringEncoding error: &error ];
			if( [ string length ] == 0 ) {
				[[ NSRunLoop currentRunLoop ] runUntilDate: [ NSDate dateWithTimeIntervalSinceNow: 1.0 ]];
				[ serverURL release ];
				serverURL = [[ NSURL URLWithString: 
					[ NSString stringWithFormat: @"http://127.0.0.1:1313/almostvpn/control/do%d?%@", _actionCount++, query ] 
				] retain ];
			}
		}
		[ serverURL release ];
		
	} 
	
	if( [ string length ] == 0 ) {
		[ self setServerIsRunning: NO ];
	} else {
		[ self setServerIsRunning: YES ];
	}
	return string;
}

+ (NSArray*) sendCommandWithParams: (NSMutableDictionary*) params needToStartServer: (BOOL) startServer {
	NSMutableArray* result = [ NSMutableArray array ];
	NSAutoreleasePool* poll = [[ NSAutoreleasePool alloc ] init ];

	startServer = startServer || [[ params objectForKey: @"start-server" ] boolValue ];
	[ params removeObjectForKey: @"start-server" ];
	NSString* string = [ ServerHelper getResponseToCommandWithParams: params needToStartServer: startServer ];	
	if( [ string length ] != 0 ) {
		NSArray* lines =  [ string componentsSeparatedByString: @"\n" ];
		NSArray* keys = [[ lines objectAtIndex: 0 ] componentsSeparatedByString: @"|" ];

		for( int i = 1; i < [ lines count ]; i++ ) {
			NSArray* values = [[ lines objectAtIndex: i ] componentsSeparatedByString: @"|" ];
			NSMutableDictionary* dictionary = [ NSMutableDictionary dictionary ];
			for( int j = 0; j < [ values count ]; j++ ) {
				[ dictionary setObject: [ values objectAtIndex: j ] forKey: [ keys objectAtIndex: j ]];
			}
			[ result addObject: dictionary ];
		}
	} else {
		result = nil;
	}
	[ poll release ];

	return result;
}

+ (void) setServerIsRunning: (BOOL) v  {
	_serverIsRunning = v;
	if( v ) {
		[ ServerMonitor monitor: @"127.0.0.1" ];
	}
	[[ NSNotificationCenter defaultCenter ] postNotificationName: @"ServerStateEvent" object: [ NSNumber numberWithBool: v ]];		
}

#pragma mark Service Control
+ (void) serviceCommand: (NSString*) action usingTool: (NSString*) toolPath {
	NSTask* task = [ NSTask 
		launchedTaskWithLaunchPath: toolPath 
		arguments: [ NSArray arrayWithObject: action ]
	];
	[ task waitUntilExit ];
}
+ (void) serviceCommand: (NSString*) action {
	[ self serviceCommand: action usingTool: [ PathLocator almostVPNServerInstallPath ]];
}

+ (void) startService {
	[ self serviceCommand: @"--startService" ];
}

+ (void) stopService {
	[ self serviceCommand: @"--stopService" ];
}

+ (void) restartService {
	[ self serviceCommand: @"--restartService"  ];
}

@end
