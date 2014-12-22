//
//  AlmostVPNRemoteControlRef.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/13/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNObjectRef.h"

@interface AlmostVPNRemoteControlRef : AlmostVPNObjectRef {

}
- (id) useBonjour;
- (void) setUseBonjour: (id) v;

- (id) startToControl;
- (void) setStartToControl: (id) v ;

- (id) controlCommand ;
- (void) setControlCommand: (id) v ;
@end
