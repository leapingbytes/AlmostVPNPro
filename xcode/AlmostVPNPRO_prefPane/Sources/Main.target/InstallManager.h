//
//  InstallManager.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 9/7/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AVPN.h"

#define InstallManager avpnClass( InstallManager )

@interface InstallManager : NSObject {
}
+ (void) ensureInstall;
+ (void) ensureFiles;	// Making sure that *.plist and *.ssp files are where they should be
+ (void) ensureServer;	// Making sure that AlmostVPNServer and StartupItem installed properly
+ (void) ensureAgent;	// Making sure that AVPN.Agent is installed and running

+ (BOOL) checkServerStartupItem;
+ (void) installServerStartupItem;
+ (void) removeServerStartupItem;

+ (BOOL) checkLoginItem: (NSString*) path;
+ (BOOL) installLoginItem: (NSString*) path;
+ (BOOL) removeLoginItem: (NSString*) path;

+ (id) widgetInstall;
+ (void) setWidgetInstall: (id) v;

+ (id) menuBarAppStartOnLogin;
+ (void) setMenuBarAppStartOnLogin: (id) v;

@end
