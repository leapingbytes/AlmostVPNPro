//
//  AlmostVPNLocation.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/4/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AlmostVPNContainer.h"
#import "AlmostVPNIdentity.h"
#import "AlmostVPNAccount.h"
#import "AlmostVPNHost.h"

#define	NOT_TESTED			@"not tested"
#define GOOD				@"good"
#define BAD					@"bad"
#define TERMINAL			@"terminal"
#define TESTING				@"testing"

@interface AlmostVPNLocation : AlmostVPNHost {

}
- (BOOL) direct;

- (AlmostVPNIdentity*) identity;
- (void) setIdentity: (AlmostVPNIdentity*) anIdentity;

- (AlmostVPNAccount*) account;
- (void) setAccount: (AlmostVPNAccount*) anAccount;

- (NSString*) port;
- (void) setPort: (NSString*) v;

- (NSString*) timeout;
- (void) setTimeout: (NSString*) v;

- (NSString*) proxy;
- (void) setProxy: (NSString*) v;

- (int) countHosts;
- (NSArray*) hosts;

- (int) countLocations;
- (NSArray*) locations;

- (id) status;
- (void) setStatus: (id) v;

- (id) sshdReply ;
- (void) setSshdReply: (id) v;

- (void) setStatus: (id) status withMessage: (id) message;

- (BOOL) goodToGo;

- (id) keepAlive;
- (void) setKeepAlive: (id) v;

- (id) runDynamicProxy;
- (void) setRunDynamicProxy: (id) v ;

- (id) shareDynamicProxy ;
- (void) setShareDynamicProxy: (id) v ;

- (id) dynamicProxyPort ;
- (void) setDynamicProxyPort: (id) v ;

@end
