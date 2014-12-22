//
//  AlmostVPNProfile.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/7/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNProfile.h"
#import "AlmostVPNObjectRef.h"
#import "AlmostVPNService.h"
#import "AlmostVPNHost.h"
#import "AlmostVPNTunnel.h"
#import "AlmostVPNHostAlias.h"
#import "AlmostVPNLocalhost.h"
#import "AlmostVPNDrive.h"
#import "AlmostVPNDriveRef.h"
#import "AlmostVPNPrinter.h"
#import "AlmostVPNPrinterRef.h"
#import "AlmostVPNFile.h"
#import "AlmostVPNFileRef.h"
#import "AlmostVPNBonjour.h"
#import "AlmostVPNBonjourRef.h"

#import "PathLocator.h"

#define boolAttribute( getter, setter, key ) \
-(id) getter { \
	return [ self booleanObjectForKey: key ];\
}\
-(void) setter: (id) v {\
	[ self setBooleanObject: v forKey: key ];\
}

#define enumAttribute( getter, setter, key ) \
-(id) getter { \
	return [ self intObjectForKey: key ]; \
}\
-(void) setter: (id) v {\
	[ self setIntObject: v forKey: key ]; \
}

#define stringAttribute( getter, setter, key ) \
-(id) getter { \
	return [ self objectForKey: key ]; \
}\
-(void) setter: (id) v {\
	[ self setObject: v forKey: key ]; \
}

#define _RESTART_ON_ERROR_KEY_	@"restart-on-error"
#define _FIRE_AND_FORGET_KEY_	@"fire-and-forget"
#define _STOP_ON_FUS_KEY_		@"stop-on-fus"
#define _RUN_MODE_KEY_			@"run-mode"
//#define _START_AT_KEY_			@"start-at"
//#define _STOP_AT_KEY_			@"stop-at"
#define _DISABLED_KEY_			@"disabled"

static NSString*	_keys_[] = {
	_FIRE_AND_FORGET_KEY_,
	_STOP_ON_FUS_KEY_,
	_RUN_MODE_KEY_,
	_RESTART_ON_ERROR_KEY_,
//	_START_AT_KEY_,
//	_STOP_AT_KEY_,
	_DISABLED_KEY_,
	nil
};


id	_RUN_MANUALLY_;
id	_RUN_AT_BOOT_;
id	_RUN_AT_LOGIN_;
id	_RUN_AT_START_;

@implementation AlmostVPNProfile
+(void) initialize {
	_RUN_MANUALLY_ = [ NSNumber numberWithInt: 0 ];
	_RUN_AT_BOOT_ = [ NSNumber numberWithInt: 1 ];
	_RUN_AT_LOGIN_ = [ NSNumber numberWithInt: 2 ];
	_RUN_AT_START_ = [ NSNumber numberWithInt: 3 ];
	
//	[self 
//		setKeys:[NSArray arrayWithObject:@"runMode" ]	
//		triggerChangeNotificationsForDependentKey:@"isTimeBased"
//	];
//
}

- (void) bootstrap {
	[ self setRunMode: _RUN_MANUALLY_ ];
	[ self setRestartOnError: [ NSNumber numberWithBool: YES ]];
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self initKeys: _keys_ fromDictionary: aDictionary ];
	
	[ AlmostVPNProfile performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

boolAttribute( restartOnError, setRestartOnError, _RESTART_ON_ERROR_KEY_ );
boolAttribute( fireAndForget, setFireAndForget, _FIRE_AND_FORGET_KEY_ );
boolAttribute( stopOnFUS, setStopOnFUS, _STOP_ON_FUS_KEY_ );

enumAttribute( runMode, setRunMode, _RUN_MODE_KEY_ );

//stringAttribute( startAt, setStartAt, _START_AT_KEY_ );
//stringAttribute( stopAt, setStopAt, _STOP_AT_KEY_ );

boolAttribute( disabled, setDisabled, _DISABLED_KEY_ );

- (int) countResources {
	return [[ self resources ] count ];
}

- (NSArray*) resources {
	return [ self childrenKindOfClass: [ AlmostVPNObjectRef class ]];
}

- (BOOL) containsResource: (AlmostVPNResource*) aResource {
	NSArray* resources = [ self resources ];
	for( int i = 0; i < [ resources count ]; i++ ) {
		AlmostVPNObjectRef* resourceRef = [ resources objectAtIndex: i ];
		if( [ aResource isEqual: [ resourceRef referencedObject ]] ) {
			return YES;
		}
	}
	return NO;
}

- (void) addResource: (AlmostVPNResource*) aResource {
	AlmostVPNObjectRef* reference = [ AlmostVPNObjectRef referenceWithObject: aResource ];
	[ self addChild: reference ];
}

- (void) removeResource: (AlmostVPNResource*) aResource {
	NSArray* resources = [ self resources ];
	for( int i = 0; i < [ resources count ]; i++ ) {
		AlmostVPNObjectRef* resourceRef = [ resources objectAtIndex: i ];
		if( [ aResource isEqual: [ resourceRef referencedObject ]] ) {
			[ self removeChild: [ resourceRef referencedObject ]];
			break;
		}
	}
}

- (BOOL) canHaveChild: (NSString*) childKind {
	return	[ @"Host" isEqual: childKind ] || 
			[ @"Location" isEqual: childKind ] || 
			[ @"Service" isEqual: childKind ] || 
			[ @"Drive" isEqual: childKind ] || 
			[ @"File" isEqual: childKind ]  || 
			[ @"Bonjour" isEqual: childKind ] ||
			[ @"RemoteControl" isEqual: childKind ] ||
			[ @"Printer" isEqual: childKind ]
	;
}

- (AlmostVPNViewable*) addChild: (AlmostVPNViewable*) child {
	AlmostVPNViewable* objectToAdd = child;
	if( [ child isKindOfClass: [ AlmostVPNService class ]] ) {
		objectToAdd = [[ AlmostVPNTunnel alloc ] initWithObject: child ];
		[ (AlmostVPNTunnel*)objectToAdd setSourcePort: [ (AlmostVPNService*)child port ]];
		[ (AlmostVPNTunnel*)objectToAdd setSourceLocation: [ AlmostVPNLocalhost  sharedInstance ]];		
	} else if( [ child isKindOfClass: [ AlmostVPNHost class ]] ) {
		objectToAdd = [[ AlmostVPNHostAlias alloc ] initWithObject: child ];
		[ (AlmostVPNHostAlias*)objectToAdd setAliasName: [ AlmostVPNHostAlias aliasNameFromRealName: [ (AlmostVPNHost*)child name ]]];
		[ (AlmostVPNHostAlias*)objectToAdd setAliasAddress: @"<auto>" ];		
	} else if( [ child isKindOfClass: [ AlmostVPNDrive class ]] ) {
		objectToAdd = [[ AlmostVPNDriveRef alloc ] initWithObject: child ];
		if( [[ (AlmostVPNDrive*)child drivePath ] length ] != 0 ) {
			[ (AlmostVPNDriveRef*)objectToAdd setMountOnStart: [ NSNumber numberWithBool: YES ]];
			[ (AlmostVPNDriveRef*)objectToAdd setUseBonjour: [ NSNumber numberWithBool: NO ]];
		} else {
			[ (AlmostVPNDriveRef*)objectToAdd setMountOnStart: [ NSNumber numberWithBool: NO ]];
			[ (AlmostVPNDriveRef*)objectToAdd setUseBonjour: [ NSNumber numberWithBool: YES ]];
		}
	} else if( [ child isKindOfClass: [ AlmostVPNPrinter class ]] ) {
		objectToAdd = [[ AlmostVPNPrinterRef alloc ] initWithObject: child ];
		[ (AlmostVPNPrinterRef*)objectToAdd setAddOnStart: [ NSNumber numberWithBool: NO ]];
		[ (AlmostVPNPrinterRef*)objectToAdd setUseBonjour: [ NSNumber numberWithBool: YES ]];
	} else if( [ child isKindOfClass: [ AlmostVPNFile class ]] ) {
		objectToAdd = [[ AlmostVPNFileRef alloc ] initWithObject: child ];
		[ (AlmostVPNFileRef*)objectToAdd setDestinationLocation: [ AlmostVPNLocalhost  sharedInstance ]];		
		[ (AlmostVPNFileRef*)objectToAdd setDestinationPath: [ (AlmostVPNFile*) child path ]];
		[ (AlmostVPNFileRef*)objectToAdd setDoAfterStart: [ NSNumber numberWithBool: YES ]];
		[ (AlmostVPNFileRef*)objectToAdd setDoThis: _FILE_COPY_OPERATION_ ];
	} else if( [ child isKindOfClass: [ AlmostVPNBonjour class ]] ) {
		objectToAdd = [[ AlmostVPNBonjourRef alloc ] initWithObject: child ];
		[ (AlmostVPNBonjourRef*)objectToAdd setName: [ child name ]];
		[ (AlmostVPNBonjourRef*)objectToAdd setLocalPort: [ (AlmostVPNBonjour*)child port ]];
	} else if( [ child isKindOfClass: [ AlmostVPNRemoteControl class ]] ) {
		objectToAdd = [[ AlmostVPNRemoteControlRef alloc ] initWithObject: child ];
		[ (AlmostVPNBonjourRef*)objectToAdd setName: [ child name ]];
	}
	return [ super addChild: objectToAdd ];
}


- (NSString*) state {
	return [ self objectForKey: @"state" ];
}

- (void) setState: (NSString*) v {
	[ self willChangeValueForKey: @"stateColor" ];
	if( v == nil ) {
		[ self removeObjectForKey: @"state" ];
	} else {
		[ self setObject: v forKey: @"state" ];
	}
	[ self didChangeValueForKey: @"stateColor" ];
}

- (NSString*) stateComment {
	return [ self objectForKey: @"state-comment" ];
}

- (void) setStateComment: (NSString*)v {
	[ self setObject: v forKey: @"state-comment" ];
}

- (NSString*) stateColor {
	NSString* state = [ self state ];
	if( [ @"running" isEqual: state ] ) {
		return @"green.png";
	}
	if( [ @"suspended" isEqual: state ] ) {
		return @"grey.png";
	}
	if( [ @"fail" isEqual: state ] ) {
		return @"red.png";
	}
	if( [ @"paused" isEqual: state ] ) {
		return @"grey.png";
	}
	if( [ @"starting" isEqual: state ] || [ @"stopping" isEqual: state ] ) {
		return @"yellow.png";
	}
	return @"blank.png";
}

@end
