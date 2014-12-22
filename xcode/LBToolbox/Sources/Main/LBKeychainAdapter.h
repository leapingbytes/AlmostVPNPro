//
//  KeyChainAdapter.h
//  AlmostVPN
//
//  Created by andrei tchijov on 9/1/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <CoreFoundation/CoreFoundation.h>
#include <Security/SecKeychain.h>
#include <Security/SecKeychainItem.h>
#include <Security/SecAccess.h>
#include <Security/SecTrustedApplication.h>
#include <Security/SecACL.h>
#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#import <CoreServices/CoreServices.h>


@interface LBKeychainAdapter : NSObject {
}
+ (NSString*)getKeychainPath;

+ (void)setKeychainPath:(NSString*)aPath;

+ (NSArray*) getTrustedApplications;
+ (void)setTrustedApplications: (NSArray*) trustedApplications;

+ (NSString*)askForPasswordForAccount:(NSString*)account onServer:(NSString*)serverName forPath:(NSString*)path;

+ (void)savePassword:(NSString*)password 
		      ofType:(SecProtocolType)type 
		  forAccount:(NSString*)account 
		    onServer:(NSString*)serverName 
			 forPath:(NSString*)path 
	    intoKeychain:(SecKeychainRef)keychain;
		
+ (NSString*)retrivePasswordOfType:(SecProtocolType)type 
						forAccount:(NSString*)account 
						  onServer:(NSString*)serverName 
						   forPath:(NSString*)path 
					  fromKeychain:(SecKeychainRef)keychain;

+ (void)forgetPasswordOfType:(SecProtocolType)type 
		          forAccount:(NSString*)account 
				    onServer:(NSString*)serverName 
				     forPath:(NSString*)path 
				fromKeychain:(SecKeychainRef)keychain;

+ (void)savePassword:(NSString*)password ofType:(SecProtocolType)type forAccount:(NSString*)account onServer:(NSString*)server forPath:(NSString*)path;

+ (NSString*)retrivePasswordOfType:(SecProtocolType)type forAccount:(NSString*)account onServer:(NSString*)server forPath:(NSString*)path;

+ (void)forgetPasswordOfType:(SecProtocolType)type forAccount:(NSString*)account onServer:(NSString*)server forPath:(NSString*)path;

+ (void)saveSSHPassword:(NSString*)password forAccount:(NSString*)account onServer:(NSString*)serverName;

+ (NSString*)retriveSSHPasswordForAccount:(NSString*)account onServer:(NSString*)serverName;

+ (void)forgetSSHPasswordForAccount:(NSString*)account onServer:(NSString*)serverName;
@end
