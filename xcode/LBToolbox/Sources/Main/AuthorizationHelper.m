//
//  AuthorizationHelper.m
//  LBToolbox
//
//  Created by andrei tchijov on 10/27/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#include <Security/Security.h>
#include <CoreServices/CoreServices.h>
#include <sys/param.h>

#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/errno.h>
#include <sys/mount.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <mach-o/dyld.h>

#include <openssl/md5.h>

#import "AuthorizationHelper.h"
#import "LBPrivelegedTask.h"

static BOOL _debug_mode_ = NO;

static AuthorizationHelper* _sharedInstance = nil;

#define MD5_BUFFER_SIZE MD5_DIGEST_LENGTH * 2 + 1

static unsigned char _hex_digits [] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }; 
static int halfByteToChar( int byte, int oddEven ) {
	byte = ( oddEven ? byte : byte >> 4 ) & 0xf; 
	if( byte >= 0 && byte < 16  ) {
		return _hex_digits[ byte ];
	} else {
		return -1;
	}
}

static int calculateDigest( const char* fileName, char* buffer, const int bufferSize ) {
	if( buffer == NULL ) {
		NSLog( @"AuthorizationHelper.calculateDigest : buffer is NULL\n" );
		return -1;
	}
	
	if( bufferSize < MD5_BUFFER_SIZE ) {
		NSLog( @"AuthorizationHelper.calculateDigest : bufferSize (%d) is too smal. Should be at least %d\n", bufferSize,  MD5_BUFFER_SIZE );
		return -1;		
	}

	FILE* f = fopen( fileName, "r" );
	if( f == NULL ) {
		NSLog( @"AuthorizationHelper.calculateDigest : can not open %s for reading\n", fileName );
		return -1;
	}

	MD5_CTX c;
	MD5_Init( &c );
	
	unsigned char* ioBuffer = malloc( 64*1024 );
	int rc;
	int size = 0;
	while(( rc = fread( ioBuffer, 1, 64*1024, f )) > 0 ) {
		MD5_Update( &c, ioBuffer, rc );
		size += rc;
	}
	fclose( f );	
	MD5_Final( ioBuffer, &c );
	
	int i, j = 0;
	for( i = 0; i < MD5_DIGEST_LENGTH; i++ ) {
		int theByte = ioBuffer[ i ];
		buffer[ j++ ] = halfByteToChar( theByte, 0 );
		buffer[ j++ ] = halfByteToChar( theByte, 1 );
	}
	buffer[ j ] = 0;
	
	free( ioBuffer );
	
	if( _debug_mode_ ) {
		NSLog( @"AuthorizationHelper.calculateDigest MD5(%s) = %s", fileName, buffer );
	}
	
	return 0;
}

@interface NSTask(Helper) 
	- (NSString*) runTool: (NSString*) toolPath withArgs: (NSArray*) args;
@end

@implementation NSTask(Helper) 
	- (NSString*) runTool: (NSString*) toolPath withArgs: (NSArray*) args {	
		[ self setLaunchPath: toolPath ];
		[ self setArguments: args ];
		
		NSPipe* stdOutPipe = [[ NSPipe alloc ] init ];
		[ self setStandardOutput: stdOutPipe ];
		NSPipe* stdErrPipe = [ NSPipe pipe ];	
		[ self setStandardError: stdErrPipe ];

		[ self launch ];
		[ self waitUntilExit ];
	
		NSData* outData = [[ stdOutPipe fileHandleForReading ] readDataToEndOfFile ];
		NSString* result = [ NSString stringWithCString: [ outData bytes ] length: [ outData length ]];

		[ self terminationStatus ];
		/*
		NSData* errData = [[ stdErrPipe fileHandleForReading ] readDataToEndOfFile ];
		NSString* errorString = [ NSString stringWithCString: [ errData bytes ] length: [ errData length ]];
		if( rc  != 0 ) {
			NSLog( @"NSTask(Helper) : ERROR %d\nout:%@\nerr:%@", rc, result, errorString );
		}
		*/
		
		return result;
	}
@end

@interface AuthorizationHelper (Private)
	- (NSString*) filePathForName: (NSString*) fileName;
	- (NSString*) digestForFileAtPath: (NSString*) filePath;
	
	- (BOOL) checkDidgest: (NSString*) fileName;
	
	- (NSString*) forAllPathOfTool: (NSString*) fileName ofApplication: (NSString*) applicationName;
	- (NSString*) forOnePathOfTool: (NSString*) fileName ofApplication: (NSString*) applicationName;
	
	- (BOOL) folderSupportsSetUIDTool: (NSString*) folderPath;
@end

@implementation AuthorizationHelper (Private)
	- (NSString*) filePathForName: (NSString*) fileName {
		NSString* result = [[ self bundle ] pathForAuxiliaryExecutable: fileName ];
		result = ( result != nil ? result : [[ self bundle ] pathForResource: fileName ofType: nil ]);		
		return result;
	}

	- (NSString*) digestForFileAtPath: (NSString*) filePath {
		char md5Buffer[ MD5_BUFFER_SIZE ];
		
		if( calculateDigest( [ filePath UTF8String ], md5Buffer, sizeof( md5Buffer )) != 0 ) {
			return nil;
		}
		
		
		NSString* result = [ NSString stringWithCString: md5Buffer encoding: NSUTF8StringEncoding ];
		
		return result;
	}
	
	- (BOOL) checkDidgest: (NSString*) fileName {
		NSString* registredDidgest = [ _digests objectForKey: fileName ];
		NSString* filePath = [ self filePathForName: fileName ];
		NSString* actualDidgest = [ self digestForFileAtPath: filePath ];	
		
		return [ registredDidgest isEqual: actualDidgest ];
	}
	
	- (NSString*) forAllPathOfTool: (NSString*) fileName ofApplication: (NSString*) applicationName {
		return [ NSString stringWithFormat: @"/Library/Application Support/%@/%@", applicationName, fileName ];
	}
	- (NSString*) forOnePathOfTool: (NSString*) fileName ofApplication: (NSString*) applicationName {
		return [[ NSString stringWithFormat: @"~/Library/Application Support/%@/%@", applicationName, fileName ] stringByExpandingTildeInPath ];
	}
	
	- (BOOL) folderSupportsSetUIDTool: (NSString*) folderPath {
		NSFileManager* fm = [ NSFileManager defaultManager ];
		NSString* testFilePath = [ NSString stringWithFormat: @"%@/.AuthorizationHelper_test_file", folderPath ];
		NSString* output;
		// Create temporary file 
		output = [ self runCommand: [ NSString stringWithFormat: @"/usr/bin/touch \"%@\" && /usr/sbin/chown root \"%@\" && /bin/chmod 4555 \"%@\" && /bin/echo OK", testFilePath, testFilePath, testFilePath ]  asRoot: YES ];
		if( [ output rangeOfString: @"OK" ].location != 0 ) {
			NSLog( @"AuthorizationHelper.folderSupportsSetUIDTool fail to create test file : \"%@\" : %@ ", output, testFilePath );
			return NO;
		}
		@try { 
			NSDictionary* toolFileAttributes = [ fm fileAttributesAtPath: testFilePath traverseLink: NO ];
			int value;
			if ( ( value = [[ toolFileAttributes fileOwnerAccountID ] intValue ]) != 0 ) {
				NSLog( @"AuthorizationHelper.folderSupportsSetUIDTool FS does not support file ownership. %@ owned by %@", testFilePath, output );
				return NO;
			}
			if( ( value = [ toolFileAttributes filePosixPermissions ]) != 04555 ) {
				NSLog( @"AuthorizationHelper.folderSupportsSetUIDTool FS does not support SETUID. %@ mode is %d", testFilePath, value );
				return NO;
			}		
			
			struct statfs	sb;
			int err = statfs([ folderPath UTF8String ], &sb);
			if(( err != 0 ) || ((sb.f_flags & MNT_NOSUID) != 0) ) {
				NSLog( @"AuthorizationHelper.folderSupportsSetUIDTool FS does not support SETUID. FS %@ : sb.f_flags == %o", folderPath, sb.f_flags );
				return NO;
			}

		}
		@finally {
			[ self runCommand: [ NSString stringWithFormat: @"/bin/rm -f \"%@\"", testFilePath ]  asRoot: YES ];
		}
		return YES;				
	}
@end 

@implementation AuthorizationHelper

+ (AuthorizationHelper*) sharedInstance {
	NSLog( @"AVPN : AuthorizationHelper.sharedInstance : Start : %@\n", _sharedInstance );
	if( _sharedInstance == nil ) {
		_sharedInstance = [[ AuthorizationHelper alloc ] init ];
		NSLog( @"AVPN : AuthorizationHelper.sharedInstance : New Instance %@\n", _sharedInstance );
 	}
	NSLog( @"AVPN : AuthorizationHelper.sharedInstance : Result : %@\n", _sharedInstance );
	return _sharedInstance;
}

- (id) init {
	self = [ super init ];
	_digests = [[ NSMutableDictionary alloc ] init ];
	return self;
}

- (NSBundle*) bundle {
	if( _bundle == nil ) {
		_bundle = [ NSBundle mainBundle ];
	}
	return _bundle;
}

- (void) setBundle: (NSBundle*) v {
	_bundle = v;
}

- (void) registerDigest: (NSString*) digest forFile: (NSString*) fileName {
	[ _digests setObject: digest forKey: fileName ];
}

- (NSDictionary*) installSetUIDTool: (NSString*) fileName ofApplication: (NSString*) applicationName forUser: (NSString*) user {
	NSMutableDictionary* result = [ NSMutableDictionary dictionary ];
	
	NSString* toolProtoPath = [ self filePathForName: fileName ];
	[ result setObject: toolProtoPath forKey: @"toolPrototypePath" ];

	NSString* toolProtoDidgest = [ self digestForFileAtPath: toolProtoPath ];
	
	NSFileManager* fm = [ NSFileManager defaultManager ];
	// Check it tool installed
	BOOL installForAll = [ @"root" isEqual: user ];
	
	NSString*	placesToTry[3];
	placesToTry[0] = ( installForAll ? 
			[ self forAllPathOfTool: fileName ofApplication: applicationName ] :
			[ self forOnePathOfTool: fileName ofApplication: applicationName ] );
	placesToTry[1] = ( installForAll ?
			nil :
			[ self forAllPathOfTool: fileName ofApplication: applicationName ] );
	placesToTry[2] = nil;

	NSString* toolPath = nil;
	for( int i = 0; placesToTry[i] != nil; i++ ) {
		if( [ fm fileExistsAtPath: placesToTry[i] ] ) {
			toolPath = placesToTry[i];
			break;
		}
	}
	if( toolPath != nil ) {
		// Check that it is of correct version
		NSString* oldFileDidgest = [ self digestForFileAtPath: toolPath ];
		if( ! [ oldFileDidgest isEqual: toolProtoDidgest ] ) {
			[ result setObject: @"reinstall" forKey: @"status" ];
			[ self runCommand: [ NSString stringWithFormat: @"/bin/rm -f \"%@\"", toolPath ] asRoot: YES ];
			toolPath = nil;
		} else {
			[ result setObject: @"good" forKey: @"status" ];
			[ result setObject: toolPath forKey: @"toolInstallPath" ];
		}
	} else {
		[ result setObject: @"new" forKey: @"status" ];
	}

	if( toolPath == nil ) { // Need to install/re-install the tool
		NSString* registredDigest = [ _digests objectForKey: fileName ];
		
		if( !  [ registredDigest isEqual: toolProtoDidgest ] ) {
			[ result setObject: @"prototype-tempered" forKey: @"status" ];
			NSLog( @"AuthorizationHelper.installSetUIDTool tool prototype was tempered. %@ != %@", registredDigest, toolProtoDidgest );
			goto done;
		}
			
		NSString* appSupportPath = installForAll ? nil : [ @"~/Library/Application Support" stringByExpandingTildeInPath ];
		appSupportPath = appSupportPath != nil && [ self folderSupportsSetUIDTool: appSupportPath ] ? appSupportPath : nil;
		appSupportPath = appSupportPath != nil ? appSupportPath : @"/Library/Application Support" ;
		
		NSString* pathToInstall = [ NSString stringWithFormat: @"%@/%@", appSupportPath, applicationName ];
				
		[ self runCommand: 
			[ NSString stringWithFormat: @"/bin/mkdir -p \"%@\" && /usr/sbin/chown %@ \"%@\"", pathToInstall, user, pathToInstall ] 
			asRoot: YES 
		];
		
		[ self runCommand: [ NSString stringWithFormat: @"/bin/cp \"%@\" \"%@\"", toolProtoPath, pathToInstall ] asRoot: YES ];
		toolPath = [ NSString stringWithFormat: @"%@/%@", pathToInstall, fileName ];
		
		[ result setObject: toolPath forKey: @"toolInstallPath" ];

	}
	
		
	// Make sure that tool is own by root and SETUID
	NSDictionary* toolFileAttributes = [ fm fileAttributesAtPath: toolPath traverseLink: NO ];
	if ( [[ toolFileAttributes fileOwnerAccountID ] intValue ] != 0 ) {
		[ self runCommand: [ NSString stringWithFormat: @"/usr/sbin/chown root \"%@\"", toolPath ] asRoot: YES ];
	}
	if( [ toolFileAttributes filePosixPermissions ] != 04555 ) {
		[ self runCommand: [ NSString stringWithFormat: @"/bin/chmod 04555 \"%@\"", toolPath ] asRoot: YES ];
	}
	
done: 
	
	if( _debug_mode_ ) {
		NSLog( @"AuthorizationHelper.installSetUIDTool : status = %@", [ result objectForKey: @"status" ] );
		NSLog( @"AuthorizationHelper.installSetUIDTool : toolPrototypePath = %@", [ result objectForKey: @"toolPrototypePath" ] );
		NSLog( @"AuthorizationHelper.installSetUIDTool : toolInstallPath = %@",  [ result objectForKey: @"toolInstallPath" ]  );
	}

	return result;
}


- (NSString*) runTool: (NSString*) fileName withArgs: (NSArray*) args asRoot: (BOOL) runAsRoot {
	if( runAsRoot && ( ! [ self checkDidgest: fileName ] )) {
		NSLog( @"AuthorizationHelper.runTool : Can not run %@. checkDidgest fail\n", fileName );
		return nil;
	}

	if( _debug_mode_ ) {
		NSLog( @"AuthorizationHelper.runTool : %@ %@\n", fileName, runAsRoot ? @"as root" : @"" );
		for( int i = 0; i < [ args count ]; i++ ) {
			NSLog( @"AuthorizationHelper.runTool : args[ %d ] = %@\n", i, [ args objectAtIndex: i ] );		
		}
	}
		
	NSTask* toolTask = [( runAsRoot ? [ LBPrivelegedTask alloc ] : [ NSTask alloc ] ) init ];
	
	NSString* result = [ toolTask runTool: fileName withArgs: args ];

	return result;
}

- (NSString*) runScript: (NSString*) fileName  withArgs: (NSArray*) args asRoot: (BOOL) runAsRoot {
	if( runAsRoot && ( ! [ self checkDidgest: fileName ] )) {
		NSLog( @"AuthorizationHelper.runScript : Can not run %@. checkDidgest fail\n", fileName );
		return nil;
	}
	
	if( _debug_mode_ ) {
		NSLog( @"AuthorizationHelper.runTool : %@ %@\n", fileName, runAsRoot ? @"as root" : @"" );
		for( int i = 0; i < [ args count ]; i++ ) {
			NSLog( @"AuthorizationHelper.runScript : args[ %d ] = %@\n", i, [ args objectAtIndex: i ] );				
		}
	}
		
	NSMutableString* command = [ NSMutableString stringWithFormat: @"%@ ", [ self filePathForName: fileName ]];
	for( int i = 0; i < [ args count ]; i++ ) {
		[ command appendFormat: @"'%@' ", [ args objectAtIndex: i ]];
	}

	NSString* result = [ self runCommand: command asRoot: runAsRoot ];
	
	return result;
}

- (NSString*) runCommand: (NSString*) shellCommand asRoot: (BOOL) runAsRoot {
	NSArray* args = 
		runAsRoot ?
			[ NSArray arrayWithObjects: 
				@"-p",
				@"-c",
				shellCommand,
				nil
			]:
			[ NSArray arrayWithObjects: 
				@"-c",
				shellCommand,
				nil
			];

	NSTask* toolTask = ( runAsRoot ? [[ LBPrivelegedTask alloc ] init ] : [[ NSTask alloc ] init ] );
	
	NSString* result = [ toolTask runTool: @"/bin/bash" withArgs: args ];

	return result;
}

- (NSString*) runCommands: (NSArray*) shellCommands asRoot: (BOOL) runAsRoot {
	NSMutableString* command = [ NSMutableString string ];
	
	for( int i = 0; i < [ shellCommands count ]; i++ ) {
		[ command appendFormat: @"%@; ", [ shellCommands objectAtIndex: i ]];
	}
	
	return [ self runCommand: command asRoot: runAsRoot ];
}

- (void) createFolder: (NSString*) path ownBy: (NSString*) owner withPermissions: (NSString*) permissions {
	[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/bin/mkdir" withArgs: [ NSArray arrayWithObjects: @"-p", path, nil ]];	
	if( owner != nil ) {
		[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/usr/sbin/chown" withArgs: [ NSArray arrayWithObjects: owner, path, nil ]];	
	}
	if( permissions != nil ) {
		[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/bin/chmod" withArgs: [ NSArray arrayWithObjects: permissions, path, nil ]];	
	}
}

- (void) deleteFile: (NSString*) path {
	[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/bin/rm" withArgs: [ NSArray arrayWithObjects: @"-rf", path, nil ]];	
}

- (void) createFile: (NSString*) path ownBy: (NSString*) owner withPermissions: (NSString*) permissions {
	[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/usr/bin/touch" withArgs: [ NSArray arrayWithObject: path ]];	
	if( owner != nil ) {
		[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/usr/sbin/chown" withArgs: [ NSArray arrayWithObjects: owner, path, nil ]];	
	}
	if( permissions != nil ) {
		[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/bin/chmod" withArgs: [ NSArray arrayWithObjects: permissions, path, nil ]];	
	}
}

- (void) changeFile: (NSString*) path ownBy: (NSString*) owner withPermissions: (NSString*) permissions {
	if( owner != nil ) {
		[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/usr/sbin/chown" withArgs: [ NSArray arrayWithObjects: owner, path, nil ]];	
	}
	if( permissions != nil ) {
		[ [[ LBPrivelegedTask alloc ] init ] runTool: @"/bin/chmod" withArgs: [ NSArray arrayWithObjects: permissions, path, nil ]];	
	}
}

- (void) copyFiles: (NSArray*) files to: (NSString*) to asRoot: (BOOL) runAsRoot {
	NSTask* toolTask = ( runAsRoot ? [[ LBPrivelegedTask alloc ] init ] : [[ NSTask alloc ] init ] );

	NSMutableArray* args = [ NSMutableArray arrayWithArray: files ];
	[ args addObject: to ];
	[ toolTask runTool: @"/bin/cp" withArgs: args ];	
}

- (void) moveFiles: (NSArray*) files to: (NSString*) to asRoot: (BOOL) runAsRoot {
	NSTask* toolTask = ( runAsRoot ? [[ LBPrivelegedTask alloc ] init ] : [[ NSTask alloc ] init ] );

	NSMutableArray* args = [ NSMutableArray arrayWithArray: files ];
	[ args addObject: to ];
	[ toolTask runTool: @"/bin/mv" withArgs: args ];	
}

+ (void) runAsRoot: (NSString*) commandPath withArguments: (NSArray*) commandArguments {
	NSLog( @"Not yet implmented : class: %@, method: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
+ (void) makeSetUidRoot: (NSString*) commandPath {
	NSLog( @"Not yet implmented : class: %@, method: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
}

typedef int (*NSGetExecutablePathProcPtr)(char *buf, size_t *bufsize);
+ (void) selfRepair {
	char* myPath = (char*)malloc( 1024+1 );
	size_t myPathLength = 1024;
	
	((NSGetExecutablePathProcPtr) NSAddressOfSymbol(NSLookupAndBindSymbol("__NSGetExecutablePath")))(myPath, &myPathLength);
	
	/*  Self repair code.  We ran ourselves using AuthorizationExecuteWithPrivileges()
        so we need to make ourselves setuid root to avoid the need for this the next time around. */
	
    AuthorizationRef auth;

	struct stat st;
	int fd_tool;
	
	/* Recover the passed in AuthorizationRef. */
	if(  AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth))
//
//	if (AuthorizationCopyPrivilegedReference(&auth, kAuthorizationFlagDefaults))
		return;
	
    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights;
	AuthorizationItem right = {
		 "system.preferences", 0, NULL, kAuthorizationFlagDefaults
	};
	AuthorizationRights rightSet = { 1, &right };
    if( AuthorizationCopyRights(auth, &rightSet, kAuthorizationEmptyEnvironment, flags, NULL)) 
		return;
	
//	if (AuthorizationCopyPrivilegedReference(&auth, kAuthorizationFlagDefaults))
//		return;
	
	/* Open tool exclusively, so noone can change it while we bless it */
	fd_tool = open(myPath, O_NONBLOCK|O_RDONLY|O_EXLOCK, 0);
	
	if (fd_tool == -1) {
		return;
	}
	
	if (fstat(fd_tool, &st))
		return;
	
	if (st.st_uid != 0)
		fchown(fd_tool, 0, st.st_gid);
	
	/* Disable group and world writability and make setuid root. */
	fchmod(fd_tool, (st.st_mode & (~(S_IWGRP|S_IWOTH))) | S_ISUID);
	
	close(fd_tool);		
}
@end
