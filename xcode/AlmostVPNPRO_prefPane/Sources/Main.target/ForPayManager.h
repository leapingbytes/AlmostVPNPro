//
//  ForPayManager.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 6/7/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNModel.h"

@interface ForPayManager : NSObject {
	int					_forPayCounter;
	AlmostVPNProfile*	_profile;
	NSString*			_profileName;
	int					_vhostCount;
}
+ (ForPayManager*) sharedInstance;
+ (void) evalConfiguration;
+ (void) forPayFeature: (NSString*) comment;
+ (int) forPayCounter;

- (int) forPayCounter;

- (id) forPayFeaturesUsed;
- (void) setForPayFeaturesUsed: (id) v ;

- (void) evalConfiguration;
- (void) forPayFeature: (NSString*) comment;

- (NSString*) indicator;
- (void) setIndicator: ( NSString*) v;

- (NSString*) indicatorToolTip;
- (void) setIndicatorToolTip: (NSString*)  v;
@end
