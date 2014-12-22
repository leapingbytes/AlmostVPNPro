//
//  AlmostVPNDrive.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 3/22/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNDrive.h"

#define _DRIVE_TYPE_KEY_		@"type"
#define _DRIVE_PATH_KEY_		@"path"
#define _DRIVE_ACCOUNT_KEY_		@"account"

#define _DRIVE_PORT_KEY_		@"port"

#define _AFP_DRIVE_TYPE_		@"AFP"
#define _SMB_DRIVE_TYPE_		@"SMB"
#define _NFS_DRIVE_TYPE_		@"NFS"
#define _DAV_DRIVE_TYPE_		@"HTTP"

#define	_DAV_PORT_NUMBER_		[ NSNumber numberWithInt: 80 ]
#define _SMB_PORT_NUMBER_		[ NSNumber numberWithInt: 139 ]
#define _AFP_PORT_NUMBER_		[ NSNumber numberWithInt: 548 ]

#define _UNKNOWN_PORT_NUMBER_	[ NSNumber numberWithInt: -1 ]


@implementation AlmostVPNDrive
+ (void) initialize {
	[self setKeys:[NSArray arrayWithObjects: @"driveType", @"drivePath", @"account", nil ] triggerChangeNotificationsForDependentKey:@"name" ];
	[self setKeys:[NSArray arrayWithObjects: @"driveType", nil ] triggerChangeNotificationsForDependentKey:@"drivePort" ];
}


static NSArray*	_driveTypes = nil;

- (NSArray*) driveTypes {
	if( _driveTypes == nil ) {
		_driveTypes = [[ NSArray arrayWithObjects:
			_AFP_DRIVE_TYPE_,
			_SMB_DRIVE_TYPE_,
//			_NFS_DRIVE_TYPE_,
			_DAV_DRIVE_TYPE_,
			nil
		] retain ];
	}
	
	return _driveTypes;
}

- (id) defaultDrivePort {
	id driveType = [ self driveType ];
	if( [ _AFP_DRIVE_TYPE_ isEqual: driveType ] ) {
		return _AFP_PORT_NUMBER_;
	}
	if( [ _SMB_DRIVE_TYPE_ isEqual: driveType ] ) {
		return _SMB_PORT_NUMBER_;
	}
	if( [ _DAV_DRIVE_TYPE_ isEqual: driveType ] ) {
		return _DAV_PORT_NUMBER_;
	}
	
	return _UNKNOWN_PORT_NUMBER_;
}


- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ AlmostVPNObject objectWithDictionary: [ aDictionary objectForKey: _DRIVE_ACCOUNT_KEY_ ]] forKey: _DRIVE_ACCOUNT_KEY_ ];
	
	[[ self account ] setOwner: self ];
	
	[ self setObject: [ aDictionary objectForKey: _DRIVE_TYPE_KEY_ ] forKey: _DRIVE_TYPE_KEY_ ];	
	[ self setObject: [ aDictionary objectForKey: _DRIVE_PATH_KEY_ ] forKey: _DRIVE_PATH_KEY_ ];	
	[ self setObject: [ aDictionary objectForKey: _DRIVE_PORT_KEY_ ] forKey: _DRIVE_PORT_KEY_ ];	
	

	return self;
}

- (NSString*) name {
	return 
		[ NSString stringWithFormat: 
			@"%@://%@/%@",
			[[ self driveType ] lowercaseString ],
			[[ self parent ] name ],
			[ self drivePath ]
		];
}

- (id) drivePort {
	return [ self intObjectForKey: _DRIVE_PORT_KEY_ ];
}

- (void) setDrivePort: (id) v {
	[ self setIntObject: v forKey: _DRIVE_PORT_KEY_ ];
}

- (NSString*) driveType {
	return [ self stringValueForKey: _DRIVE_TYPE_KEY_ ];
}

- (void) setDriveType: (NSString*) v {
	[ self setStringValue: v forKey: _DRIVE_TYPE_KEY_ ];
	[ self setDrivePort: [ self defaultDrivePort ]];
}

- (NSString*) drivePath {
	return [ self stringValueForKey: _DRIVE_PATH_KEY_ ];
}

- (void) setDrivePath: (NSString*) v {
	[ self setStringValue: v forKey: _DRIVE_PATH_KEY_ ];
}

- (AlmostVPNAccount*) account {
	return [ self objectForKey: _DRIVE_ACCOUNT_KEY_ ];
}

- (void) setAccount: (AlmostVPNAccount*) v {
	[ self setObject: v forKey: _DRIVE_ACCOUNT_KEY_ ];
	[ v setOwner: self ];
}


- (void) bootstrap {
	[ super bootstrap ];
	AlmostVPNAccount* account = [[ AlmostVPNAccount alloc ] init ];
	[ self setAccount: account ];
	[ account setUserName: NSUserName() ];
	[ account release ];
	
	[ self setDriveType: _AFP_DRIVE_TYPE_ ];
	[ self setDrivePort: _AFP_PORT_NUMBER_ ];
	[ self setDrivePath: NSUserName() ];
}

@end
