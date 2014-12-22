//
//  AlmostVPNBonjour.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 6/14/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNModel.h"

@interface AlmostVPNBonjour : AlmostVPNResource {
}

- (NSString*) type;
- (void) setType: (NSString*) v;

- (NSString*) port;
- (void) setPort: (NSString*) v;

- (id) bonjourTitle;
- (void) setBonjourTitle: (id) v;

- (id) properties;
- (void) setProperties: (id) v;

- (id) customProperties;
- (void) setCustomProperties: (id) v;
@end
