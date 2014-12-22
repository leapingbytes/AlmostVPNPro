//
//  AlmostVPNObjectRef.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/11/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNObjectRef.h"

@implementation AlmostVPNObjectRef
+ (AlmostVPNObjectRef*) referenceWithObject: (AlmostVPNViewable*) anObject {
	AlmostVPNObjectRef* result = [[ AlmostVPNObjectRef alloc ] initWithObject: anObject ];
	return result;
}

- (AlmostVPNObjectRef*) initWithObject: (AlmostVPNViewable*) anObject {
	self = [ super init ];
	[ self setReferencedObject: anObject ];
	[ self bootstrap ];
	return self;
}

- (NSString*) name {
	return [[ self referencedObject ] name ];
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	self = (id)[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ aDictionary objectForKey: _REF_OBJECT_UUID_KEY_ ] forKey: _REF_OBJECT_UUID_KEY_ ];

	[ AlmostVPNObjectRef performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (AlmostVPNViewable*) referencedObject {
	NSString* referenceUUID = [ self objectForKey: _REF_OBJECT_UUID_KEY_ ];
	AlmostVPNViewable* result = referenceUUID == nil ? nil : (AlmostVPNViewable*)[ AlmostVPNObject findObjectWithUUID: referenceUUID ];
	return result;
}

- (void) setReferencedObject: (AlmostVPNViewable*) anObject {
	if( anObject == nil ) {
		[ self removeObjectForKey: _REF_OBJECT_UUID_KEY_ ];
	} else {
		[ self setObject: [ anObject uuid ] forKey: _REF_OBJECT_UUID_KEY_ ];
	}
}

- (BOOL) isReference {
	return YES;
}

@end
