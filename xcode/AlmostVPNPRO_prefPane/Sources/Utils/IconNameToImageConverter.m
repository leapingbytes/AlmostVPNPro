//
//  IconNameToImageConverter.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 12/8/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "IconNameToImageConverter.h"
#import "PathLocator.h"
#import "AlmostVPNModel.h"

@implementation IconNameToImageConverter
+ (Class)transformedValueClass { return [NSImage self]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	return [ PathLocator imageNamed: value ];
}

@end
