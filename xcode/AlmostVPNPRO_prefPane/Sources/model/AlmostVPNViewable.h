//
//  AlmostVPNViewable.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AlmostVPNObject.h"

@interface AlmostVPNViewable : AlmostVPNObject {
}
+ (NSString*) icon;

- (NSString*) label;

- (NSString*) icon;
- (void) setIcon: (NSString*) value;

- (AlmostVPNViewable*) parent;
- (void) setParent: (AlmostVPNViewable*) parent;

- (AlmostVPNViewable*) location;

- (BOOL) isDecendentOf:(AlmostVPNViewable*) anObject;
- (BOOL) hasAncestorOfClass: (Class) aClass;

- (BOOL) canHaveChild: (NSString*) childKind;
@end
