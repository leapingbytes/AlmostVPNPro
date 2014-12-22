//
//  AlmostVPNRemoteControl.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/13/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNResource.h"
#import "AlmostVPNAccount.h"

@interface AlmostVPNRemoteControl : AlmostVPNResource {

}

+ (NSArray*) rcTypes;

- (NSString*) rcTypeLabel;

- (id) rcType;
- (void) setRcType: (id) v;

- (id) port;
- (void) setPort: (id) v;

- (id) bindToLocalhost;
- (void) setBindToLocalhost: (id) v;

- (AlmostVPNAccount*) account;
- (void) setAccount: (AlmostVPNAccount*) anAccount;
@end
