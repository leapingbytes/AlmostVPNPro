//
//  AlmostVPNPrinterRef.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 4/11/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNPrinterRef.h"

#define		_ADD_ON_START_KEY_	@"add-on-start"
#define		_USE_BONJOUR_KEY_	@"use-bonjour"
#define		_USE_CUPS_KEY_		@"use-cups"

@implementation AlmostVPNPrinterRef
- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ aDictionary objectForKey: _ADD_ON_START_KEY_ ] forKey: _ADD_ON_START_KEY_ ];	
	[ self setObject: [ aDictionary objectForKey: _USE_BONJOUR_KEY_ ] forKey: _USE_BONJOUR_KEY_ ];	
	[ self setObject: [ aDictionary objectForKey: _USE_CUPS_KEY_ ] forKey: _USE_CUPS_KEY_ ];	

	return self;
}

- (void) bootstrap {
	[ self setUseBonjour: [ NSNumber numberWithBool: YES ]];
	[ self setUseCUPS: [ NSNumber numberWithBool: YES ]];
}

- (id) addOnStart {
	return [ self booleanObjectForKey: _ADD_ON_START_KEY_ ];
}
- (void) setAddOnStart: (id) v {
	[ self setBooleanObject: v forKey: _ADD_ON_START_KEY_ ];
}

- (id) useBonjour {
	return [ self booleanObjectForKey: _USE_BONJOUR_KEY_ ];
}

- (void) setUseBonjour: (id) v {
	[ self setBooleanObject: v forKey: _USE_BONJOUR_KEY_ ];
}

- (id) useCUPS {
	return [ self booleanObjectForKey: _USE_CUPS_KEY_ ];
}

- (void) setUseCUPS: (id) v {
	[ self setBooleanObject: v forKey: _USE_CUPS_KEY_ ];
}
@end
