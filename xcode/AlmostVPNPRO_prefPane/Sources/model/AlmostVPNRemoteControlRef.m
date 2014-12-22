//
//  AlmostVPNRemoteControlRef.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/13/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNRemoteControlRef.h"


#define		_USE_BONJOUR_KEY_		@"use-bonjour"
#define		_START_TO_CONTROL_KEY_	@"start-to-control"
#define		_CONTROL_COMMAND_KEY_	@"control-command"

@implementation AlmostVPNRemoteControlRef

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ aDictionary objectForKey: _USE_BONJOUR_KEY_ ] forKey: _USE_BONJOUR_KEY_ ];	
	[ self setObject: [ aDictionary objectForKey: _START_TO_CONTROL_KEY_ ] forKey: _START_TO_CONTROL_KEY_ ];	
	[ self setObject: [ aDictionary objectForKey: _CONTROL_COMMAND_KEY_ ] forKey: _CONTROL_COMMAND_KEY_ ];	

	return self;
}

- (void) bootstrap {
	[ self setControlCommand: @"doRemoteControl.sh" ];
}

- (id) useBonjour {
	return [ self booleanObjectForKey: _USE_BONJOUR_KEY_ ];
}

- (void) setUseBonjour: (id) v {
	[ self setBooleanObject: v forKey: _USE_BONJOUR_KEY_ ];
}

- (id) startToControl {
	return [ self booleanObjectForKey: _START_TO_CONTROL_KEY_ ];
}

- (void) setStartToControl: (id) v {
	[ self setBooleanObject: v forKey: _START_TO_CONTROL_KEY_ ];
}

- (id) controlCommand {
	return [ self stringValueForKey: _CONTROL_COMMAND_KEY_ ];
}

- (void) setControlCommand: (id) v {
	[ self setStringValue: v forKey: _CONTROL_COMMAND_KEY_ ];
}

@end
