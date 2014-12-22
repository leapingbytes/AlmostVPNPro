//
//  LBService.h
//  AlmostVPN
//
//  Created by andrei tchijov on 8/24/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AVPN.h"

#define LBService avpnClass( LBService )


@interface LBService : NSObject {
	NSString*	name;
	int			number;
}
+ (void)rememberFromPreferences: (NSArray*) preferences;
+ (void)servicesToPreferences: (NSMutableArray*) preferences;

+ (NSMutableArray*) knownServices;
+ (void) setKnownServices: (NSMutableArray*) anArray;
+ (void) rememberService: (NSString*) name withNumber: (int) number;
+ (void) rememberService: (LBService*) aService;

+(int) nameToNumber: (NSString*) name;
+(NSString*) numberToName: (int) number;

+(int) knownNameToNumber: (NSString*) name;
+(int) getservbyname: (NSString*) name;

+(NSString*) knownNumberToName: (int) number;
+(NSString*) getservbyport: (int) number;


+(id)serviceWithNumber: (int) number;
+(id)serviceWithName: (NSString*) name andNumber: (int)number;
+(id)serviceWithName: (NSString*) name;

-(NSString*) stringValue;
-(int) intValue;

- (NSString*) name;
- (void) setName: (NSString*) value;

- (int) number;
- (void) setNumber: (int) value;

@end
