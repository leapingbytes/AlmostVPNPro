//
//  FileRef.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 4/12/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNObjectRef.h"
#import "AlmostVPNLocation.h"

extern id	_FILE_COPY_OPERATION_;
extern id	_FILE_MOVE_OPERATION_;
extern id	_FILE_NOP_OPERATION_;

@interface AlmostVPNFileRef : AlmostVPNObjectRef {

}

- (AlmostVPNLocation*) destinationLocation;
- (void) setDestinationLocation: (AlmostVPNLocation*) v;

- (NSString*) destinationPath;
- (void) setDestinationPath: (NSString*) v;

- (id) doAfterStart;
- (void) setDoAfterStart: (id) v;

- (id) doThis;
- (void) setDoThis: (id) v;

- (id) andExecute;
- (void) setAndExecute:(id) v;

//- (id) onStartOperation;
//- (void) setOnStartOperation: (id) v;
//
//- (id) executeOnStart;
//- (void) setExecuteOnStart: (id) v;
//
//- (id) onStopOperation;
//- (void) setOnStopOperation: (id) v;
//
//- (id) executeOnStop;
//- (void) setExecuteOnStop: (id) v;
//
@end
