//
//  LBPrivelegedTask.m
//  LBToolbox
//
//  Created by andrei tchijov on 2/1/07.
//  Copyright 2007 Leaping Bytes, LLC. All rights reserved.
//
#include <sys/param.h>
#include <unistd.h>

#include <Security/Security.h>

#import "LBPrivelegedTask.h"


static 	AuthorizationRef authRef = nil;
static FILE* execWithPrivileges( const char* tool, char * const * args ) {
	OSStatus status;
	if( authRef == nil ) {
		status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
		if (status != errAuthorizationSuccess) {
			NSLog( @"AuthorizationHelper.execWithPrivileges AuthorizationCreate failed - %d", status );
			return nil;		
		}
	}

	AuthorizationItem authItems = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights rights = {1, &authItems};
	AuthorizationFlags flags = 
		kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | 
		kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;

	status = AuthorizationCopyRights (authRef, &rights, NULL, flags, NULL);
	if (status != errAuthorizationSuccess) {
		NSLog( @"AuthorizationHelper.execWithPrivileges AuthorizationCopyRights failed - %d", status );
		AuthorizationFree(authRef,kAuthorizationFlagDefaults);
		return nil;
	}

	FILE* pipe = nil;

	status = AuthorizationExecuteWithPrivileges(authRef, tool, kAuthorizationFlagDefaults, args, &pipe);
	
	if( status != errAuthorizationSuccess ) {
		NSLog( @"AuthorizationHelper.execWithPrivileges AuthorizationExecuteWithPrivileges failed - %d", status );
		pipe = nil;
	}

	//AuthorizationFree(authRef,kAuthorizationFlagDefaults);
	
	return pipe;
}

@interface LBPrivelegedTask(Private)
	- (int) fileno: (id) file forReading: (BOOL) forReading;
	- (void) copyInToPipe;
	- (void) copyPipeToOut;
	- (void) copyFrom: (int) inFd to: (int) toFd;	
@end

@implementation LBPrivelegedTask(Private)
	- (int) fileno: (id) file forReading: (BOOL) forReading {
		if ([file isKindOfClass: [NSPipe class]]) {
			file = forReading ? [(NSPipe*)file fileHandleForReading] : [(NSPipe*)file fileHandleForWriting];
			if( _toClose == nil ) {
				_toClose = [ NSMutableArray array ];
			}
			[ _toClose addObject: file ];
		}
		return [file fileDescriptor];
	}	
	
	- (void) copyInToPipe {
		[ self copyFrom: _stdInFno to: _pipeFno ];
		_stdInFno = -1;
		_pipeFno = -1;
	}
	
	- (void) copyPipeToOut {
		[ self copyFrom: _pipeFno to: _stdOutFno ];
		
		_pipeFno = -1;
		_stdOutFno = -1;
	}
	
	- (void) copyFrom: (int) inFd to: (int) toFd {
		char ioBuffer[ 1024+1 ];
		while( YES ) {
			int readBytes = read( inFd, ioBuffer, 1024 );
			if( readBytes <= 0 ) {
				close( inFd );
				close( toFd );
				// NSLog( @"LBPrivelegedTask:copyFrom:To: EOF" );
				break;
			}
			ioBuffer[ readBytes ] = 0;
			// NSLog( @"LBPrivelegedTask:copyFrom:To: %s", ioBuffer );
			write( toFd, ioBuffer, readBytes );
		}
	}	
@end
/*
– setArguments:  
– setCurrentDirectoryPath:  
– setEnvironment:  
– setLaunchPath:  
– setStandardError:  
– setStandardInput:  
– setStandardOutput:  
*/
@implementation LBPrivelegedTask

- (id) init {
	self = [ super init ];
	return self;
}

- (void) launch {
	const char* cCurrentDirectoryPath = [[ self currentDirectoryPath ] UTF8String ];
	const char* cLaunchPath = [[ self launchPath ] UTF8String ];
	const char* cArgs[ [[ self arguments ] count ] + 1 ];
	
	for( int i = 0; i < [[ self arguments ] count ]; i++ ) {
		cArgs[ i ] = [[[ self arguments ] objectAtIndex: i ] UTF8String ];
		cArgs[ i + 1 ] = nil;
	}
	
	/*
		AuthorizationExecuteWithPrivileges does not support specifying current directory for the tool. 
		The only way to simulate it is by changing current directory for the whole process before 
		starting the tool and then reseting it back.
	*/
	char currentPath[ MAXPATHLEN + 1 ];
	if( cCurrentDirectoryPath != nil ) {
		getcwd( currentPath, sizeof( currentPath ));
		chdir( cCurrentDirectoryPath  );
	}
	
		FILE* pipe = execWithPrivileges( cLaunchPath, ( char * const * )cArgs );
	
	if( cCurrentDirectoryPath != nil ) {
		chdir( currentPath );
	}
	
	if( pipe == nil ) {
		NSLog( @"LBPrivilegedTask : execWithPrivileges( %s ) returned null", cLaunchPath );
	} else {
		id stdIn = [ self standardInput ];
		id stdOut = [ self standardOutput ];
		// id stdErr = [ self standardError ];
		
		_pipeFno = fileno( pipe );
		
		_stdInFno = stdIn ? [ self fileno: stdIn forReading: YES ] : -1;
		_stdOutFno = stdOut ? [ self fileno: stdOut forReading: NO ] : -1;
		
		if( _stdInFno >= 0 ) {
			[ NSThread detachNewThreadSelector: @selector( copyInToPipe ) toTarget: self withObject: self ];
		}
		if( _stdOutFno >= 0 ) {
			[ NSThread detachNewThreadSelector: @selector( copyPipeToOut ) toTarget: self withObject: self ];
		}
	}
}

-(void) waitUntilExit {
	NSTimer	*timer = nil;
	while( [ self isRunning ] ) {
		NSDate* limit = [[NSDate alloc] initWithTimeIntervalSinceNow: 0.1];
		if (timer == nil) {
			timer = [NSTimer scheduledTimerWithTimeInterval: 0.1
					   target: nil
					 selector: @selector(class)
					 userInfo: nil
					  repeats: YES];
		}
		[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: limit];
		[ limit release ];		
	}
}

-(BOOL)isRunning {
	return _pipeFno > 0;
}

-(int)terminationStatus {
	return 0;
}

- (void)setLaunchPath:(NSString *)v {
	_launchPath = [ v copy ];
}

- (void)setArguments:(NSArray *)v {
	_arguments = [ v copy ];
}

- (void)setEnvironment:(NSDictionary *)v {
	_env = [ v copy ];
}

- (void)setCurrentDirectoryPath:(NSString *)v {
	_currentDirectoryPath = [ v copy ];
}

- (void)setStandardInput:(id)v {
	_stdIn = v;
}

- (void)setStandardOutput:(id)v {
	_stdOut = v;
}

- (void)setStandardError:(id)v {
	_stdErr = v;
}

- (NSString *)launchPath {
	return _launchPath;
}

- (NSArray *)arguments {
	return _arguments;
}

- (NSDictionary *)environment {
	return _env;
}

- (NSString *)currentDirectoryPath {
	return _currentDirectoryPath;
}

- (id)standardInput {
	return _stdIn;
}

- (id)standardOutput {
	return _stdOut;
}

- (id)standardError {
	return _stdErr;
}

- (void)interrupt{
	NSLog( @"LBPrivilegedTask : -interrupt not supported" );
}

-(void) resume {
	NSLog( @"LBPrivilegedTask : -resume not supported" );
}

-(void) suspend {
	NSLog( @"LBPrivilegedTask : -suspend not supported" );
}

-(void) terminate {
	NSLog( @"LBPrivilegedTask : -terminate not supported" );
}

@end
