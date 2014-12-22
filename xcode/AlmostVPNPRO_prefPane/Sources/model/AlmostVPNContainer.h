//
//  AlmostVPNContainer.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/4/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AlmostVPNViewable.h"

@interface AlmostVPNContainer : AlmostVPNViewable {
}

- (NSMutableArray*) children;
- (void) setChildren: (NSArray*) value;
- (int) countChildren;
- (void) removeAllChildren;

- (NSArray*) childrenKindOfClass: (Class) aClass;
- (NSArray*) childrenMemberOfClass: (Class) aClass;

- (AlmostVPNViewable*) addChild: (AlmostVPNViewable*) child;
- (void) removeChild: (AlmostVPNViewable*) child;
- (AlmostVPNViewable*) findChild: (NSString*) childName; 

- (AlmostVPNObject*) childOfClass: (Class) childClass andName: (NSString*) childName createIfNeeded: (BOOL) createIfNeeded;
@end
