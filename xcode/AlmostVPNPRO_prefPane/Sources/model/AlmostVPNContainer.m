//
//  AlmostVPNContainer.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/4/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNContainer.h"

#define _CHILDREN_KEY_			@"children"

@implementation AlmostVPNContainer

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	NSArray* children = [ aDictionary objectForKey: _CHILDREN_KEY_ ];
	for( int i = 0; i < [ children count ]; i++ ) {
		AlmostVPNViewable* child = (AlmostVPNViewable*)[ AlmostVPNViewable objectWithDictionary: [ children objectAtIndex: i ]];
		[ self addChild: child ];
		[ child release ];
	}

	[ AlmostVPNContainer performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (NSMutableArray*) children {
	NSMutableArray* children = [ self objectForKey: _CHILDREN_KEY_ ];
	if( children == nil ) {
		children = [[ NSMutableArray alloc ] init ];
		[ self setObject: children forKey: _CHILDREN_KEY_ ];
		[ children release ];
	}
	return children;
} 

- (void) setChildren: (NSArray*) anArray {
	[ self setObject: [ anArray mutableCopy ] forKey: _CHILDREN_KEY_ ];
}

- (int) countChildren {
	NSMutableArray* children = [ self objectForKey: _CHILDREN_KEY_ ];
	return children == nil ? 0 : [ children count ];
}

- (void) removeAllChildren {
	[ self removeObjectForKey: _CHILDREN_KEY_ ];
}

- (AlmostVPNViewable*) addChild: (AlmostVPNViewable*) child {
	NSMutableArray* children = [ self children ];
	AlmostVPNViewable* parent = [ child parent ];
	
	[ child retain ];
	if( parent == self ) {
		[ child setParent: nil ];
		[ children removeObject: child ];
	} else if( parent != nil ) {
		[ (AlmostVPNContainer*)parent removeChild: child ];
	}
	
	assert( [ child parent ] == nil );
	
	[ children addObject: child ];
	[ child setParent: self ];

	[ child release ];

	return child;
}

- (NSArray*) childrenKindOfClass: (Class) aClass {
	NSArray* children = [ self children ];
	NSMutableArray* result = [ NSMutableArray array ];
	for( int i = 0; i < [ children count ]; i++ ) {
		AlmostVPNViewable* child = [ children objectAtIndex: i ];
		if( [ child isKindOfClass: aClass ] ) {
			[ result addObject: child ];
		}
	} 
	return result;
}

- (NSArray*) childrenMemberOfClass: (Class) aClass {
	NSArray* children = [ self children ];
	NSMutableArray* result = [ NSMutableArray array ];
	for( int i = 0; i < [ children count ]; i++ ) {
		AlmostVPNViewable* child = [ children objectAtIndex: i ];
		if( [ child isMemberOfClass: aClass ] ) {
			[ result addObject: child ];
		}
	} 
	return result;
}


- (void) removeChild: (AlmostVPNViewable*) child {
	AlmostVPNViewable* parent = [ child parent ];
	assert( parent == self );

	NSMutableArray* childrenUUIDs = [ self objectForKey: _CHILDREN_KEY_ ];
	[ child setParent: nil ];
	[ childrenUUIDs removeObject: child ];
}

- (AlmostVPNViewable*) findChild: (NSString*) childName {
	NSMutableArray* children = [ self children ];
	if( children == nil ) {
		return nil;
	}
	for( int i = 0; i < [ children count ]; i++ ) {	
		AlmostVPNViewable* child = [ children objectAtIndex: i ];
		if( [ childName isEqual: [ child name ]] ) {
			return child;
		}
	}
	return nil;
}

- (BOOL) isContainer {
	return YES;
}

- (AlmostVPNObject*) childOfClass: (Class) childClass andName: (NSString*) childName createIfNeeded: (BOOL) createIfNeeded {	
	NSMutableArray* children = [ self children ];
	AlmostVPNObject* result = nil;
	for( int i = 0; i < [ children count ]; i++ ) {	
		AlmostVPNViewable* child = [ children objectAtIndex: i ];
		if( [ child class ] != childClass ) {
			continue;
		}
		if( [ childName isEqual: [ child name ]] ) {
			result = child;
			break;
		}
	}
	if( result == nil && createIfNeeded ) {
		result = [[ childClass alloc ] init ];
		[ result setName: childName ];
		[ result bootstrap ];
		[ self addChild: (AlmostVPNViewable*)result ];
	}
	
	return result;
}

@end
