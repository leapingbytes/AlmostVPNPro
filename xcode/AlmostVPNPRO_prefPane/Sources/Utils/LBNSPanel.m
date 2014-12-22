//
//  LBNSPanel.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 12/3/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "LBNSPanel.h"

static NSMutableDictionary* _panels = nil;

@implementation LBNSPanel
- (void) awakeFromNib {
	if( _panels == nil ) {
		_panels = [[ NSMutableDictionary alloc ] init ];
	}
	[ _panels setObject: self forKey: [ self title ]];
}

+ (id) panelWithTitle: (NSString*) title {
	return [ _panels objectForKey: title ];
}

@end
