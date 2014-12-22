//
//  AlmostVPNMenuBar.h
//  AlmostVPN
//
//  Created by andrei tchijov on 11/17/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNModel.h"

@interface AlmostVPNProMenuBar : NSObject {
	AlmostVPNConfiguration* _configuration;
	NSDate*					_configurationModificationDate;
	
	NSStatusItem*			_statusItem;
	
	NSString*				_agregatedStatus;	
	NSMutableDictionary*	_profileStates;
	
	BOOL					_serviceIsRunning;
}

+ (AlmostVPNProMenuBar*) sharedInstance;

- (NSArray*) listProfiles;
- (NSArray*) profiles;

- (void) startThisProfile: (AlmostVPNProfile*) p ;
- (void) stopThisProfile: (AlmostVPNProfile*) p ;

- (NSString*) statusToImageName;
@end
