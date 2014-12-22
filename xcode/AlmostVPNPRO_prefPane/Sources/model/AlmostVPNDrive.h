//
//  AlmostVPNDrive.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 3/22/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AlmostVPNResource.h"
#import "AlmostVPNAccount.h"

@interface AlmostVPNDrive : AlmostVPNResource {

}

- (NSString*) driveType;
- (void) setDriveType: (NSString*) v;

- (NSString*) drivePath;
- (void) setDrivePath: (NSString*) v;

- (AlmostVPNAccount*) account;
- (void) setAccount: (AlmostVPNAccount*) v;

@end
