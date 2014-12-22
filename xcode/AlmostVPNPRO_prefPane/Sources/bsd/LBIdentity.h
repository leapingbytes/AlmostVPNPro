//
//  LBIdentity.h
//  AlmostVPNPRO_bsd
//
//  Created by andrei tchijov on 12/16/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LBIdentity : NSObject {
	NSString* _dotSshPath;
}
+(LBIdentity*) sharedInstance;

-(NSArray*) identityFiles;
-(NSArray*) identityFilesInFolder: (NSString*)path;

-(NSString*) pathToPublicKeyPath: (NSString*) path;
-(NSString*) pathToPrivateKeyPath: (NSString*) path;

-(NSDictionary*) newIdentityFile: (NSDictionary*) params;

-(BOOL) isPublicIdentityFile: (NSString*) path;

-(BOOL) isPrivateIdentityFile: (NSString*) path;
-(BOOL) isPrivateIdentityFile: (NSString*) path withPassphrase: (NSString*) passphrase;

-(NSDictionary*) queryIdentityFile: (NSString*)path;
-(NSDictionary*) queryIdentityFile: (NSString*)path withPassphrase: (NSString*) passphrase;

@end
