//
//  AlmostVPNService.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNService.h"
//#import "AlmostVPNPROBSD/LBService.h"

#define _SERVICE_PORT_KEY_			@"port"
#define _SERVICE_PROTOCOLS_KEY_		@"protocols"

#define _SERVICE_TCP_PROTOCOL_		@"tcp"
#define _SERVICE_UDP_PROTOCOL_		@"udp"
#define _SERVICE_BOTH_PROTOCOL_		@"tcp+udp"

@implementation AlmostVPNService
static id<ServiceResolver> _resolver;
+(id<ServiceResolver>)resolver {
	return _resolver;
}

+(void) setResolver: (id<ServiceResolver>)v {
	_resolver = v;
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];
	
	[ self setObject: [ aDictionary objectForKey: _SERVICE_PORT_KEY_ ] forKey: _SERVICE_PORT_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _SERVICE_PROTOCOLS_KEY_ ] forKey: _SERVICE_PROTOCOLS_KEY_ ];
	
	[ AlmostVPNService performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (void) setName: (NSString*) name {
	[ super setName: name ];
	if( _resolver != nil ) {
		int port = [ _resolver serviceNameToPort: name ];
		if( port > 0 ) {
			[ self setPort: [ NSString stringWithFormat: @"%d", port ]];
		}
	}
}

- (NSString*) port {
	return [ self stringValueForKey: _SERVICE_PORT_KEY_ ];
}

- (void) setPort: (NSString*)value {
	[ self setStringValue: value  forKey: _SERVICE_PORT_KEY_ ];
	[ _resolver rememberServiceName: [ self name ] withPort: [[ self port ] intValue ]];
}

- (id) serviceProtocols {
	NSString* v = [ self stringValueForKey: _SERVICE_PROTOCOLS_KEY_ ];
	int n = 0;
	if( v == nil ) {
		[ self setStringValue: _SERVICE_TCP_PROTOCOL_ forKey: _SERVICE_PROTOCOLS_KEY_ ];		
	} else {
		if( [ v isEqual: _SERVICE_TCP_PROTOCOL_ ] ) n = 0;
		if( [ v isEqual: _SERVICE_UDP_PROTOCOL_ ] ) n = 1;
		if( [ v isEqual: _SERVICE_BOTH_PROTOCOL_ ] ) n = 2;
	}
	
	return [ NSNumber numberWithInt: n ];
}

- (void) setServiceProtocols: (id) n {
	NSString* v = _SERVICE_TCP_PROTOCOL_;
	switch ( [ n intValue ] ) {
		case 0 :  v = _SERVICE_TCP_PROTOCOL_; break;
		case 1 :  v = _SERVICE_UDP_PROTOCOL_; break;
		case 2 :  v = _SERVICE_BOTH_PROTOCOL_; break;
	}
	[ self setStringValue: v forKey: _SERVICE_PROTOCOLS_KEY_ ];
}

@end
