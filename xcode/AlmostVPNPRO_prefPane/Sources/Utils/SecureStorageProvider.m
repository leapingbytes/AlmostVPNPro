//
//  SecureStorageProvider.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 3/23/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "SecureStorageProvider.h"
#import "ServerHelper.h"
#import "AlmostVPNObject.h"

#define	_SSP_VALUE_				@"<SSP-VALUE>"
@implementation SecureStorageProvider

+ (NSString*) keyForObject: (AlmostVPNObject*) anObject andKey: (NSString*) aKey {
	return [ NSString stringWithFormat: @"%@:%@", [ anObject uuid ], aKey ];
}

- (void) saveSecureObject:(id) secretObject withKey:(id) aKey ofObject:(AlmostVPNObject*) anObject {
	if( [ _SSP_VALUE_ isEqual: secretObject ] ) {
		return;
	} else if( secretObject == nil ) {
		NSString* fullKey = [ SecureStorageProvider keyForObject: anObject andKey: aKey ];
		[ ServerHelper forgetSecretWithKey: fullKey ];
	} else {
		NSString* fullKey = [ SecureStorageProvider keyForObject: anObject andKey: aKey ];
		[ ServerHelper saveSecret: [ secretObject description ] withKey: fullKey ];
	}
}

- (id) retriveSecureObjectWithKey: (id) aKey ofObject:(AlmostVPNObject*) anObject {
	if( [ ServerHelper checkSecretWithKey: [ SecureStorageProvider keyForObject: anObject andKey: aKey ] ] ) {
		return _SSP_VALUE_;
	} else {
		return @"";
	}
}

@end
