//
//  QuickConfigHelper.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/24/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QuickConfigHelper : NSObject {
	NSMutableDictionary* _configDictionary;
}

- (void) initializedQuickConfigDictionary;

- (NSMutableDictionary*) configDictionary;

+ (QuickConfigHelper*) sharedInstance;

+ (NSMutableDictionary*) processQuickConfigDictionary: (NSMutableDictionary*) v;

+ (NSMutableDictionary*) addFileToImports: (NSString*) fileName;

@end
