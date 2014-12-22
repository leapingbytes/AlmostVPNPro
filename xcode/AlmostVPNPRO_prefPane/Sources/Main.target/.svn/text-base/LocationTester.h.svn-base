//
//  AccountTester.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 8/2/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNLocation.h"

@interface LocationTester : NSObject {
	AlmostVPNLocation*	_location;
	
	BOOL				_tested;
	BOOL				_good;
	
	BOOL				_testScheduled;
	BOOL				_testInProgress;
	BOOL				_doItAgain;
	
	NSThread*			_testThread;
}

+ (void) watchLocation: (AlmostVPNLocation*) location;

+ (LocationTester*) testerForLocation: (AlmostVPNLocation*) account;

- (id) setValue: (id) aValue forProperty: (NSString*) aName ofObject: (AlmostVPNObject*) o;

- (BOOL) tested;
- (BOOL) good;
@end
