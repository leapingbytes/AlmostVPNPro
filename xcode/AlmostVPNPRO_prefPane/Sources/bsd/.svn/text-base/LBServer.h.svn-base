//
//  LBServer.h
//  AlmostVPN
//
//  Created by andrei tchijov on 8/24/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AVPN.h"

// #define LBServer comLeapinbytesAlmostVPNPROLBServer

#define LBServer avpnClass( LBServer )

@interface LBServer : NSObject {
	NSString*	name;
	NSString*	address;

	BOOL		resolved;
}
+(NSMutableArray*) knownServers;
+(void) setKnownServers:(NSMutableArray*)anArray;

+(NSString*) knownNameToAddress: (NSString*) value;
+(NSString*) gethostbyname: (NSString*) value;

+(NSString*)nameToAddress: (NSString*)value;
+(NSString*)addressToName: (NSString*)value;

+(id)serverWithName: (NSString*) name;
+(id)serverWithAddress: (NSString*) address;
+(id)serverWithName: (NSString*) name andAddress: (NSString*) address;

+(void)rememberServer: (NSString*) name withAddress: (NSString*) address;
+(void)rememberServer: (LBServer*) aServer;

+ (void)rememberFromPreferences: (NSArray*) preferences;
+ (void)serversToPreferences: (NSMutableArray*) preferences;

+ (LBServer*) findServer: (NSString*) name;

- (NSString*) stringValue;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)address;
- (void)setAddress:(NSString *)value;

- (BOOL)resolved;
- (BOOL)isResolved;
- (void)setResolved: (BOOL) value;

@end

@interface LBServerResolvedToColorTransformer : NSValueTransformer {
}
@end
