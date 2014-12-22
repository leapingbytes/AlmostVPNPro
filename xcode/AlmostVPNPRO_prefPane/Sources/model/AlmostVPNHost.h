//
//  AlmostVPNHost.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/4/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AlmostVPNContainer.h"
@protocol HostResolver 
	- (NSString*) hostNameToAddress: (NSString*) name;
	- (NSString*) addressToHostName: (NSString*) address;
	- (void) rememberHostName: (NSString*)name withAddress: (NSString*) address;
@end

@interface AlmostVPNHost : AlmostVPNContainer {
}

+(id<HostResolver>) resolver;
+(void) setResolver: (id<HostResolver>)v;

- (BOOL) resolvable;
- (void) setResolvable: (BOOL) value;

- (NSString*) address;
- (void) setAddress: (NSString*) anAddress;

//- (NSString*) addressIPv6;
//- (void) setAddressIPv6: (NSString*) anAddress;

- (NSArray*) resources;
@end
