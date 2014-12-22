//
//  ServerHelper.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 3/14/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ServerHelper : NSObject {
}
+ (void) startServer;

+ (void) startService;
+ (void) stopService;
+ (void) restartService;

+ (void) sendEvent: (NSString*) event;
+ (void) sendEvent: (NSString*) event startServer: (BOOL) yesNo;

+ (void) startProfile: (NSString*) profileName;
+ (void) stopProfile: (NSString*) profileName;
+ (void) pauseProfile: (NSString*) profileName;
+ (void) resumeProfile: (NSString*) profileName;

+ (void) startProfileAndWait: (NSString*) profileName;
+ (void) stopProfileAndWait: (NSString*) profileName;
+ (void) pauseProfileAndWait: (NSString*) profileName;
+ (void) resumeProfileAndWait: (NSString*) profileName;

+ (NSArray*) status;

+ (void) stopServer;

+ (BOOL) serverIsRunning;

+ (void) saveSecret: (NSString*) secret withKey: (NSString*) key;
+ (BOOL) checkSecretWithKey: (NSString*) key;
+ (void) forgetSecretWithKey: (NSString*) key;

+ (void) setServerIsRunning: (BOOL) v;

+ (NSString*) saveRegistrationKey: (NSString*) key forUser: (NSString*) user withEMail: (NSString*) email;
+ (NSString*) verifyRegistrationForUser: (NSString*) name withEMail: (NSString*) email;
+ (NSString*) forgetRegistration;

+ (NSString*) testLocation: (NSString*) locationUUID;

+ (void) sendSynchroEvent: (NSString*) event;
+ (void) sendSynchroEvent: (NSString*) event startServer: (BOOL) yesNo;

+ (void) serviceCommand: (NSString*) action;

@end
