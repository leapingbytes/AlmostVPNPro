//
//  Agent.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 5/14/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SCNetworkReachability.h>


@interface Agent : NSObject {
	SCNetworkReachabilityRef _reachabilityTester;

	NSString*				_event;
	int						_repeatCount;
	
	NSDate*					_waitUntil;
}
- (id) init;

- (BOOL) isReachable;
- (void) reachabilityChanged: (NSString*) src;

- (void) didWake: (id) notification;
- (void) willSleep: (id) notification;
- (void) switchIn: (id) notification;
- (void) switchOut: (id) notification;
- (void) powerOff: (id) notification;
@end
