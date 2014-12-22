//
//  LogRecords.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 5/21/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define _STATE_EVENT_		1
#define _LOG_EVENT_			2
#define _UTILIZATION_EVENT_	4
#define _FOR_PAY_EVENT_		8

@interface LogRecord : NSObject {
	int					_type;
	
	NSTimeInterval		_timestamp;		// seconds since 1 January 1970, GMT
	NSString*			_source;		// log message source, profile uuid, location uuid
	NSString*			_message;		// log message, state comment
	
	

	// Log event fields
	int					_level;
	
	// State event fields
	NSString*			_profileState;
	
	// Utilization event fields
	int					_inBytes;
	int					_outBytes;
}
+ (LogRecord*) parseServerEvent: (NSString*) string ;

- (int) type;
- (void) setType: (int) v;
- (BOOL) isStateEvent;
- (BOOL) isLogEvent;
- (BOOL) isUtilizationEvent;

// Common fields accessors
- (NSTimeInterval) timestamp;
- (void) setTimestamp: (NSTimeInterval) v;

- (NSString*) source;
- (void) setSource: (NSString*) v;

- (NSString*) message;
- (void) setMessage: (NSString*) v;

- (NSString*) date;

- (NSString*) logViewMessage;
- (NSString*) logViewSource;
- (NSString*) state;
// Log event accessors
- (int) level;
- (void) setLevel: (int) v;

// State event accessors
- (NSString*) profileUuid;
- (void) setProfileUuid: (NSString*) v;

- (NSString*) profileState;
- (void) setProfileState:(NSString*) v;

- (NSString*) profileStateComment;
- (void) setProfileStateComment: (NSString*) v;

// Utilization event
- (NSString*) locationUuid;
- (void) setLocationUuid: (NSString*) v;

- (int) inBytes;
- (void) setInBytes: (int) v;

- (int) outBytes;
- (void) setOutBytes: (int) v;

@end
