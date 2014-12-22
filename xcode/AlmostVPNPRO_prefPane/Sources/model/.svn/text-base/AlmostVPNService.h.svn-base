//
//  AlmostVPNService.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNResource.h"

@protocol ServiceResolver 
	- (int) serviceNameToPort: (NSString*) name;
	- (NSString*) portToServiceName: (int) port;
	- (void) rememberServiceName: (NSString*)name withPort: (int) port;
@end

@interface AlmostVPNService : AlmostVPNResource {

}

+(id<ServiceResolver>)resolver;
+(void) setResolver: (id<ServiceResolver>)v;

- (NSString*) port;
- (void) setPort: (NSString*) value;
@end
