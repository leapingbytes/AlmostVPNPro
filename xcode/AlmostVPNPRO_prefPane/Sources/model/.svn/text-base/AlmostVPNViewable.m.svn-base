//
//  AlmostVPNViewable.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNViewable.h"
#import "AlmostVPNLocation.h"

#define _ICON_KEY_			@"icon"
#define _PARENT_UUID_KEY_	@"parent-uuid"

#define _DEFAULT_ICON_		@"Default"

@implementation AlmostVPNViewable
- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ aDictionary objectForKey: _ICON_KEY_ ] forKey: _ICON_KEY_ ];
	
	[ AlmostVPNViewable performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

+ (NSString*) icon {
	NSString* result = [ self kind ];
	return result == nil ? _DEFAULT_ICON_ : result;
}

- (NSString*) label {
	return [ self name ];
}

- (NSString*) icon {
	NSString* result = [ self objectForKey: _ICON_KEY_ ];
	return result == nil ? [[ self class ] icon ] : result;
}

- (void) setIcon: (NSString*) value {
	[ self setObject: value forKey: _ICON_KEY_ ];
}

- (AlmostVPNViewable*) parent {
	NSString* parentUUID = [ self stringValueForKey: _PARENT_UUID_KEY_ ];	
	AlmostVPNViewable* result = parentUUID == nil ? nil : (AlmostVPNViewable*)[ AlmostVPNObject findObjectWithUUID: parentUUID ];	
	return result;
}

- (AlmostVPNViewable*) location {
	if( [ self isKindOfClass: [ AlmostVPNLocation class ]] ) {
		return self;
	}
	AlmostVPNViewable* parent = [ self parent ];
	if ( [ parent isKindOfClass: [ AlmostVPNLocation class ]] ) {
		return parent;
	} else {
		return [ parent location ];
	}
}

- (void) setParent: (AlmostVPNViewable*) parent {
	if( parent == nil ) {
		[ self removeObjectForKey: _PARENT_UUID_KEY_ ];
	} else {
		NSString* parentUUID = [ parent uuid ];
	
		assert( parentUUID != nil );
	
		[ self setStringValue: parentUUID forKey: _PARENT_UUID_KEY_ ];
	}
}

- (NSString*) fullName {
	if( [ self isContainer ] ) {
		return [ self name ];
	} else {
		return [ NSString stringWithFormat: @"%@@%@", [ self name ], [[ self parent ] name ]];
	}
}

- (BOOL) isDecendentOf:(AlmostVPNViewable*) anObject {
	AlmostVPNViewable* parent = [ self parent ];
	if( parent == nil ) {
		return NO;
	} else if( [ parent isEqual: anObject ] ) {
		return YES;
	} else {
		return [ parent isDecendentOf: anObject ];
	}
}

- (BOOL) hasAncestorOfClass: (Class) aClass {
	AlmostVPNViewable* parent = [ self parent ];
	if( parent == nil ) {
		return NO;
	} else if( [ parent isKindOfClass: aClass ] ) {
		return YES;
	} else {
		return [ parent hasAncestorOfClass: aClass ];
	}
}

- (BOOL) canHaveChild: (NSString*) childKind {
	return NO;
}
@end
