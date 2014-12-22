//
//  AlmostVPNBonjourRef.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 6/17/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNObjectRef.h"

@interface AlmostVPNBonjourRef : AlmostVPNObjectRef {

}

- (NSString*) localPort;
- (void) setLocalPort: (NSString*) port;

@end
