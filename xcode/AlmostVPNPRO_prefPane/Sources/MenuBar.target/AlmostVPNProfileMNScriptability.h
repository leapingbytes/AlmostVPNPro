//
//  AlmostVPNProfileMNScriptability.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 8/19/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "AlmostVPNModel.h"

@interface AlmostVPNProfile (AVPNScriptability) 
- (void) startThisProfile: (NSScriptCommand*) c;
- (void) stopThisProfile: (NSScriptCommand*) c;
@end
