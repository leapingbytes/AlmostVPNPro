//
//  LogRecords.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 5/21/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNModel.h"
#import "LogRecord.h"


static NSDictionary*	_level_names_;

@implementation LogRecord

+ (void) initialize {
	_level_names_ = [[ NSDictionary dictionaryWithObjectsAndKeys:
		@"SEVERE", [ NSNumber numberWithInt: 1000 ],
		@"WARNING", [ NSNumber numberWithInt: 900 ], 
		@"INFO", [ NSNumber numberWithInt: 800 ],
		@"CONFIG", [ NSNumber numberWithInt: 700 ],
		@"FINE", [ NSNumber numberWithInt: 500 ],
		@"FINER", [ NSNumber numberWithInt: 400 ],
		@"FINEST", [ NSNumber numberWithInt: 300 ],		
		nil
	] retain ];
	
	[self 
		setKeys:[NSArray arrayWithObjects:@"timestamp", nil ]	
		triggerChangeNotificationsForDependentKey:@"date"
	];
	
}

+ (LogRecord*) parseServerEvent: (NSString*) string {
	int	type;
	if( [ string rangeOfString: @"PING:" ].location == 0 ) {
		return nil;
	} else if( [ string rangeOfString: @"STATE:" ].location == 0 ) {
		type = _STATE_EVENT_;
		string = [ string substringFromIndex: [ @"STATE:" length ]];
	}else if( [ string rangeOfString: @"LOG:" ].location == 0 ) {
		type = _LOG_EVENT_;
		string = [ string substringFromIndex: [ @"LOG:" length ]];
	}else if( [ string rangeOfString: @"UTIL:" ].location == 0 ) {
		type = _UTILIZATION_EVENT_;
		string = [ string substringFromIndex: [ @"UTIL:" length ]];
	} else if( [ string rangeOfString: @"PAY:" ].location == 0 ) {
		type = _FOR_PAY_EVENT_;
		string = [ string substringFromIndex: [ @"PAY:" length ]];
	} else {
//		NSLog( @"WARNING : Unknown event type %@\n", string );
		return nil;
	}
	
	NSArray* parts = [ string componentsSeparatedByString: @"|" ];
	
	LogRecord* result = [[ LogRecord alloc ] init ];
	[ result setType: type ];		
	
	[ result setTimestamp: [[ parts objectAtIndex: 0 ] doubleValue ]];
	[ result setSource: [ parts objectAtIndex: 1 ]];
	[ result setMessage: [ parts objectAtIndex: [ parts count ] - 1 ]]; // last
	
	switch( type ) {
		case _LOG_EVENT_ :
			[ result setLevel: [[ parts objectAtIndex: 2 ] intValue ]];
		break;
		case _STATE_EVENT_ :
			[ result setProfileState: [ parts objectAtIndex: 2 ]];
		break;
		case _UTILIZATION_EVENT_ :
			[ result setInBytes: [[ parts objectAtIndex: 2 ] intValue ]];
			[ result setOutBytes: [[ parts objectAtIndex: 3 ] intValue ]];
		break;
	}
	
	return result;
}

- (int) type {
	return _type;
}

- (void) setType: (int) v {
	_type = v;
}

- (BOOL) isStateEvent {
	return _type == _STATE_EVENT_;
}

- (BOOL) isLogEvent {
	return _type == _LOG_EVENT_;
}

- (BOOL) isUtilizationEvent {
	return _type == _UTILIZATION_EVENT_;
}


- (void) dealloc {
	[ _source release ];
	[ _message release ];
	[ _profileState release ];
	[ super dealloc ];
}

// Common accessors
- (NSTimeInterval) timestamp {
	return _timestamp;
}

- (void) setTimestamp: (NSTimeInterval) v {
	_timestamp = v;
}

- (NSString*) source {
	return _source;
}

- (void) setSource: (NSString*) v {
	v = [ v copy ];
	[ _source release ];
	_source = v;
}

- (NSString*) message {
	return _message;
}

- (void) setMessage: (NSString*) v {
	v = [ v copy ];
	[ _message release ];
	_message = v;
}

- (NSString*) logViewSource {
	if( _type == _LOG_EVENT_ ) {	
		NSArray* parts = [ _source componentsSeparatedByString: @"." ];
		return [ parts objectAtIndex: [ parts count ] - 1 ];
	} else if( _type == _STATE_EVENT_ ) {
		return [[ AlmostVPNObject findObjectWithUUID: [ self profileUuid ]] name ];
	} else {
		return _source;
	}
}

- (NSString*) logViewMessage {
	if( _type == _LOG_EVENT_ || _type == _STATE_EVENT_ || _type == _FOR_PAY_EVENT_ ) {	
		return _message;
	} else {
		return [ NSString stringWithFormat: @" incomming bytes : %d, outgoing bytes : %d", [ self inBytes ], [ self outBytes ]];
	}
}

-(NSString*) date {
	NSDate* date = [ NSDate dateWithTimeIntervalSince1970: _timestamp / 1000 ];
	return [ date descriptionWithCalendarFormat: @"%m/%d %H:%M:%S" timeZone: nil locale: nil ];
}

-(NSString*) state {
	if( _type == _LOG_EVENT_ ) {
		return [ _level_names_ objectForKey: [ NSNumber numberWithInt: _level ]];
	} else if( _type == _STATE_EVENT_ ) {
		return [ self profileState ];
	} else if( _type == _FOR_PAY_EVENT_ ) {
		return @"NOT FREE";
	} else {
		return @"utilization";
	}
}

-(id) stateColor {
	if( _type == _LOG_EVENT_ ) {
		if( _level == 1000 ) {
			return [ NSColor redColor ];
		} else if( _level >= 900 ) {
			return [ NSColor orangeColor ];
		} else {
			return [ NSColor grayColor ];
		}
	} else if( _type == _STATE_EVENT_ ) {
		return [ NSColor blackColor ];
	} else if( _type == _FOR_PAY_EVENT_ ) {
		return [ NSColor orangeColor ];
	} else {
		return [ NSColor blueColor];
	}
}

- (id) stateImportant {
	BOOL result = ( _type == _LOG_EVENT_ && _level >= 900 ) || ( _type == _STATE_EVENT_ && [ _profileState isEqual: @"fail" ] );
	return [ NSNumber numberWithBool: result ];
}

// Log event accessors
- (int) level {
	return _level;
}

- (void) setLevel: (int) v {
	_level = v;
}

// State event accessors
- (NSString*) profileUuid {
	return [ self source ];
}

- (void) setProfileUuid: (NSString*) v {
	[ self setSource: v ];
}

- (NSString*) profileState {
	return _profileState;
}

- (void) setProfileState:(NSString*) v {
	v = [ v copy ];
	[ _profileState release ];
	_profileState = v;
}

- (NSString*) profileStateComment {
	return [ self message ];
}

- (void) setProfileStateComment: (NSString*) v {
	[ self setMessage: v ];
}

- (NSString*) profileStateColor {
	if( _type == _FOR_PAY_EVENT_ ) {
		return @"dollar.png";
	}
	NSString* state = [ self profileState ];
	if( [ @"running" isEqual: state ] ) {
		return @"green.png";
	}
	if( [ @"fail" isEqual: state ] ) {
		return @"red.png";
	}
	if( [ @"starting" isEqual: state ] || [ @"stopping" isEqual: state ] ) {
		return @"yellow.png";
	}
	return nil;
}

// Utilization event
- (NSString*) locationUuid {
	return [ self source ];
}

- (void) setLocationUuid: (NSString*) v {
	[ self setSource: v ];
}

- (int) inBytes {
	return _inBytes;
}

- (void) setInBytes: (int) v {
	_inBytes = v;
}

- (int) outBytes {
	return _outBytes;
}

- (void) setOutBytes: (int) v {
	_outBytes = v;
}

@end
