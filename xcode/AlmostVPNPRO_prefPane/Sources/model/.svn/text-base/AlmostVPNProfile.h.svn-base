//
//  AlmostVPNProfile.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/7/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNContainer.h"
#import "AlmostVPNResource.h"

extern	id	_RUN_MANUALLY_;
extern	id	_RUN_AT_START_;
extern	id	_RUN_AT_BOOT_;
extern	id	_RUN_AT_LOGIN_;

@interface AlmostVPNProfile : AlmostVPNContainer {
}
- (int) countResources;
- (NSArray*) resources;
- (BOOL) containsResource: (AlmostVPNResource*) aResource;
- (void) addResource: (AlmostVPNResource*) aResource;
- (void) removeResource: (AlmostVPNResource*) aResource;

- (id) restartOnError;
- (void) setRestartOnError: (id) v;

- (id) fireAndForget;
- (void) setFireAndForget: (id) v;

- (id) stopOnFUS;
- (void) setStopOnFUS: (id) v;

- (id) runMode;
- (void) setRunMode: (id) v;

//- (id) startAt;
//- (void) setStartAt: (id) v;
//
//- (id) stopAt;
//- (void) setStopAt: (id) v;
//

- (id) disabled;
- (void) setDisabled: (id) v;

- (NSString*) state;
- (void) setState: (NSString*) v;

- (NSString*) stateComment;
- (void) setStateComment: (NSString*)v;

- (NSString*) stateColor;
@end
