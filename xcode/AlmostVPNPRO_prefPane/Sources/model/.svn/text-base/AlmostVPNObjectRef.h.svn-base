//
//  AlmostVPNObjectRef.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/11/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AlmostVPNViewable.h"

#define _REF_OBJECT_UUID_KEY_	@"reference-object-uuid"

@interface AlmostVPNObjectRef : AlmostVPNViewable {

}
+ (AlmostVPNObjectRef*) referenceWithObject: (AlmostVPNViewable*) anObject;
- (AlmostVPNObjectRef*) initWithObject: (AlmostVPNViewable*) anObject;

- (AlmostVPNViewable*) referencedObject;
- (void) setReferencedObject: (AlmostVPNViewable*) anObject;
@end
