//
//  AlmostVPNHostAlias.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 12/12/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNObjectRef.h"
#import "AlmostVPNHost.h"

@interface AlmostVPNHostAlias : AlmostVPNObjectRef {
}
+ (NSString*) aliasNameFromRealName: (NSString*) realName;

- (NSString*) aliasName;
- (void) setAliasName: (NSString*) v;

- (NSString*) aliasAddress;
- (void) setAliasAddress: (NSString*) v;

- (NSNumber*) autoAliasAddress;
- (void) setAutoAliasAddress: (NSNumber*) v;
@end
