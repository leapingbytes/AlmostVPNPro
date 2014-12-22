//
//  PathLocator.h
//  AlmostVPN
//
//  Created by andrei tchijov on 9/2/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AVPN.h" 

#define PathLocator avpnClass( PathLocator )

@interface PathLocator : NSObject {
}
+ (void) guessInstall;

+ (void) setPrefPaneBundle: (NSBundle*) bundle;
+ (NSBundle*) prefPaneBundle;

+ (NSString*) prefPaneInstallPath;

+ (BOOL) prefPaneInstalledForAll;

+ (void) setAlmostVPNServerInstallPath: (NSString*) v;
+ (NSString*) almostVPNServerInstallPath;

+ (NSString*) applicationSupportPath;
+ (NSString*) applicationSupportPathForFile: (NSString*) file;

+ (NSString*) resourcePath;
+ (NSString*) pathForResource: (NSString*) resource;
+ (NSString*) pathForResource: (NSString*) resource ofType: (NSString*) extension;

+ (NSImage*) imageNamed: (NSString*) imageName;
+ (NSImage*) imageNamed: (NSString*) imageName ofSize: (NSSize) size;

+ (NSImage*) imageNamed: (NSString*) imageName fromBundle: (NSBundle*) bundle;
+ (NSImage*) imageNamed: (NSString*) imageName ofSize: (NSSize) size fromBundle: (NSBundle*) bundle;

+ (NSSound*) soundNamed: (NSString*) soundName;

+ (NSString*) preferencesPath;

+ (NSString*) home;
+ (NSString*) version;
+ (NSString*) shortVersion;


+ (NSString*) sspPath;
//
// User specific pathes
//
+ (NSString*) preferencesPath: (NSString*) applicationId;
+ (NSString*) userKeychainPath: (NSString*)keychainName;

+ (NSString*) keychainPath;

// ======================================================

//+(NSString*) bundleIdentifier;
//+(void) setBundleIdentifier: (NSString*) value ;
//
//
//
//+(NSBundle*)prefPaneBundle;
//+(void)setPrefPaneBundle: (NSBundle*) bundle;
//
//+ (NSString*) prefPaneInstallPath;
//+(BOOL) prefPaneInstalledForAll;
//
//
//
//+(NSBundle*)almostVPNBundle;
//
//
//+(NSString*)home;
//+(NSString*)version;
//+(NSString*)preferencesPath;
//+(NSString*)preferencesPath: (NSString*) applicationId;
//
//+ (NSString*) almostVPNServerPath;
//+ (void) setAlmostVPNServerPath: (NSString*)v;
//
//+(NSString*)applicationSupportPathForFile: (NSString*) file;
//+(NSString*)launchdPlistPathForProfile: (NSString*) profile;
//+(NSString*)resourcePath;
//+(NSString*)installedResourcePath;
//+(NSString*)pathForResource: (NSString*) resource;
//+(NSString*)pathForInstalledResource: (NSString*) resource;
//+(NSString*)userKeychainPath: (NSString*)keychainName;
//
//+(NSString*) pathForExecutable: ( NSString* )v;
//
//+ (NSImage*) imageNamed: (NSString*) imageName;
//+ (NSImage*) imageNamed: (NSString*) imageName ofSize: (NSSize) size;
//+ (NSSound*) soundNamed: (NSString*) soundName;
//
//+(NSString*) keychainPath;
@end
