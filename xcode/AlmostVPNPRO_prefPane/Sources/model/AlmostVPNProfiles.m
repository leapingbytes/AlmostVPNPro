//
//  AlmostVPNProfiles.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 12/3/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNProfiles.h"


@implementation AlmostVPNProfiles

- (BOOL) canHaveChild: (NSString*) childKind {
	return	[ @"Profile" isEqual: childKind ]
	;
}
@end
