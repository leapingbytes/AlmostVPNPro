//
//  AlmostVPNResource.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/4/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNResource.h"
#import "AlmostVPNProfile.h"

@implementation AlmostVPNResource
- (NSArray*) profiles {
	NSArray* profiles = [ AlmostVPNObject objectsKindOfClass: [ AlmostVPNProfile class ]];
	NSMutableArray* result = [ NSMutableArray array ];
	for( int i = 0; i < [ profiles count ]; i++ ) {
		AlmostVPNProfile* profile = [ profiles objectAtIndex: i ];
		if( [ profile containsResource: self ] ) {
			[ result addObject: profile ];
		}
	}
	return result;
}

@end
