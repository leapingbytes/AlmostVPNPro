//
//  PathLocator.m
//  AlmostVPN
//
//  Created by andrei tchijov on 9/2/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//
#include <unistd.h>
#include <sys/param.h>

#include <Security/Security.h>

#import "PathLocator.h"

@implementation PathLocator
// ============================================================================
// Axioms
//
// ============================================================================
// 1) _prefPaneBundle
//		-> _prefPaneInstallPath
//		-> _prefPaneInstalledForAll
static NSBundle*	_prefPaneBundle = nil;
static NSString*	_prefPaneInstallPath = nil;
static BOOL			_prefPaneInstalledForAll = NO;

+ (void) setPrefPaneBundle: (NSBundle*) bundle {
	if( [ bundle isEqual: _prefPaneBundle ] ) {
		return;
	}
	
	if( _prefPaneBundle != nil ) {
		NSLog( @"AlmostVPNPRO.setPrefPaneBundle:WARNING: _prefPaneBundle is not nil!!!\n" );
	}
	
	_prefPaneBundle = bundle;
	
	_prefPaneInstallPath = [[ _prefPaneBundle bundlePath ] copy ];
	_prefPaneInstalledForAll = [ _prefPaneInstallPath rangeOfString: @"/Library" ].location == 0;
}

+(NSBundle*) prefPaneBundle {
	return _prefPaneBundle;
}

+ (NSString*) prefPaneInstallPath {
	return _prefPaneInstallPath;
}

+ (BOOL) prefPaneInstalledForAll {
	return _prefPaneInstalledForAll;
}
// ============================================================================
// 2) _almostVPNServerInstallPath
//		-> _applicationSupportPath
//		
static NSString*	_almostVPNServerInstallPath = nil;
static NSString*	_applicationSupportPath = nil;
static BOOL			_almostVPNServerInstalledForAll = NO;

+ (void) setAlmostVPNServerInstallPath: (NSString*) v {
	if( [ v isEqual: _almostVPNServerInstallPath ] ) {
		return;
	}
	
	if( _almostVPNServerInstallPath != nil ) {
		NSLog( @"AlmostVPNPRO.setAlmostVPNServerInstallPath:WARNING: _almostVPNServerInstallPath is not nil!!!\n" );
	}

	v = [ v copy ];
	[ _almostVPNServerInstallPath release ];
	_almostVPNServerInstallPath = v;
	
	_applicationSupportPath = [[ _almostVPNServerInstallPath stringByDeletingLastPathComponent ] copy ];
	_almostVPNServerInstalledForAll = [ _almostVPNServerInstallPath rangeOfString: @"/Library" ].location == 0;

	NSLog( @"AlmostVPNPRO.setAlmostVPNServerInstallPath:  _almostVPNServerInstallPath is %@\n", _almostVPNServerInstallPath );
	if( _almostVPNServerInstalledForAll ) {
		NSLog( @"AlmostVPNPRO.setAlmostVPNServerInstallPath:  _almostVPNServerInstalledForAll is YES\n" );
	}
}

+ (NSString*) almostVPNServerInstallPath {	
	return _almostVPNServerInstallPath;
}

+ (NSString*) applicationSupportPath {
	return _applicationSupportPath;
}
//
// ============================================================================
//
+ (void) guessInstall {
	if( _prefPaneBundle == nil ) {
		NSBundle* guess = [ NSBundle bundleWithPath: [ @"~/Library/PreferencePanes/AlmostVPNPRO.prefPane"  stringByExpandingTildeInPath ]];
		guess = guess != nil ? guess : [ NSBundle bundleWithPath: @"/Library/PreferencePanes/AlmostVPNPRO.prefPane" ];

		if( guess == nil ) {
			NSLog( @"AlmostVPNPRO.guessInstall : ERROR : Fail to guess _prefPaneBundle\n" );
		} else {
			NSLog( @"AlmostVPNPRO.guessInstall _prefPaneBundle = %@\n", guess );
			[ self setPrefPaneBundle: guess ];
		}
	}
	if( _almostVPNServerInstallPath == nil ) {
		NSFileManager* fm = [ NSFileManager defaultManager ];
		
		NSString* guess = [ @"~/Library/Application Support/AlmostVPNPRO/AlmostVPNServer" stringByExpandingTildeInPath ];
		guess = [ fm fileExistsAtPath: guess ] ? guess : @"/Library/Application Support/AlmostVPNPRO/AlmostVPNServer";
		
		if( guess == nil ) {
			NSLog( @"AlmostVPNPRO.guessInstall : ERROR : Fail to guess _almostVPNServerInstallPath\n" );
		} else {
			NSLog( @"AlmostVPNPRO.guessInstall _almostVPNServerInstallPath = %@\n", guess );
			[ self setAlmostVPNServerInstallPath: guess ];
		}
	}
}

//
// ============================================================================
//
+ (NSString*) applicationSupportPathForFile: (NSString*) file {
	return [ _applicationSupportPath stringByAppendingPathComponent: file ];
}

+ (NSString*) resourcePath {
	return [ _prefPaneBundle resourcePath ];
}

+ (NSString*) pathForResource: (NSString*) resource {
	return [ self pathForResource: resource ofType: nil ];
}

+ (NSString*) pathForResource: (NSString*) resource ofType: (NSString*) extension {
	return [ _prefPaneBundle pathForResource: resource ofType: extension ];
}

+(NSImage*)imageNamed: (NSString*) imageName {
	return [ self imageNamed: imageName fromBundle: _prefPaneBundle ];
}

+(NSImage*)imageNamed: (NSString*) imageName fromBundle: (NSBundle*) bundle {
	NSString* imagePath = [ bundle pathForImageResource: imageName ];
	
	return [[[ NSImage alloc ] initByReferencingFile: imagePath ] autorelease ];
}

+(NSImage*)imageNamed: (NSString*) imageName ofSize: (NSSize) size {
	return [ self imageNamed: imageName ofSize: size fromBundle: _prefPaneBundle ];
}

+(NSImage*)imageNamed: (NSString*) imageName ofSize: (NSSize) size fromBundle: (NSBundle*) bundle {
	NSString* imagePath = [ bundle pathForImageResource: imageName ];
	NSImage* result = [[[ NSImage alloc ] initByReferencingFile: imagePath ] autorelease ];
	[ result setScalesWhenResized: YES ];
	[ result setSize: size ];
	return result;
}

+(NSSound*) soundNamed: (NSString*) soundName {
	NSString* soundPath = [ _prefPaneBundle pathForResource: soundName ofType:@"mov"];
	if( soundPath == nil ) {
		return [ NSSound soundNamed: soundName ];
	} else {
		return [[[NSSound alloc] initWithContentsOfFile: soundPath byReference: YES ] autorelease ];
	}
}

static NSString* _preferencesPath = nil;
+ (NSString*) preferencesPath {
	if( _preferencesPath == nil ) {
		if( _almostVPNServerInstalledForAll ) {
			_preferencesPath = [ NSString stringWithFormat: @"/Library/Preferences/AlmostVPNPRO/%@/com.leapingbytes.AlmostVPNPRO.plist", NSUserName() ];
		} else {
			_preferencesPath = [ @"~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist" stringByExpandingTildeInPath ];
		}
		_preferencesPath = [ _preferencesPath copy ];
	}
	return _preferencesPath;
}

static NSString* _sspPath = nil;
+ (NSString*) sspPath {
	if( _sspPath == nil ) {
		if( _almostVPNServerInstalledForAll ) {
			_sspPath = @"/.almostVPN.ssp";
		} else {
			_sspPath = [[ @"~/.almostVPN.ssp" stringByExpandingTildeInPath ] copy ];
		}
	}
	return _sspPath;
}

static NSString* _home = nil;
+ (NSString*) home {
	if( _home == nil ) {
		_home = [ @"~" stringByExpandingTildeInPath ];
	}
	return _home;
}

static NSString* _version = nil;
+ (NSString*) version {
	if( _version == nil ) {	
		_version = [[[ _prefPaneBundle infoDictionary ] objectForKey: @"CFBundleVersion" ] copy ];
	}
	return _version;
}

static NSString* _shortVersion = nil;
+ (NSString*) shortVersion {
//	if( _shortVersion == nil ) {	
		_shortVersion = [[[ _prefPaneBundle infoDictionary ] objectForKey: @"CFBundleShortVersionString" ] copy ];
//	}
	return _shortVersion;
}


+ (NSString*) preferencesPath: (NSString*)applicationId {
	return [[ NSString stringWithFormat: @"~/Library/Preferences/%@.plist", applicationId ] stringByExpandingTildeInPath ];
}

+ (NSString*) userKeychainPath: (NSString*)keychainName {
	return [[ NSString stringWithFormat: @"~/Library/Keychains/%@.keychain", keychainName ] stringByExpandingTildeInPath ];
}

+ (NSString*) describeOSStatus: (OSStatus) status {
	NSError* error = [ NSError errorWithDomain: NSOSStatusErrorDomain code: status userInfo: nil ];
	return [ error localizedDescription ];
}

+ (NSString*) keychainPath {
	SecKeychainRef loginKeychain = (SecKeychainRef)nil;
	SecKeychainStatus status = 0;
	OSStatus err = SecKeychainCopyDefault( &loginKeychain );
	if( err == 0 && ( loginKeychain != nil )) {
		err = SecKeychainGetStatus( loginKeychain, &status );
	}
	if( err || ( status == 0 )) {
		NSRunAlertPanel( @"Internal Error", @"Fail to get 'default' keychain\n%@", @"OK", nil, nil, [ self describeOSStatus: err ] );
		if( loginKeychain != nil ) {
			CFRelease( loginKeychain );
		}
		return nil;		
	}
	UInt32 ioPathLength = MAXPATHLEN;
	char pathName[ MAXPATHLEN + 1];
	
	err = SecKeychainGetPath( loginKeychain,&ioPathLength,&(pathName[0]));
	
	NSString* result = [[ NSString alloc ] initWithCString: pathName length: ioPathLength ];

	CFRelease( loginKeychain );

	return result;
}

//
// These 3 always point to  com.leapingbytes.AlmostVPNPRO bundle
//
//static NSString* prefPaneInstallPath = nil;
//
//
//static NSString* prefPaneResourcePath = nil;
//static NSString* executablePath = nil;
//static NSString* macOSPath = nil;
//
//
// These 3 are bundle independent 
//
//static NSString* home = nil;
//static NSString* preferencesPath = nil;
//static NSString* applicationSupportPath = nil;
//
//static NSString* bundleIdentifier = @"com.leapingbytes.AlmostVPNPRO";
//
//static NSBundle* prefPaneBundle = nil;
//static NSBundle* bundle = nil;
//static NSDictionary* bundleInfo = nil;
//static NSString* resourcePath = nil;
//
//static BOOL _prefPaneInstalledForAll = NO;
//
//void _LBSetBundleIdentifier( NSString* v ) {
//	bundleIdentifier = [ v copy ];
//}
//
//+(NSString*) bundleIdentifier {
//	return bundleIdentifier;
//}
//
//+(void) setBundleIdentifier: (NSString*) value {
//	bundleIdentifier = [ value copy ];
//	[ self initialize ];
//}
//
//+ (void) locateInstallationParts {
//	//
//	// 1) AlmostVPNPRO.prefPane bundle
//	//
//	if( prefPaneBundle == nil ) {
//		prefPaneBundle = [ NSBundle bundleWithIdentifier: bundleIdentifier ];
//		if( prefPaneBundle == nil ) {
//			prefPaneBundle = [ NSBundle bundleWithPath: [ @"~/Library/PreferencePanes/AlmostVPNPRO.prefPane"  stringByExpandingTildeInPath ]];
//		}
//		if( prefPaneBundle == nil ) {
//			prefPaneBundle = [ NSBundle bundleWithPath: @"/Library/PreferencePanes/AlmostVPNPRO.prefPane" ];
//		}
//		[ prefPaneBundle retain ];			
//		
//		NSLog( @"AlmostVPNPRO.locateInstallationParts %@\n", prefPaneBundle );
//		
//		[ self setPrefPaneBundle: prefPaneBundle ];
//	}
//	_prefPaneInstalledForAll = [[ prefPaneBundle bundlePath ] rangeOfString: @"/Library" ].location == 0;
//	//
//	// 2) com.leapingbytes.AlmostVPNPRO.plist
//	//
//	NSString* guess = [ @"~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist"  stringByExpandingTildeInPath ];
//	if( [[ NSFileManager defaultManager ] fileExistsAtPath: guess ] ) {
//		preferencesPath = [ guess copy ];
//	} else {
//		guess = @"/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist";
//		if( [[ NSFileManager defaultManager ] fileExistsAtPath: guess ] ) {
//			preferencesPath = [ guess copy ];
//		}
//	}
//	preferencesPath = preferencesPath != nil ? preferencesPath : (
//		_prefPaneInstalledForAll ? 
//			[ @"~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist"  stringByExpandingTildeInPath ] :
//			@"/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist"
//	);
//	NSLog( @"AlmostVPNPRO.locateInstallationParts %@\n", preferencesPath );
//	//
//	// 3) Application Support/AlmostVPNPRO
//	//
//	guess = [ @"~/Library/Application Support/AlmostVPNPRO"  stringByExpandingTildeInPath ];
//	if( [[ NSFileManager defaultManager ] fileExistsAtPath: guess ] ) {
//		applicationSupportPath = [ guess copy ];
//	} else {
//		guess = [ NSString stringWithFormat: @"/Library/Application Support/AlmostVPNPRO" ];
//		if( [[ NSFileManager defaultManager ] fileExistsAtPath: guess ] ) {
//			applicationSupportPath = [ guess copy ];
//		}
//	}
//	NSLog( @"AlmostVPNPRO.locateInstallationParts %@\n", applicationSupportPath );
//}
//
//+(BOOL) prefPaneInstalledForAll {
//	return _prefPaneInstalledForAll;
//}
//
//+(void)initialize {
//	[ self locateInstallationParts ];
//	
//	bundle					= [[ NSBundle  bundleWithIdentifier: bundleIdentifier ] retain ];
//	bundleInfo				= [[ bundle infoDictionary ] retain ];
//	resourcePath			= [[ bundle resourcePath ] retain ];	
//}
//
//+(NSString*)version {
//	NSString* result = [ bundleInfo objectForKey: @"CFBundleVersion" ];
//	return result;
//}
//
//+(NSString*)shortVersion {
//	return [ bundleInfo objectForKey: @"CFBundleShortVersionString" ];
//}
//
//+(NSString*)home {
//	return home;
//}
//
//+(NSString*)preferencesPath {
//	return preferencesPath;
//}
//
//+(NSString*)preferencesPath: (NSString*)applicationId {
//	return [[ NSString stringWithFormat: @"~/Library/Preferences/%@.plist", applicationId ] stringByExpandingTildeInPath ];
//}
//
//+(NSString*)applicationSupportPath {
//	return applicationSupportPath;
//}
//
//+(void) setApplicationSupportPath: (NSString*) v {
//	applicationSupportPath = [ v copy ];
//}
//
//+(NSString*)applicationSupportPathForFile: (NSString*) file {
//	return [ NSString stringWithFormat: @"%@/%@", applicationSupportPath, file ];
//}
//+(NSString*)launchdPlistPathForProfile: (NSString*) profile {
//	NSString* result = [ NSString stringWithFormat: @"%@/launchd.%@.plist", applicationSupportPath, profile ];	
//	return result;
//}
//
//+(NSString*)pathForExecutable: (NSString*) exec {
//	NSString* result = [ NSString stringWithFormat: @"%@/%@", macOSPath, exec ];
//	return result;
//}
//
//+(NSString*)resourcePath {
//	return resourcePath;
//}
//
//+(NSString*)installedResourcePath {
//	return prefPaneResourcePath;
//}
//
//+(NSString*)pathForResource: (NSString*) resource {
//	NSString* result = [ NSString stringWithFormat: @"%@/%@", resourcePath, resource ];
//	return result;
//}
//
//+(NSString*)pathForInstalledResource: (NSString*) resource {
//	NSString* result = [ NSString stringWithFormat: @"%@/Contents/Resources/%@", prefPaneInstallPath, resource ];
//	return result;
//}
//
//+(NSString*)userKeychainPath: (NSString*)keychainName {
//	return [ NSString stringWithFormat: @"%@/Library/Keychains/%@.keychain", home, keychainName ];
//}
//
//
//+(NSBundle*)prefPaneBundle {
//	return prefPaneBundle;
//}
//
//+(void)setPrefPaneBundle: (NSBundle*) bundle {
//	prefPaneBundle = bundle;
//
//	prefPaneInstallPath		= [[ prefPaneBundle bundlePath ] retain ];	
//	prefPaneResourcePath	= [[ prefPaneBundle resourcePath ] retain ];	
//	executablePath			= [[ prefPaneBundle executablePath ] retain ];
//	macOSPath				= [[ executablePath stringByDeletingLastPathComponent ] retain ];
//
//	home					= [[ @"~" stringByExpandingTildeInPath ] retain ];
//	preferencesPath			= [[ @"~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist" stringByExpandingTildeInPath ] retain ];
//	applicationSupportPath	= [[ @"~/Library/Application Support/AlmostVPNPRO" stringByExpandingTildeInPath ] retain ];	
//}
//
//+(NSBundle*)almostVPNBundle {
//	return bundle;
//}
//
//+(NSImage*)imageNamed: (NSString*) imageName {
//	NSString* imagePath = [ bundle pathForImageResource: imageName ];
//	
//	return [[[ NSImage alloc ] initByReferencingFile: imagePath ] autorelease ];
//}
//
//+(NSImage*)imageNamed: (NSString*) imageName ofSize: (NSSize) size {
//	NSString* imagePath = [ bundle pathForImageResource: imageName ];
//	NSImage* result = [[[ NSImage alloc ] initByReferencingFile: imagePath ] autorelease ];
//	[ result setScalesWhenResized: YES ];
//	[ result setSize: size ];
//	return result;
//}
//
//+(NSSound*) soundNamed: (NSString*) soundName {
//	NSString* soundPath = [ bundle pathForResource: soundName ofType:@"mov"];
//	if( soundPath == nil ) {
//		return [ NSSound soundNamed: soundName ];
//	} else {
//		return [[[NSSound alloc] initWithContentsOfFile: soundPath byReference: YES ] autorelease ];
//	}
//}
//
//+ (NSString*) describeOSStatus: (OSStatus) status {
//	NSError* error = [ NSError errorWithDomain: NSOSStatusErrorDomain code: status userInfo: nil ];
//	return [ error localizedDescription ];
//}
//
//+ (NSString*) keychainPath {
//	SecKeychainRef loginKeychain = (SecKeychainRef)nil;
//	SecKeychainStatus status = 0;
//	OSStatus err = SecKeychainCopyDefault( &loginKeychain );
//	if( err == 0 && ( loginKeychain != nil )) {
//		err = SecKeychainGetStatus( loginKeychain, &status );
//	}
//	if( err || ( status == 0 )) {
//		NSRunAlertPanel( @"Internal Error", @"Fail to get 'default' keychain\n%@", @"OK", nil, nil, [ self describeOSStatus: err ] );
//		if( loginKeychain != nil ) {
//			CFRelease( loginKeychain );
//		}
//		return nil;		
//	}
//	UInt32 ioPathLength = MAXPATHLEN;
//	char pathName[ MAXPATHLEN + 1];
//	
//	err = SecKeychainGetPath( loginKeychain,&ioPathLength,&(pathName[0]));
//	
//	NSString* result = [[ NSString alloc ] initWithCString: pathName length: ioPathLength ];
//
//	CFRelease( loginKeychain );
//
//	return result;
//}
@end
