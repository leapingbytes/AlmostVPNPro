//
//  FileRef.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 4/12/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNFileRef.h"

#define _DEST_LOCATION_KEY_		@"dst-location"
#define _DEST_PATH_KEY_			@"dst-path"

//#define _ON_START_OP_KEY_		@"on-start-op"
//#define _EXEC_ON_START_KEY_		@"exec-on-start"
//
//#define _ON_STOP_OP_KEY_		@"on-stop-op"
//#define _EXEC_ON_STOP_KEY_		@"exec-on-stop"

#define	_DO_AFTER_START_KEY_	@"do-after-start"
#define _DO_THIS_KEY_			@"do-this"
#define _AND_EXEC_KEY_			@"and-exec"

static NSString*	_keys_[] = {
	_DEST_LOCATION_KEY_,
	_DEST_PATH_KEY_,
	_DO_AFTER_START_KEY_,
	_DO_THIS_KEY_,
	_AND_EXEC_KEY_,
//	_ON_START_OP_KEY_,
//	_ON_STOP_OP_KEY_,
//	_EXEC_ON_START_KEY_,
//	_EXEC_ON_STOP_KEY_,
	nil
};

id	_FILE_COPY_OPERATION_;
id	_FILE_MOVE_OPERATION_;
id	_FILE_NOP_OPERATION_;

@implementation AlmostVPNFileRef
+ (void) initialize {
	_FILE_COPY_OPERATION_ = [ NSNumber numberWithInt: 0 ];
	_FILE_MOVE_OPERATION_ = [ NSNumber numberWithInt: 1 ];
	_FILE_NOP_OPERATION_ = [ NSNumber numberWithInt: 3 ];
	
	[self setKeys:[NSArray arrayWithObject:@"doThis"]	triggerChangeNotificationsForDependentKey:@"needDst"];
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self initKeys: _keys_ fromDictionary: aDictionary ];

	return self;
}

- (AlmostVPNLocation*) destinationLocation { 
	NSString* uuid = [ self stringValueForKey: _DEST_LOCATION_KEY_ ];
	AlmostVPNLocation* result = (AlmostVPNLocation*)[ AlmostVPNObject findObjectWithUUID: uuid ];
	return result;	
}

- (void) setDestinationLocation: (AlmostVPNLocation*) v {
	[ self setStringValue: [ v uuid ] forKey: _DEST_LOCATION_KEY_ ];
}

- (NSString*) destinationPath {
	return [ self stringValueForKey: _DEST_PATH_KEY_ ];
}
- (void) setDestinationPath: (NSString*) aPath {
//	BOOL needToRefresh = YES;
//	switch( [ aPath characterAtIndex: 0 ] ) {
//		case '/'  :
//		case '~'  :
//			needToRefresh = NO;
//			// Absolute Path do nothing
//			break;
//		case '.' :
//			aPath = [ NSString stringWithFormat: @"~/%@", [ aPath substringFromIndex: 1 ]];
//			break;
//		default:
//			aPath = [ NSString stringWithFormat: @"~/%@", aPath ];
//	}
	[ self setStringValue: aPath forKey: _DEST_PATH_KEY_ ];
//	if ( needToRefresh ) {
//		[ self performSelector: @selector( setDestinationPath: ) withObject: aPath afterDelay: 0 ];
//	}
}

- (id) doAfterStart {
	NSString* v = [ self stringValueForKey: _DO_AFTER_START_KEY_ ];
	return [ NSNumber numberWithInt: ( [ @"yes" isEqual: v ] ? 0 : 1 )];
}

- (void) setDoAfterStart: (id) v {
	[ self setStringValue: ( [v intValue ] == 0 ? @"yes" : @"no" ) forKey: _DO_AFTER_START_KEY_ ];
}

- (id) doThis {
	NSString* s = [ self stringValueForKey: _DO_THIS_KEY_ ];
	int n = 0;
	if( [ @"copy" isEqual: s ] ) n = 0;
	if( [ @"move" isEqual: s ] ) n = 1;
	if( [ @"nop" isEqual: s ] ) n = 3;
	
	return [ NSNumber numberWithInt: n ];	
}

- (void) setDoThis: (id) v {
	int n = [ v intValue ];
	NSString* s = @"copy";
	switch( n ) {
		case 0 : s = @"copy"; break;
		case 1 : s = @"move"; break;
		case 3 : s = @"nop"; break;
	}
	[ self setStringValue: s forKey: _DO_THIS_KEY_ ];
}

- (id) andExecute {
	return [ self booleanObjectForKey: _AND_EXEC_KEY_ ];
}

- (void) setAndExecute:(id) v {
	[ self setBooleanObject: v forKey: _AND_EXEC_KEY_ ];
}

- (id) needDst {
	if( [[ self doThis ] isEqual: _FILE_NOP_OPERATION_ ] ) {
		return [ NSNumber numberWithBool: NO ];
	} else {
		return [ NSNumber numberWithBool: YES ];
	}
}

//- (id) onStartOperation {
//	return [ self intObjectForKey: _ON_START_OP_KEY_ ];
//}
//
//- (void) setOnStartOperation: (id) v {
//	[ self setIntObject: v forKey: _ON_START_OP_KEY_ ];
//}
//
//- (id) executeOnStart {
//	return [ self booleanObjectForKey: _EXEC_ON_START_KEY_ ];
//}
//- (void) setExecuteOnStart: (id) v {
//	[ self setBooleanObject: v forKey: _EXEC_ON_START_KEY_ ];
//}
//
//- (id) onStopOperation {
//	return [ self intObjectForKey: _ON_STOP_OP_KEY_ ];
//}
//- (void) setOnStopOperation: (id) v {	
//	[ self setIntObject: v forKey: _ON_STOP_OP_KEY_ ];
//}
//
//- (id) executeOnStop {
//	return [ self booleanObjectForKey: _EXEC_ON_STOP_KEY_ ];
//}
//- (void) setExecuteOnStop: (id) v {	
//	[ self setBooleanObject: v forKey: _EXEC_ON_STOP_KEY_ ];
//}
//

@end
