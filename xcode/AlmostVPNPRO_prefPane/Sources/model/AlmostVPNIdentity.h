//
//  AlmostVPNIdentity.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/14/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum { FILE_MEDIA, KEYCHAIN_MEDIA } IdentityMedia;

#import "AlmostVPNViewable.h"

/*!
	@class AlmostVPNIdentity
	@abstract An AlmostVPNIdentity object describes "ssh identity" (pair of private/public keys used to authenticate ssh client)
	
*/
@interface AlmostVPNIdentity : AlmostVPNViewable {
}
/*!
	@method media
	@abstract Returns string indicating in which form (flat file or secure note in keychain) this particular identity object exists.
	@discussion Presently idenity object can exist in one of two forms:
	- flat file,
	- secure not in the AlmostVPN.keychain	
	@result NSNumber with FILE_MEDIA or KEYCHAIN_MEDIA as a value
*/
-(id)media;
/*!
	@method setMedia:
	@abstract Sets value for "media" attribute
	@param NSNumber with FILE_MEDIA or KEYCHAIN_MEDIA as a value
	@discussion any value other then @"file" or @"keychain" will be ignored 
*/
-(void) setMedia: (id) media;

/*!
	@method path
	@abstract Returns string which could be used to locate the object
	@discussion Depending on the value of "media" attribute this string could represent either file path or secure note name.
	@result Path to identity object
*/
- (NSString*)path;
/*!
	@method setPath:
	@abstract Sets path to the identity object.
	@param new value for "path" attribute
*/
- (void) setPath: (NSString*)value;

/*!
	@method passphrase
	@abstract If identity object protected by passphrase, then it will return it. Returns nil otherwise;
	@resilt Passphrase or nil
*/
- (NSString*)passphrase;
/*!
	@method setPassphrase:
	@abstract Sets value for "passphrase" attribute.
	@param New passphrase or nil if there is no passphrase
*/
- (void)setPassphrase: (NSString*) value;

- (id) usePassphrase;
- (void) setUsePassphrase: (id) value;

- (id) isDefaultIdentity;
- (void) setIsDefaultIdentity: (id) v;

-(NSString*) type;
-(void) setType: (NSString*)v;

-(NSString*) bits;
-(void) setBits: (NSString*) v;

-(NSString*) fingerprint;
-(void) setFingerprint: (NSString*) v;

-(NSString*) digest;
-(void) setDigest: (NSString*) v;
@end
