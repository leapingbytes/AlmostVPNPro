//
//  LBNSTableView.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 4/12/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "LBNSTableView.h"


static NSMutableArray*	_tables;
static id				_delegate = nil;
static SEL				_action = nil;
static SEL				_doubleAction = nil;

@implementation LBNSTableView

+(NSArray*) tables {
	if( _tables == nil ) {
		_tables = [[ NSMutableArray alloc ] init ];
	} 
	return _tables;
}

+ (void) setDelegate: (id) v {
	_delegate = v;
	NSEnumerator* e = [[ self tables ] objectEnumerator ];
	id t;
	while(( t = [ e nextObject ] ) != nil ) {
		[ t setDelegate: v ];
	}
}
+ (void) setAction: (SEL) v {
	_action = v;
	NSEnumerator* e = [[ self tables ] objectEnumerator ];
	id t;
	while(( t = [ e nextObject ] ) != nil ) {
		[ t setAction: v ];
	}
}
+ (void) setDoubleAction: (SEL) v {
	_doubleAction = v;
	NSEnumerator* e = [[ self tables ] objectEnumerator ];
	id t;
	while(( t = [ e nextObject ] ) != nil ) {
		[ t setDoubleAction: v ];
	}
}

- (void) customInit {
	[ LBNSTableView tables ]; // To make sure that _tables allocated
	[ _tables addObject: self ];
	if( _delegate != nil ) {
		[ self setDelegate: _delegate ];
	}
	if( _action != nil ) {
		[ self setAction: _action ];
	}
	if( _doubleAction != nil ) {
		[ self setDoubleAction: _doubleAction ];
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [ super initWithCoder: decoder ];
	[ self customInit ];
	return self;
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [ super initWithFrame: frameRect ];
	[ self customInit ];
	return self;
}

@end
