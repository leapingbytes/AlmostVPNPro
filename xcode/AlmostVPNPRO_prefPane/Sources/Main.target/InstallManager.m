//
//  InstallManager.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 9/7/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "LBToolbox/LBToolbox.h"

#import "InstallManager.h"
#import "PathLocator.h"
#import "ServerHelper.h"

#import "/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/xcode/AlmostVPNServer.starter/almostvpn_jar_md5.h"
#import "/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/xcode/AlmostVPNPRO_prefPane/authorization_helper_md5.h"

@interface InstallManager (private)
+(int) checkInstall;
+(NSString*) runInstallSh: (NSString*) command;
+(NSString*) runInstallSh: (NSString*) command withArgument: (NSString*) arg;
@end

@implementation InstallManager (private)
static NSFileManager* _fm = nil;

+ (void) initialize {
	NSLog( @"AVPN : InstallManager.initialize : START\n" );
	_fm = [ NSFileManager defaultManager ];

	NSLog( @"AVPN : InstallManager.initialize : NSFileManager = %x\n", _fm );

	AuthorizationHelper* ah = [ AuthorizationHelper sharedInstance ];

	NSLog( @"AVPN : InstallManager.initialize : AuthorizationHelper = %x\n", ah );
	
	[[ AuthorizationHelper sharedInstance ] registerDigest: @ALMOSTVPN_SERVER_MD5 forFile: @"AlmostVPNServer"  ];
	[[ AuthorizationHelper sharedInstance ] registerDigest: @UTILS_SH_MD5 forFile: @"utils.sh"  ];
	[[ AuthorizationHelper sharedInstance ] registerDigest: @INSTALL_SH_MD5 forFile: @"install.sh"  ];

	NSLog( @"AVPN : InstallManager.initialize : END\n" );
}

+(NSString*) runInstallSh: (NSString*) command {
	return [ self runInstallSh: command withArgument: nil ];
}

+(NSString*) runInstallSh: (NSString*) command withArgument: (NSString*) arg {
	AuthorizationHelper* ah = [ AuthorizationHelper sharedInstance ];
	
	[ ah setBundle: [ PathLocator prefPaneBundle ]];


	NSArray* taskArgs = [ NSArray arrayWithObjects: 
		command,
		NSUserName(),
		[ PathLocator resourcePath ],
		[ PathLocator applicationSupportPath ],
		[ PathLocator preferencesPath ],
		arg,
		nil
	];
	NSString* result = [ ah runScript: @"install.sh" withArgs: taskArgs asRoot: NO ];

	return result;
}
+ (int) checkInstall {
	NSString* result = [ self runInstallSh: @"check" ];
	NSArray* parts = [ result componentsSeparatedByString: @"|" ];
	if( [ parts count ] != 2 ) {	
		return -1;
	}
	
	return [[ parts objectAtIndex: 0 ] intValue ];
}
@end
@implementation InstallManager
+ (BOOL) checkLoginItem: (NSString*) path {
	NSString* result = [ self runInstallSh: @"checkLoginItem" withArgument: path ];
	return [ @"OK" isEqual: result ];
}

+ (BOOL) installLoginItem: (NSString*) path {
	[ InstallManager removeLoginItem: path ];
	
	NSString* result = [ self runInstallSh: @"installLoginItem" withArgument: path ];

	return [ @"OK" isEqual: result ];
}

+ (BOOL) removeLoginItem: (NSString*) path {
	NSString* result = [ self runInstallSh: @"uninstallLoginItem" withArgument: path ];

	return [ @"OK" isEqual: result ];
}

static id		_menuBarAppInstalled = nil;

+ (id) menuBarAppStartOnLogin {
	if( _menuBarAppInstalled == nil ) {
		BOOL v = [ self checkLoginItem: [ PathLocator pathForResource: @"AlmostVPNProMenuBar.app" ]];
		_menuBarAppInstalled = [[ NSNumber alloc ] initWithBool: v ];
	}
	return _menuBarAppInstalled;
}

+ (void) setMenuBarAppStartOnLogin: (id) v {
	v = [ v copy ];
	[ _menuBarAppInstalled release ];
	_menuBarAppInstalled = v;
	
	if( [ v boolValue ] ) {
		[ self installLoginItem: [ PathLocator pathForResource: @"AlmostVPNProMenuBar.app"  ]];
	} else {
		[ self removeLoginItem: [ PathLocator pathForResource: @"AlmostVPNProMenuBar.app"  ]];
	}
}

static id	_widgetInstalled = nil;

+ (id) widgetInstall {
	if( _widgetInstalled == nil ) {
		NSString* result = [ self runInstallSh: @"checkWidget" ];
		_widgetInstalled = [[ NSNumber alloc ] initWithBool: [ result isEqual: @"OK" ]]; 
	}
	return _widgetInstalled;
}

+ (void) setWidgetInstall: (id) v {
	v = [ v copy ];
	[ _widgetInstalled release ];
	_widgetInstalled = v;
	
	if( [ v boolValue ] ) {
		[ self runInstallSh: @"installWidget" ];
	} else {
		[ self runInstallSh: @"uninstallWidget" ];
	}
}

+ (void) ensureInstall {	
	[ self ensureServer ];
	[ self ensureFiles ];
	[ self ensureAgent ];
}

+ (void) ensureServer {
	AuthorizationHelper* ah = [ AuthorizationHelper sharedInstance ];
	
	[ ah setBundle: [ PathLocator prefPaneBundle ]];
	
	NSDictionary* result = [ ah 
		installSetUIDTool: @"AlmostVPNServer" 
		ofApplication: @"AlmostVPNPRO" 
		forUser: ( [ PathLocator prefPaneInstalledForAll ] ? @"root" : NSUserName()	)
	];
	NSString* installStatus = [ result objectForKey: @"status" ];
	
	if( [ @"prototype-tempered" isEqual: installStatus ] ) {
		NSRunCriticalAlertPanel( 
			@"Fatal Problem", 
			@"AlmostVPNServer has been tempered with\n"
			"Please re-download and re-install AlmostVPN\n"
			"If problem persists, contact support@leapingbytes.com\n"
			"Will exit now.", 
			@"OK", nil, nil 
		);
		exit(1);
	}
	
	NSString* almostVPNServerInstallPath = [[ result objectForKey: @"toolInstallPath" ] copy ];
	
	[ PathLocator setAlmostVPNServerInstallPath: almostVPNServerInstallPath ];
			
	if( ! [ @"good" isEqual: installStatus ] ) {	
		[ self installServerStartupItem ];

		if( [[ self menuBarAppStartOnLogin ] boolValue ] ) {
			[ self removeLoginItem: [ PathLocator pathForResource: @"AlmostVPNProMenuBar.app"  ]];		
			[ self installLoginItem: [ PathLocator pathForResource: @"AlmostVPNProMenuBar.app"  ]];		
		}
		
		if( [[ self widgetInstall ] boolValue ] ) {
			[ self runInstallSh: @"uninstallWidget" ];
			[ self runInstallSh: @"installWidget" ];
		}
	}	
}

+ (void) ensureFiles {
	AuthorizationHelper* ah = [ AuthorizationHelper sharedInstance ];

	BOOL restartServer = NO;

	NSString* plistPath = [ PathLocator preferencesPath ];
	NSString* oldPlistPath = [ @"~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist" stringByExpandingTildeInPath ];
	
	if( ! [ _fm fileExistsAtPath: plistPath ] ) {
		if( [ _fm fileExistsAtPath: oldPlistPath ] ) {
			[ ah moveFiles: [ NSArray arrayWithObject: oldPlistPath ] to: [ plistPath stringByDeletingLastPathComponent ] asRoot: YES ];
			[ ah changeFile: plistPath ownBy: NSUserName() withPermissions: @"744" ];
			restartServer = YES;
		}
	}
	
	NSString* sspPath = [ PathLocator sspPath ];
	NSString* oldSspPath = [ @"~/.almostVPN.ssp" stringByExpandingTildeInPath ];

	if( ! [ _fm fileExistsAtPath: sspPath ] ) {
		if( [ _fm fileExistsAtPath: oldSspPath ] ) {
			[ ah moveFiles: [ NSArray arrayWithObject: oldSspPath ] to: [ sspPath stringByDeletingLastPathComponent ] asRoot: YES ];
			[ ah changeFile: sspPath ownBy: @"root" withPermissions: @"700" ];
			restartServer = YES;
		}
	}
	
	if( restartServer ) {
		[ ServerHelper restartService ];
	}
}

+ (void) ensureAgent {
	if( ! [ self checkLoginItem: [ PathLocator pathForResource: @"AVPN.Agent.app" ]] ) {
		[ self installLoginItem: [ PathLocator pathForResource: @"AVPN.Agent.app" ]];
	}
}


+ (BOOL) checkServerStartupItem {
	AuthorizationHelper* ah = [ AuthorizationHelper sharedInstance ];
	
	NSString* result = 
		[ ah runCommand: @"[ -f /Library/StartupItems/AlmostVPN/AlmostVPN ] && [ -f /Library/StartupItems/AlmostVPN/AlmostVPN.env ] && echo -n \"OK\"" asRoot: YES ];

	return [ @"OK" isEqual: result ];
}

+ (void) controlServerStartupItem: (NSString*) command {
	NSString* avpnServerPath = [ NSString stringWithFormat: @"%@/AlmostVPNServer", [ PathLocator applicationSupportPath ]];
	if( [[ NSFileManager defaultManager ] fileExistsAtPath: avpnServerPath ] ) {
		[[ NSTask launchedTaskWithLaunchPath: avpnServerPath arguments: [ NSArray arrayWithObject: command ]] waitUntilExit ];
	}
}

+ (void) installServerStartupItem {
	AuthorizationHelper* ah = [ AuthorizationHelper sharedInstance ];
	
	[ self controlServerStartupItem: @"--stopService" ];
	
	[ ah deleteFile: @"/Library/StartupItems/AlmostVPN" ];
	[ ah createFolder: @"/Library/StartupItems/AlmostVPN" ownBy: nil withPermissions: nil ];
	[ ah copyFiles: [ NSArray arrayWithObjects: 
			[ NSString stringWithFormat: @"%@/Install/StartupItem/AlmostVPN", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/Install/StartupItem/StartupParameters.plist", [ PathLocator resourcePath ]], 
			nil
		]
		to: @"/Library/StartupItems/AlmostVPN"
		asRoot: YES
	];
	[ ah runCommands:
		[ NSArray arrayWithObjects:
			[ NSString stringWithFormat: @"echo \"declare AVPN_USER=\\\"%@\\\"\" >/tmp/AlmostVPN.env", NSUserName() ],
			[ NSString stringWithFormat: @"echo \"declare AVPN_RESOURCES=\\\"%@\\\"\" >>/tmp/AlmostVPN.env", [ PathLocator resourcePath ]],
			[ NSString stringWithFormat: @"echo \"declare AVPN_SUPPORT=\\\"%@\\\"\" >>/tmp/AlmostVPN.env", [ PathLocator applicationSupportPath ]],
			[ NSString stringWithFormat: @"echo \"declare AVPN_PREFERENCES=\\\"%@\\\"\" >>/tmp/AlmostVPN.env", [ PathLocator preferencesPath ]],
			[ NSString stringWithFormat: @"echo \"declare AVPN_SERVER_PATH=\\\"%@\\\"\" >>/tmp/AlmostVPN.env", [ PathLocator almostVPNServerInstallPath ]],
			nil
		]
		asRoot: NO
	];
	[ ah moveFiles: [ NSArray arrayWithObject: @"/tmp/AlmostVPN.env" ] to: @"/Library/StartupItems/AlmostVPN" asRoot: YES ];
	[ ah changeFile: @"/Library/StartupItems/AlmostVPN/AlmostVPN" ownBy: nil withPermissions: @"744" ];
	[ ah changeFile: @"/Library/StartupItems/AlmostVPN/AlmostVPN.env" ownBy: nil withPermissions: @"744" ];
	[ ah changeFile: @"/Library/StartupItems/AlmostVPN/StartupParameters.plist" ownBy: nil withPermissions: @"744" ];
	
	[ ah copyFiles: [ NSArray arrayWithObjects: 
			[ NSString stringWithFormat: @"%@/utils.sh", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/askPassword.sh", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/cleanup.sh", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/install.sh", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/doRemoteControl.sh", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/startTerminal.sh", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/AlmostVPNPRO_icon.png", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/AlmostVPN.jar", [ PathLocator resourcePath ]], 
//			[ NSString stringWithFormat: @"%@/libAlmostVPNToolJNI.macosx.jnilib", [ PathLocator resourcePath ]], 
			[ NSString stringWithFormat: @"%@/chickenpassword", [ PathLocator resourcePath ]], 
			
			nil
		]
		to: [ PathLocator applicationSupportPath ]
		asRoot: YES
	];
	
	[ ah createFile: [ NSString stringWithFormat: @"%@/amostvpn.log", [ PathLocator applicationSupportPath ]] ownBy: nil withPermissions: @"744" ];

	if( [ PathLocator almostVPNServerInstallPath ] ) {
		[ ah createFolder: [[ PathLocator preferencesPath ] stringByDeletingLastPathComponent ] ownBy: NSUserName() withPermissions: @"744" ];
	}
	
	[ self controlServerStartupItem: @"--startService" ];
}

+ (void) removeServerStartupItem {
	AuthorizationHelper* ah = [ AuthorizationHelper sharedInstance ];
	
	[ ah runCommands:
		[ NSArray arrayWithObjects:
			@"/sbin/SystemStarter stop AlmostVPN",
			@"/bin/rm -rf /Library/StartupItems/AlmostVPN",
			nil
		]
		asRoot: YES 
	];
}


@end
