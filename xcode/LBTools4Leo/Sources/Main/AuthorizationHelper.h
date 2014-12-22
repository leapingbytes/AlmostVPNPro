//
//  AuthorizationHelper.h
//  LBToolbox
//
//  Created by andrei tchijov on 10/27/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
	@class AuthorizationHelper
	@abstract AuthorizationHelper simplify typical tasks.
	@discussion AuthorizationHelper simplify typical tasks which require use of Authorization:
	
		1. setup setuid tool					
		2. run tool/script/command as a root	
	
	Besides using appropriate Authorization APIs to run things as root, AuthorizationHelper can perform
	digest based validation to prevent tempering (see -registerDigest:forFile: below ).
	
	<strong>NOTE:</strong> Only tool/script with registered digest could be run as root.
	
	Unless absolute path has been used, AuthorizationHelper will look in appliction bundle for 
	tools and scripts. It expect to find:
	
		1. tools in Contentents/MacOS
		1. scripts in Contents/Resources
*/

@interface AuthorizationHelper : NSObject {
	NSBundle*				_bundle;
	NSMutableDictionary*	_digests;
}
/*!
	@method sharedInstance
	@abstract returns shared instance of AuthorizationHelper
	
	@result shared instance 
*/
+ (AuthorizationHelper*) sharedInstance;

/*!
	@method bundle
	@abstract return current bundle
*/
- (NSBundle*) bundle;

/*!
	@method setBundle:
	@abstract set bundle to look into for files
	
	@param bundle bundle
*/

- (void) setBundle: (NSBundle*) bundle;

/*!
	@method registerDigest:forFile:
	@abstract associate digest (MD5) with given file name
	
	@discussion installSetUIDTool:/runTool:withArgs:asRoot:/runScript:withArgs:asRoot: methods 
	will compute digest of the tools/script and compare it with registered value. 
	Only if values match, tools/script could be run as root.
*/
- (void) registerDigest: (NSString*) digest forFile: (NSString*) fileName;

/*!
	@method  installSetUIDTool:ofApplication:forAll:	
	@abstract install tool and make it setuid
	
	@discussion Unless installForAll is true, this method will try to install tool into 
	"~/Library/Application Support". If it is impossible to install tool into "~/Library/Application Support", then 
	"/Library/Application Support" will be used.
	
	It is OK to call this method more then once. For example, to check where tool has been installed.

	@param fileName tool file name
	@param applicationName sub-folder name into which tool will be installed
	@param user user name or "root" to install in /Library/Application Support as root
	@result dictionary which describes results
		- toolPrototypePath : NSString*
		- toolInstallPath : NSString*
		- status : NSString* : { "new" | "good" | "reinstall" | "fail" }
		- errorMessage : NSString* - if status is "fail"
*/
- (NSDictionary*) installSetUIDTool: (NSString*) fileName ofApplication: (NSString*) applicationName forUser: (NSString*) user;

/*!
	@method runTool:withArgs:asRoot:
	@abstract runs tool with given args either as root or as user
	
	@discussion If this tool was installed as SETUID and runAsRoot is YES, then installed version 
	of the tool will run. In this case AuthorizationHelper will not employ any additional authorization APIs
	( no authorization dialog will pop-up ).
	
	This method will wait until tool closes its stdout. 
	
	@param fileName tool file name 
	@param args array of scring to be passed to the tool as parameters
	@param runAsRoot it YES, then tool will be run as root
	@result content of stdout
*/
- (NSString*) runTool: (NSString*) fileName withArgs: (NSArray*) args asRoot: (BOOL) runAsRoot;

/*!
	@method runScript:withArgs:asRoot:
	@abstract runs shell script with given args either as root or as user

	@param fileName shell script file name 
	@param args array of scring to be passed to the tool as parameters
	@param runAsRoot it YES, then tool will be run as root
	@result content of stdout
*/
- (NSString*) runScript: (NSString*) fileName  withArgs: (NSArray*) args asRoot: (BOOL) runAsRoot;

/*!
	@method runCommand:asRoot:
	@abstract runs single shell(bash) command either as root or as user

	@param shellCommand shell command to be run 
	@param runAsRoot it YES, then tool will be run as root
	@result content of stdout
*/
- (NSString*) runCommand: (NSString*) shellCommand asRoot: (BOOL) runAsRoot;

/*!
	@method runCommands:asRoot:
	@abstract runs many shell(bash) commands either as root or as user

	@param shellCommands shell commands to be run 
	@param runAsRoot it YES, then tool will be run as root
	@result content of stdout
*/
- (NSString*) runCommands: (NSArray*) shellCommands asRoot: (BOOL) runAsRoot;

- (void) createFolder: (NSString*) path ownBy: (NSString*) owner withPermissions: (NSString*) permissions;
- (void) createFile: (NSString*) path ownBy: (NSString*) owner withPermissions: (NSString*) permissions;
- (void) changeFile: (NSString*) path ownBy: (NSString*) owner withPermissions: (NSString*) permissions;
- (void) deleteFile: (NSString*) path;
- (void) copyFiles: (NSArray*) files to: (NSString*) to asRoot: (BOOL) runAsRoot;
- (void) moveFiles: (NSArray*) files to: (NSString*) to asRoot: (BOOL) runAsRoot;
//- (void) systemStarterCommand: (NSString*) command forStartupItem: (NSString*) item;

+ (void) runAsRoot: (NSString*) commandPath withArguments: (NSArray*) commandArguments;
+ (void) makeSetUidRoot: (NSString*) commandPath;
+ (void) selfRepair;
@end
