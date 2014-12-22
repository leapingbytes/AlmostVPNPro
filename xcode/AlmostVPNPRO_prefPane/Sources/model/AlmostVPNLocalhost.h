//
//  AlmostVPNLocalHost.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNLocation.h"

@interface AlmostVPNLocalhost : AlmostVPNLocation {

}
+ (AlmostVPNLocalhost*) sharedInstance;

- (int) countIdentities ;

- (NSArray*) identities ;

- (NSNumber*) canSUDO;
- (void) setCanSUDO: (NSNumber*) v;

- (AlmostVPNIdentity*) defaultIdentity;
- (AlmostVPNIdentity*) identityWithName: (NSString*) name;

@end
