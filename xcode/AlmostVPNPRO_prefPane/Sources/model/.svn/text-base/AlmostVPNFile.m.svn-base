//
//  AlmostVPNFile.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 12/9/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNFile.h"

#define _PATH_KEY_				@"path"
#define _FILE_KIND_KEY_			@"kind"

#define _X11_KEY_				@"x11"
#define _CONSOLE_KEY_			@"console"

#define	_LIVE_LOG_KEY_			@"live-log"
#define _DEVICE_KEY_			@"device"
#define _WILDCARD_KEY_			@"wildcard"

static NSString*	_keys_[] = {
	_PATH_KEY_,
	_FILE_KIND_KEY_,
	_X11_KEY_,
	_CONSOLE_KEY_,
	_LIVE_LOG_KEY_,
	_DEVICE_KEY_,
	_WILDCARD_KEY_,
	nil
};

id _FILE_IS_FILE_;
id _FILE_IS_FOLDER_;
id _FILE_IS_SCRIPT_;

@implementation AlmostVPNFile
+ (void) initialize {
	_FILE_IS_FILE_ = [ NSNumber numberWithInt: 0 ];
	_FILE_IS_FOLDER_ = [ NSNumber numberWithInt: 1 ];
	_FILE_IS_SCRIPT_ = [ NSNumber numberWithInt: 2 ];
	
	[self setKeys:[NSArray arrayWithObject:@"fileKind"]	triggerChangeNotificationsForDependentKey:@"x11"];
	[self setKeys:[NSArray arrayWithObject:@"fileKind"]	triggerChangeNotificationsForDependentKey:@"isFile"];
	[self setKeys:[NSArray arrayWithObject:@"fileKind"]	triggerChangeNotificationsForDependentKey:@"isFolder"];
	[self setKeys:[NSArray arrayWithObject:@"fileKind"]	triggerChangeNotificationsForDependentKey:@"isScript"];
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self initKeys: _keys_ fromDictionary: aDictionary ];
	
	[ AlmostVPNFile performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (void) bootstrap {
	[ self setFileKind: _FILE_IS_FILE_ ];
}

- (NSString*) name {
	NSString* name;
	if([self hasDefaultName ]) {
		NSString* path = [ self path ];
		name = [ path lastPathComponent ];
	} else {
		name = [ super name ];
	}
	return name;
}

- (NSString*)path {
	return [ self stringValueForKey: _PATH_KEY_ ];
}
- (void) setPath: (NSString*) aPath {
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
	[ self setStringValue: aPath forKey: _PATH_KEY_ ];
//	if ( needToRefresh ) {
//		[ self performSelector: @selector( setPath: ) withObject: aPath afterDelay: 0 ];
//	}
}

- (id) isFile {
	return [ NSNumber numberWithBool: [[ self intObjectForKey: _FILE_KIND_KEY_ ] isEqual: _FILE_IS_FILE_ ]];
}

- (id) isFolder {
	return [ NSNumber numberWithBool: [[ self intObjectForKey: _FILE_KIND_KEY_ ] isEqual: _FILE_IS_FOLDER_ ]];
}

- (id) isScript {
	return [ NSNumber numberWithBool: [[ self intObjectForKey: _FILE_KIND_KEY_ ] isEqual: _FILE_IS_SCRIPT_ ]];
}

- (id) fileKind {
	return [ self intObjectForKey: _FILE_KIND_KEY_ ];
}

- (void) setFileKind: (id) v {
	[ self setIntObject: v forKey: _FILE_KIND_KEY_ ];
}

- (id) x11 {
	return [ self booleanObjectForKey: _X11_KEY_ ];
}
- (void) setX11: (id) aValue {
	[ self setBooleanObject: aValue forKey: _X11_KEY_ ];
}

- (id) console {
	return [ self booleanObjectForKey: _CONSOLE_KEY_ ];
}
- (void) setConsole: (id) aValue {
	[ self setBooleanObject: aValue forKey: _CONSOLE_KEY_ ];
}

- (id) liveLog {
	return [ self booleanObjectForKey: _LIVE_LOG_KEY_ ];
}
- (void) setLiveLog: (id) aValue {
	[ self setBooleanObject: aValue forKey: _LIVE_LOG_KEY_ ];
}

- (id) device {
	return [ self booleanObjectForKey: _DEVICE_KEY_ ];
}
- (void) setDevice: (id) aValue {
	[ self setBooleanObject: aValue forKey: _DEVICE_KEY_ ];
}

- (id) wildcard {
	return [ self booleanObjectForKey: _WILDCARD_KEY_ ];
}
- (void) setWildcard: (id) aValue {
	[ self setBooleanObject: aValue forKey: _WILDCARD_KEY_ ];
}
@end
