//
//  QuickConfigHelper.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/24/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "QuickConfigHelper.h"
#import "PathLocator.h"
#import "AlmostVPNModel.h"
#import "LBUtils.h"
#import "LBService.h"
#import "AlmostVPNConfigurationController.h"
#import "KeyChainAdapter.h"
#import "LBServer.h"
#import "LBService.h"


#import "SSHTunnel.h"

static QuickConfigHelper* _sharedInstance = nil;

@interface AlmostVPNProfile (QuickConfigHelper)
- (BOOL) isDefault;
- (void) setIsDefault: (BOOL) v;
@end

@implementation AlmostVPNProfile (QuickConfigHelper)
- (BOOL) isDefault {
	return [ self booleanValueForKey: @"-is-default-" ];
}

- (void) setIsDefault: (BOOL) v {
	[ self setBooleanValue: v forKey: @"-is-default-" ];
}
@end

@implementation QuickConfigHelper

#pragma mark Private 

+ (void) initialize {
	_sharedInstance = [[ QuickConfigHelper alloc ] init ];
}

- (id) init {
	_sharedInstance = self;
	_configDictionary = [[ NSMutableDictionary alloc ] init ];
//	_configDictionary = [[ AlmostVPNObject alloc ] init ];
	[ self initializedQuickConfigDictionary ];
	return self;
}

- (NSMutableDictionary*) configDictionary {
	return _configDictionary;
}

+ (QuickConfigHelper*) sharedInstance {
	return _sharedInstance;
}

+ (NSMutableDictionary*) initializePopular: (NSMutableDictionary*) dict {
	id defaultIdentity = [[ AlmostVPNLocalhost sharedInstance ] defaultIdentity ];
	if( defaultIdentity != nil ) {
		[ dict setObject: defaultIdentity forKey: @"sshServerIdentity" ];
	}
//	[ dict setObject: @"Quick Config" forKey: @"profileName" ];
	
	return dict;	
}
+ (NSMutableDictionary*) addFileToImports: (NSString*) fileName {
	NSMutableDictionary* dict = [[ self sharedInstance ] configDictionary ];
	fileName = [ fileName stringByExpandingTildeInPath ];
	
	if( ! [[ NSFileManager defaultManager ] fileExistsAtPath:  fileName ] ) {
		[ AlmostVPNConfigurationController 
			logMessage: [ NSString stringWithFormat: @"file %@ does not exist", fileName ]
			from: @"import" atLevel: @"900" ];
		return nil;
	}
	
	NSMutableArray* imports = [ dict objectForKey: @"imports" ];
	if( imports == nil ) {		
		imports = [ NSMutableArray array ];
	}
	int count = [ imports count ];
	for( int i = 0; i < count; i++ ) {
		if( [ fileName isEqual: [[ imports objectAtIndex: i ] objectForKey: @"path" ]] ) {
			return nil;
		}
	}
	
	NSString* productName = @"Unknown";
	NSString* logo = @"UnknownLogo";
	BOOL checked = YES;
	BOOL enabled = YES;
	
	if( [ fileName rangeOfString: @"org.tynsoe.sshtunnelmanager" ].location != NSNotFound ) {
		productName = @"SSH Tunnel Manager v 1.x";
		logo = @"STMLogo";
	} else if( [ fileName rangeOfString: @"com.tynsoe.sshtunnelmanager" ].location != NSNotFound ) {
		productName = @"SSH Tunnel Manager v 2.x";
		logo = @"STMLogo";
	} else if( [ fileName rangeOfString: @"com.leapingbytes.AlmostVPN.plist" ].location != NSNotFound ) {
		productName = @"AlmostVPN 0.9.x";
		logo = @"AlmostVPNLogo";
	} else if( [ fileName rangeOfString: @"SSHKeychain" ].location != NSNotFound ) {
		productName = @"SSHKeychain";
		logo = @"SSHKeychainLogo";
	} else if( [ fileName rangeOfString: @".tunnel" ].location != NSNotFound ) {
		productName = @"SSHAgent";
		logo = @"SSHAgentLogo";
	} else if( [ fileName rangeOfString: @"jellyfiSSHr12_bm.xml" ].location != NSNotFound ) {
		productName = @"jellyfiSSH";
		logo = @"JellyfisshLogo";
	} else {
		checked = NO;
		enabled = NO;
	}
		
//	if( ! checked ) {
//		[ AlmostVPNConfigurationController 
//			logMessage: [ NSString stringWithFormat: @"file %@ can not be recognized", fileName ];
//			from: @"import" atLevel: @"900" ];
//		return;
//	}
	
	count++;
	
	NSMutableDictionary* import = [ NSMutableDictionary dictionary ];
	[ imports addObject: import ];
	[ import setObject: fileName forKey: @"path" ];
	[ import setObject: [ NSString stringWithFormat: @"%@\n%@", productName, [ fileName stringByAbbreviatingWithTildeInPath ]] forKey: @"comment" ];
	[ import setObject: logo forKey: @"logo" ];
	[ import setObject: [ NSNumber numberWithBool: checked ] forKey:@"checked" ];
	[ import setObject: [ NSNumber numberWithBool: enabled ] forKey:@"enabled" ];
	
	[ import addObserver: _sharedInstance forKeyPath: @"checked" options:  NSKeyValueObservingOptionNew context: nil ];
	
	if( count >= 6 ) {
		[ dict setObject: [ NSNumber numberWithInt: 32 ] forKey: @"importsTableRowHight" ];
	} else if( count > 3 ) {
		[ dict setObject: [ NSNumber numberWithInt: 48 ] forKey: @"importsTableRowHight" ];
	} else {
		[ dict setObject: [ NSNumber numberWithInt: 64 ] forKey: @"importsTableRowHight" ];
	}
	
	[ dict setObject: imports forKey: @"imports" ];
	
	return import;
}

+ (void) initializeImport: (NSMutableDictionary*) dict {
	NSFileManager* fm = [ NSFileManager defaultManager ];
	
	NSString* sshtmv1Path = [ PathLocator preferencesPath: @"org.tynsoe.sshtunnelmanager" ];
	NSString* sshtmv2Path =  [ PathLocator preferencesPath: @"com.tynsoe.sshtunnelmanager" ];
	NSString* sshkcPath = [ PathLocator preferencesPath: @"SSHKeychain" ];
	NSString* avpn09Path = [ PathLocator preferencesPath: @"com.leapingbytes.AlmostVPN" ]; 	
	NSString* jellyfisshPath = [ @"~/Library/Preferences/JellyfiSSH/jellyfiSSHr12_bm.xml" stringByExpandingTildeInPath ];
	
	NSMutableArray* imports = [ NSMutableArray array ];
	[ dict setObject: imports forKey: @"imports" ];

	NSMutableDictionary* import;
	
	BOOL avpn09Present = [ fm fileExistsAtPath: avpn09Path ];
	BOOL sshtmv1Present = [ fm fileExistsAtPath: sshtmv1Path ];
	BOOL sshtmv2Present = [ fm fileExistsAtPath: sshtmv2Path ];
	BOOL sshkcPresent = [ fm fileExistsAtPath: sshkcPath ];
	BOOL jellyfisshPresent = [ fm fileExistsAtPath: jellyfisshPath ];
	
	if( avpn09Present ) {		
		import = [ self addFileToImports: avpn09Path ];
		[ import setObject: [ NSNumber numberWithBool: YES ] forKey:@"checked" ];
	}
	
	if( sshtmv1Present ) {
		import = [ self addFileToImports: sshtmv1Path ];
		[ import setObject: [ NSNumber numberWithBool: ! avpn09Present && ! sshtmv2Present ] forKey:@"checked" ];
	}
	if( sshtmv2Present ) {
		import = [ self addFileToImports: sshtmv2Path ];
		[ import setObject: [ NSNumber numberWithBool: ! avpn09Present ] forKey:@"checked" ];
	}
	if( sshkcPresent ) {
		import = [ self addFileToImports: sshkcPath ];
		[ import setObject: [ NSNumber numberWithBool: ! avpn09Present ] forKey:@"checked" ];
	}
	if( jellyfisshPresent ) {
		import = [ self addFileToImports: jellyfisshPath ];
		[ import setObject: [ NSNumber numberWithBool: ! avpn09Present ] forKey:@"checked" ];
	}
}

- (void) initializedQuickConfigDictionary {
	[ QuickConfigHelper initializePopular: _configDictionary ];
	[ QuickConfigHelper initializeImport: _configDictionary ];
	
	[ _configDictionary addObserver: _sharedInstance forKeyPath: @"commandLine" options: NSKeyValueObservingOptionNew context: nil ];		
}

+ (AlmostVPNHost*) getHostWithName: (NSString*) hostName forSSHServer: (AlmostVPNLocation*) sshServer {
	AlmostVPNHost* result = nil;
	if( [ @"127.0.0.1" isEqual: hostName ] || [ @"localhost" isEqual: hostName ] || [ hostName isEqual: [ sshServer name ]] ) {
		result = sshServer;
	} else {
		result = (AlmostVPNHost*)[ sshServer 
			childOfClass: [ AlmostVPNHost class ]
			andName: hostName
			createIfNeeded: YES
		];
	}
	return result;
}

+ (AlmostVPNLocation*) processSshServer: (NSMutableDictionary*) dict {
	AlmostVPNLocation* sshServer = (AlmostVPNLocation*)[
		[ AlmostVPNConfiguration sharedInstance ] 
			childOfClass: [ AlmostVPNLocation class ]
			andName: [ dict objectForKey: @"sshServerHostName" ]
			createIfNeeded: YES
	];
	
	NSString* userName = [ dict objectForKey: @"sshServerUserName" ];
	if( userName != nil ) {
		[[ sshServer account ] setUserName: userName ];
	}
	NSString* password = [ dict objectForKey: @"sshServerPassword" ];
	if( password != nil ) {
		[[ sshServer account ] setUsePassword: [ NSNumber numberWithBool: YES ]];
		[[ sshServer account ] setPassword: password ];		
	}
	[ sshServer setIdentity: [ dict objectForKey: @"sshServerIdentity" ]];
	
	return sshServer;
}

+ (AlmostVPNProfile*) processProfile: (NSMutableDictionary*) dict withDefaultName: (NSString*) defaultName {
	NSString* profileName = [ dict objectForKey: @"profileName" ];
	BOOL isDefault = profileName == nil;
	profileName = profileName != nil ? profileName : defaultName;
	
	AlmostVPNProfile* profile = (AlmostVPNProfile*)[
		[ AlmostVPNConfiguration sharedInstance ] 
			childOfClass: [ AlmostVPNProfile class ]
			andName: profileName
			createIfNeeded: YES
	];
	
	[ profile setIsDefault: isDefault ];
	
	return profile;
}
+ (AlmostVPNProfile*) processProfile: (NSMutableDictionary*) dict {
	return [ self processProfile: dict withDefaultName: @"Quick Config" ];
}

+ (void) processProfileItems: (NSArray*)profileItems forProfile: (AlmostVPNProfile*)profile {
	NSEnumerator* items = [ profileItems objectEnumerator ];
	id item;
	while( ( item = [ items nextObject ] ) != nil ) {
		if( [ item isKindOfClass: [ AlmostVPNObjectRef class ]] ) {
			[ profile addChild: item ];
		} else {
			if( [ item isKindOfClass: [ AlmostVPNHost class ]] ) {
				AlmostVPNHostAlias* hostAlias = [[ AlmostVPNHostAlias alloc ] init ];
				[ hostAlias setAliasName: [ item name ]];
				[ hostAlias setAutoAliasAddress: [ NSNumber numberWithBool: YES ]];
				[ hostAlias setReferencedObject: item ];
				[ profile addChild: hostAlias ];
			} else {
				NSLog( @"ERROR : Unexpected class : %@\n", NSStringFromClass( [ item class ] ));
			}
		}
	}
}

#pragma mark CommandLine
+(NSArray*) parseOptionsString: (NSString*) value {
	NSMutableArray* result = [ NSMutableArray array ];
	NSArray* parts = [ value componentsSeparatedByString: @" " ];
	
	BOOL		inQuotes = NO;
	NSString*	quote = @"";
	NSString*	item = @"";
	
	for( int i = 0; i < [ parts count ]; i++ ) {
		NSString* part = [ parts objectAtIndex: i ];
		if( [ part length ] == 0 ) {
			continue;
		}
		
		if( inQuotes ) {
			item = [ item stringByAppendingString: @" " ];
			NSRange quotesRange = [ part rangeOfCharacterFromSet: 
				[ NSCharacterSet characterSetWithCharactersInString: quote ]
			];
			if( quotesRange.location != NSNotFound ) {
				NSArray* beforAndAfterQuote = [ part componentsSeparatedByString: quote ];
				for( int i = 0; i < [ beforAndAfterQuote count ]; i++ ) {
					item = [ item stringByAppendingString: [ beforAndAfterQuote objectAtIndex: i ]];
				}
				inQuotes = NO;
				[ result addObject: item ];
				item = @"";
			} else {
				item = [ item stringByAppendingString: part ];
			}
		} else {
			unichar char0 = [ part characterAtIndex: 0 ];
			unichar charLast = [ part characterAtIndex: [ part length ] - 1 ];
			
			if(( char0 == '\'' || char0 == '"' ) && ( char0 == charLast )) {
				[ result addObject: [ part stringByTrimmingCharactersInSet: [ NSCharacterSet characterSetWithCharactersInString: @"\"'" ]]];
			} else {
				NSRange quotesRange = [ part rangeOfCharacterFromSet: 
					[ NSCharacterSet characterSetWithCharactersInString: @"\"'" ]
				];
				if( quotesRange.location != NSNotFound ) {
					if( quotesRange.location == 0 ) {
					} 
					inQuotes = YES;
					quote = [ part substringWithRange: quotesRange ];

					NSArray* beforAndAfterQuote = [ part componentsSeparatedByString: quote ];
					for( int i = 0; i < [ beforAndAfterQuote count ]; i++ ) {
						item = [ item stringByAppendingString: [ beforAndAfterQuote objectAtIndex: i ]];
					}
				} else {
					[ result addObject: part ];
				}
			}
		}
	}
	
	return result;
}

+ (NSDictionary*) parseCommandLine: (NSString*) commandLineString  {
	NSArray* options = [ self parseOptionsString: commandLineString ];
	BOOL warnings = NO;
	
	NSArray* optionsToFlag = [ NSArray arrayWithObjects:
		@"-1", @"-A", @"-b", @"-e", @"-F", @"-g",
		@"-I", @"-s", @"-t", 
		nil
	];

	NSArray* optionsToIgnore = [ NSArray arrayWithObjects:
		@"-f", @"-N", @"-n", @"-q", @"-V", @"-v", @"-T", @"-o",
		nil
	];
	NSArray* simpleOptions = [ NSArray arrayWithObjects: 
		@"-1", @"-2", 
		@"-4", @"-6", 
		@"-A", @"-a", 
		@"-C", @"-g",
		@"-k", @"-s", 
		@"-T", @"-t", 
		@"-X", @"-x",
		@"-Y",
		nil
	];
	NSArray* optionsWithArg = [ NSArray arrayWithObjects: 
		@"-b", @"-c", @"-D", @"-e", @"-F", @"-i", @"-m", @"-o", @"-p", @"-l", @"-L", @"-R",
		nil
	];
	
	NSString* user = nil;
	NSString* host = nil;
#pragma unused ( user, host, simpleOptions )

	NSMutableArray* normalizedOptions = [ NSMutableArray array ];
	NSMutableString* avpnCommandLine = [ NSMutableString string ];
	
	NSEnumerator* optionsEnumerator = [ options objectEnumerator ];
	NSString* option;
	NSString* arg = nil;
	NSString* null = (NSString*)[ NSNull null ];
	BOOL gotUserNameAndHost = NO;
	NSMutableString* remoteCommand = nil;
	
	while(( option = [ optionsEnumerator nextObject ]) != nil ) {
		arg = null;
			
		option = [ option stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]];
		if(  [ @"\\" isEqual: option ] || ( [ option length ] == 0 ) ){
			continue;
		}
		
		if ( [ @"ssh" isEqual: option ] || ( [ option length ] == 0 )) {
			[ avpnCommandLine appendFormat: @"<span class='normal'>%@</span>&nbsp ", option  ];			
			continue;
		}
		
		if( [ option characterAtIndex: 0 ] != '-' ) {
			if( ! gotUserNameAndHost ) {
				gotUserNameAndHost = YES;
				[ normalizedOptions addObject: [ NSNull null ] ];
				[ normalizedOptions addObject: option ];
				[ avpnCommandLine appendFormat: @"<span class='normal'>%@</span>&nbsp ", option  ];			
			} else {
				remoteCommand = remoteCommand == nil ? [ NSMutableString string ] : remoteCommand;
				[ remoteCommand appendString: option ];
				[ remoteCommand appendString: @" " ];
				while(( option = [ optionsEnumerator nextObject ]) != nil ) {
					[ remoteCommand appendString: option ];
					[ remoteCommand appendString: @" " ];
				}
				[ normalizedOptions addObject: [ NSNull null ] ];
				[ normalizedOptions addObject: remoteCommand ];
				[ avpnCommandLine appendFormat: @"<span class='remoteCommand'>%@</span>&nbsp ", remoteCommand  ];			
			}
			continue;
		}
		
		if( [ optionsWithArg containsObject: option ] ) {
			arg = [ optionsEnumerator nextObject ];
		}	
		
		if ( [ optionsToFlag containsObject: option ] ) {
			[ avpnCommandLine appendFormat: ( arg != null ? @"<span class='flag'>%@ %@</span>&nbsp" : @"<span class='flag'>%@</span>&nbsp" ), option, arg ];
			warnings = YES;
			[ AlmostVPNConfigurationController 
				logMessage: [ NSString stringWithFormat: @"%@ option is not supported", option ] 
				from: @"import" atLevel: @"900"
			];
			continue;
		}
		if ( [ optionsToIgnore containsObject: option ] ) {
			[ avpnCommandLine appendFormat: ( arg != null ? @"<span class='ignore'>%@ %@</span>&nbsp" : @"<span class='ignore'>%@</span>&nbsp" ), option, arg ];
			continue;
		}
		[ avpnCommandLine appendFormat: ( arg != null ? @"<span class='normal'>%@ %@</span>&nbsp" : @"<span class='normal'>%@</span>&nbsp" ), option, arg ];
		
		[ normalizedOptions addObject: option ];
		[ normalizedOptions addObject: arg ];		
		
		[ avpnCommandLine appendString: @" " ];
	}
	
	#define _PREFIX_	\
		@"<style>"		\
			"* { padding: 0px; margin: 0px; margin-left: 3px; } " \
			"hr { margin: 3px; } " \
			"p { padding-left: 20px; font-size: 75%; } " \
			"span { white-space: nowrap; } " \
			"*.flag { color: red; border-bottom: 1px dotted red;} " \
			"*.ignore { color: gray; } " \
			"*.normal { color: black; } " \
			"*.remoteCommand { color: black; font-style: italic; } " \
		"</style>"
		
	#define _POSTFIX_	\
		@"<hr/>" \
		"<span class='flag'>-x</span><p>This(ese) option(s) is(are) not supported</p>" \
		"<span class='ignore'>-x</span><p>This(ese) option(s) is(are) ignored</p>" \
		"<span class='remoteCommand'>xx</span><p>AlmostVPN will try to execute this command on remote host</p>"		
	
	NSMutableDictionary* result = [ NSMutableDictionary dictionaryWithObjectsAndKeys: 
		options, @"options",
		normalizedOptions, @"normalizedOptions", 		
		[ NSNumber numberWithBool: warnings ], @"warnings",
		[ NSString stringWithFormat: @"%@\n%@\n%@", _PREFIX_, avpnCommandLine, _POSTFIX_ ], @"avpnCommandLine",
		nil
	];	
	
	return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

	if( [ @"checked" isEqual: keyPath  ] ) {
		if( [[ (NSDictionary*) object objectForKey: @"checked" ] boolValue ] ) {
			[ _configDictionary setObject: @"" forKey: @"importsConfigurationFilePath" ]; 
		}
	} else if( [ @"commandLine" isEqual: keyPath ] ) {
		NSDictionary* dict = (NSDictionary*) object;
		NSDictionary* commandLineDict = [ QuickConfigHelper parseCommandLine: [ dict objectForKey: @"commandLine" ]];
		[ _configDictionary setObject: commandLineDict forKey: @"parsedCommandLine" ];
		NSString* avpnCommandLine = [ commandLineDict objectForKey: @"avpnCommandLine" ];
		[
			[[AlmostVPNConfigurationController avpnCommandLineView ] mainFrame ] 
			loadHTMLString: avpnCommandLine baseURL: [ NSURL URLWithString: @"http://localhost" ]
		];
	}
}

#pragma mark -
#pragma mark Popular : Process File

+ (NSMutableDictionary*) processFile: (NSMutableDictionary*) dict withSshServer: (AlmostVPNLocation*) sshServer addProfileItemsTo: (NSMutableArray*) profileItems {
	NSString* fileRemotePath = [ dict objectForKey: @"fileRemotePath" ];
	NSString* fileLocalPath = [ dict objectForKey: @"fileLocalPath" ];
	NSString* operation = [ dict objectForKey: @"fileOperation" ];
	operation = operation == nil ? @"download" : operation;

	if( ( [ fileRemotePath length ] + [ fileLocalPath length ] ) != 0 ) {
		if( [ @"download" isEqual: operation ] ) {
			AlmostVPNFile* file = (AlmostVPNFile*) [ sshServer
				childOfClass: [ AlmostVPNFile class ]
				andName: [ fileRemotePath lastPathComponent ]
				createIfNeeded: YES
			];
			[ file setFileKind: [ NSNumber numberWithInt: 0 ]];				// file
			[ file setPath: fileRemotePath ];
			
			AlmostVPNFileRef* fileRef = [[ AlmostVPNFileRef alloc ] init ];
			[ fileRef setDestinationLocation: [ AlmostVPNLocalhost sharedInstance ]];
			[ fileRef setReferencedObject: file ];
			[ fileRef setDoAfterStart: [ NSNumber numberWithBool: YES ]];
			[ fileRef setDoThis: [ NSNumber numberWithInt: 0 ]];			// copy
			if( [ fileLocalPath length ] != 0 ) {
				[ fileRef setDestinationPath: fileLocalPath ];
			}
			
			[ profileItems addNewObject: fileRef ];
		} else if( [ @"upload" isEqual: operation ] ) {
			AlmostVPNFile* file = (AlmostVPNFile*) [ [ AlmostVPNLocalhost sharedInstance ]
				childOfClass: [ AlmostVPNFile class ]
				andName: [ fileLocalPath lastPathComponent ]
				createIfNeeded: YES
			];
			[ file setFileKind: [ NSNumber numberWithInt: 0 ]];				// file
			[ file setPath: fileLocalPath ];
			
			AlmostVPNFileRef* fileRef = [[ AlmostVPNFileRef alloc ] init ];
			[ fileRef setDestinationLocation: sshServer ];
			[ fileRef setReferencedObject: file ];
			[ fileRef setDoAfterStart: [ NSNumber numberWithBool: YES ]];
			[ fileRef setDoThis: [ NSNumber numberWithInt: 0 ]];			// copy
			if( [ fileRemotePath length ] != 0 ) {
				[ fileRef setDestinationPath: fileRemotePath ];
			}
			
			[ profileItems addNewObject: fileRef ];
		} else if( [ @"execute" isEqual: operation ] ) {
			AlmostVPNFile* file = (AlmostVPNFile*) [ sshServer
				childOfClass: [ AlmostVPNFile class ]
				andName: [ fileRemotePath lastPathComponent ]
				createIfNeeded: YES
			];
			[ file setFileKind: [ NSNumber numberWithInt: 3 ]];				// script
			[ file setPath: fileRemotePath ];
			
			AlmostVPNFileRef* fileRef = [[ AlmostVPNFileRef alloc ] init ];
			[ fileRef setDestinationLocation: [ AlmostVPNLocalhost sharedInstance ]];
			[ fileRef setReferencedObject: file ];
			[ fileRef setDoAfterStart: [ NSNumber numberWithBool: YES ]];
			[ fileRef setDoThis: [ NSNumber numberWithInt: 3 ]];			// nop
			[ fileRef setAndExecute: [ NSNumber numberWithBool: YES ]];
			
			[ profileItems addNewObject: fileRef ];
		}
	}
	
	return dict;
}

#pragma mark Popular : Process Printer

+ (NSMutableDictionary*) processPrinter: (NSMutableDictionary*) dict withSshServer: (AlmostVPNLocation*) sshServer addProfileItemsTo: (NSMutableArray*) profileItems {
	NSString* printerHostName = [ dict objectForKey: @"printerHostName" ];
	if( [ printerHostName length ] != 0 ) {
		NSString* printerType = [ dict objectForKey: @"printerType" ];
		printerType = printerType == nil ? @"ipp" : printerType;
		NSString* printerQueue = [ dict objectForKey: @"printerQueueName" ];
		NSString* printerModel = [ dict objectForKey: @"printerModel" ];
		BOOL printerIsPostscript = [ dict objectForKey: @"printerIsPostscript" ] == nil || [ [ dict objectForKey: @"printerIsPostscript" ] boolValue ];
		BOOL printerIsFax = [[ dict objectForKey: @"printerIsFax" ] boolValue ];
		
		AlmostVPNHost* printerHost = [ self getHostWithName: printerHostName forSSHServer: sshServer ];
		[ profileItems addNewObject: printerHost ];
		
		AlmostVPNPrinter* printer = (AlmostVPNPrinter*)[ printerHost
			childOfClass: [ AlmostVPNPrinter class ] 
			andName: [ NSString stringWithFormat: @"%@://./%@", printerType, printerQueue ] 
			createIfNeeded: YES
		];
		[ printer setPrinterType: printerType ];
		[ printer setPrinterQueue: printerQueue ];
		[ printer setPostscript: [ NSNumber numberWithBool: printerIsPostscript ]];
		[ printer setFax: [ NSNumber numberWithBool: printerIsFax ]];
		if( [ printerModel length ] != 0 ) { 
			[ printer setPrinterModel: printerModel ];
		}
		// To make sure that we do have "printer-model" property
		[ printer setPrinterModel: [ printer printerModel ]];
	}
	return dict;
}

#pragma mark Popular : Process Remote Control

+ (NSMutableDictionary*) processRC: (NSMutableDictionary*) dict withSshServer: (AlmostVPNLocation*) sshServer addProfileItemsTo: (NSMutableArray*) profileItems {
	NSString* rcHostName = [ dict objectForKey: @"rcHostName" ];
	if( [ rcHostName length ] != 0 ) {
		NSString* rcTypeString = [ dict objectForKey: @"rcType" ];
		
		AlmostVPNHost* rcHost = [ self getHostWithName: rcHostName forSSHServer: sshServer ];
		[ profileItems addNewObject: rcHost ];
		
		AlmostVPNRemoteControl* rc = (AlmostVPNRemoteControl*)[ rcHost
			childOfClass: [ AlmostVPNRemoteControl class ] 
			andName: rcTypeString 
			createIfNeeded: YES
		];
		NSNumber* rcType = [ NSNumber numberWithInt: 0 ]; // VNC 
		if( [ @"ard" caseInsensitiveCompare: rcTypeString ] == NSOrderedSame ) {
			rcType = [ NSNumber numberWithInt: 1 ];
		} else if( [ @"rdc" caseInsensitiveCompare: rcTypeString ] == NSOrderedSame ) {
			rcType = [ NSNumber numberWithInt: 2 ];
		} else if( [ @"shell" caseInsensitiveCompare: rcTypeString ] == NSOrderedSame ) {
			rcType = [ NSNumber numberWithInt: 3 ];
		}
		[ rc setRcType: rcType ];
	}
	return dict;
}

#pragma mark Popular : Process Web Server 

+ (NSMutableDictionary*) processWebServer: (NSMutableDictionary*) dict withSshServer: (AlmostVPNLocation*) sshServer addProfileItemsTo: (NSMutableArray*) profileItems {
	NSString* webHostName = [ dict objectForKey: @"webHostName" ];
	
	if( [ webHostName length ] != 0 ) {
		BOOL doHTTP = [ dict objectForKey: @"webDoHTTP" ] == nil || [[ dict objectForKey: @"webDoHTTP" ] boolValue ];
		BOOL doHTTPs = [[ dict objectForKey: @"webDoHTTPs" ] boolValue ];

		AlmostVPNHost* webHost = [ self getHostWithName: webHostName forSSHServer: sshServer ];
		[ profileItems addNewObject: webHost ];
		
		if( doHTTP ) {
			AlmostVPNService* httpService = (AlmostVPNService*)[
				webHost
					childOfClass: [ AlmostVPNService class ]
					andName: @"http"
					createIfNeeded: YES				
			];
			[ httpService setPort: @"80" ];
		}
		if( doHTTPs ) {
			AlmostVPNService* httpService = (AlmostVPNService*)[
				webHost
					childOfClass: [ AlmostVPNService class ]
					andName: @"https"
					createIfNeeded: YES				
			];
			[ httpService setPort: @"443" ];
		}
	}
	
	return dict;
}

#pragma mark Popular : Process Drive

+ (NSMutableDictionary*) processDrive: (NSMutableDictionary*) dict withSshServer: (AlmostVPNLocation*) sshServer addProfileItemsTo: (NSMutableArray*) profileItems {
	NSString* driveHostName = [ dict objectForKey: @"driveHostName" ];

	if( [ driveHostName length ] != 0 ) {
		NSString* driveType = [ dict objectForKey: @"driveType" ];
		NSString* driveUserName = [ dict objectForKey: @"driveUserName" ];
		NSString* drivePassword = [ dict objectForKey: @"drivePassword" ];
		NSString* drivePath = [ dict objectForKey: @"drivePath" ];
	
		AlmostVPNHost* driveHost = [ self getHostWithName: driveHostName forSSHServer: sshServer ];

		AlmostVPNDrive* drive = (AlmostVPNDrive*)[ driveHost
			childOfClass: [ AlmostVPNDrive class ]
			andName: [ NSString stringWithFormat: @"%@://%@/%@", driveType, [driveHost name ], drivePath ]
			createIfNeeded: YES
		];
		[ drive setDriveType: driveType ];
		[ drive setDrivePath: drivePath ];
		if( [ driveUserName length ] != 0 ) {
			[[ drive account ] setUserName: driveUserName ];
			if( [ drivePassword length ] != 0 ) {
				[[ drive account ] setUsePassword: [NSNumber numberWithBool: YES ]];
				[[ drive account ] setPassword: drivePassword ];
			}
		}
		[ profileItems addNewObject: driveHost ];		
	}
	
	return dict;
}

#pragma mark Popular : Process E-mail

+ (NSMutableDictionary*) processEmail: (NSMutableDictionary*) dict withSshServer: (AlmostVPNLocation*) sshServer addProfileItemsTo: (NSMutableArray*) profileItems {
	NSString* emailIncomingHostName = [ dict objectForKey: @"emailIncomingHostName" ];
	if( [ emailIncomingHostName length ] != 0 ) {
		AlmostVPNHost* emailHost = [ self getHostWithName: emailIncomingHostName forSSHServer: sshServer ];
		
		NSString* emailIncomingType = [ dict objectForKey: @"emailIncomingType" ];
		emailIncomingType = emailIncomingType == nil ? "pop3" : emailIncomingType;
		NSString* port = @"110";
		if( [ @"pop3" isEqual: emailIncomingType ] ) {
			port = @"110";
		} else if( [ @"pop3s" isEqual: emailIncomingType ] ) {
			port = @"995";
		} else if( [ @"imap" isEqual: emailIncomingType ] ) {
			port = @"143";
		} else if( [ @"imaps" isEqual: emailIncomingType ] ) {
			port = @"993";
		}
		AlmostVPNService* incomingEmailService = (AlmostVPNService*)[
			emailHost
				childOfClass: [ AlmostVPNService class ]
				andName: emailIncomingType
				createIfNeeded: YES				
		];
		[ incomingEmailService setPort: port ];
		[ profileItems addNewObject: emailHost ];
	}
	NSString* emailOutgoingHostName = [ dict objectForKey: @"emailOutgoingHostName" ];
	if( [ emailOutgoingHostName length ] != 0 ) {
		AlmostVPNHost* emailHost =  [ self getHostWithName: emailOutgoingHostName forSSHServer: sshServer ];
		
		AlmostVPNService* outgoingEmailService = (AlmostVPNService*)[
			emailHost
				childOfClass: [ AlmostVPNService class ]
				andName: @"smtp"
				createIfNeeded: YES				
		];
		[ outgoingEmailService setPort: @"25" ];
		[ profileItems addNewObject: emailHost ];
	}
	return dict;
}

#pragma mark Popular : processPopular

+ (NSMutableDictionary*) processPopular: (NSMutableDictionary*) dict  intoProfile: (AlmostVPNProfile*)profile {
	AlmostVPNLocation*	sshServer = [ self processSshServer: dict ];
	
	NSMutableArray*		profileItems = [ NSMutableArray array ];

	dict = [ self processEmail: dict withSshServer: sshServer addProfileItemsTo: profileItems ];
	dict = [ self processDrive: dict withSshServer: sshServer addProfileItemsTo: profileItems ];
	dict = [ self processWebServer: dict withSshServer: sshServer addProfileItemsTo: profileItems ];
	dict = [ self processRC: dict withSshServer: sshServer addProfileItemsTo: profileItems ];
	dict = [ self processPrinter: dict withSshServer: sshServer addProfileItemsTo: profileItems ];
	dict = [ self processFile: dict withSshServer: sshServer addProfileItemsTo: profileItems ];
	
	[ self processProfileItems: profileItems forProfile: profile ];

	return dict;
}

#pragma mark -
#pragma mark Process Command Line

+ (void) processLocalTunnel: (NSString*) tunnelDefinition withSshServer: (AlmostVPNLocation*) sshServer andProfile: (AlmostVPNProfile*) profile {
	NSArray* definitionParts = [ tunnelDefinition componentsSeparatedByString: @":" ];
	NSString* localPort = [ definitionParts objectAtIndex: 0 ];
	NSString* remoteHost = [ definitionParts objectAtIndex: 1 ];
	NSString* remotePort = [ definitionParts objectAtIndex: 2 ];
	
	AlmostVPNHost* serviceHost = nil;
	if( [ @"localhost" isEqual: remoteHost ] || [ @"127.0.0.1" isEqual: remoteHost ] || 
		[ remoteHost isEqual: [ sshServer name ]] ) {
		serviceHost = sshServer;
	} else {
		serviceHost = (AlmostVPNHost*)[ sshServer
			childOfClass: [ AlmostVPNHost class ]
			andName: remoteHost 
			createIfNeeded: YES
		];
	}
	
	int localPortNumber = [ LBService nameToNumber: localPort ];
	NSString* localPortName = [ LBService numberToName: localPortNumber ];	
	
	int remotePortNumber = [ LBService nameToNumber: remotePort ];
	NSString* remotePortName = [ LBService numberToName: remotePortNumber ];
	
	AlmostVPNService* service = (AlmostVPNService*)[
		serviceHost
			childOfClass: [ AlmostVPNService class ]
			andName: remotePortName
			createIfNeeded: YES				
	];
	[ service setPort: [[ NSNumber numberWithInt: remotePortNumber ] stringValue ]];
	
	AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*)[ profile
		childOfClass: [ AlmostVPNTunnel class ] 
		andName: [ NSString stringWithFormat: @"%@@%@", remotePortName, remoteHost ]
		createIfNeeded: YES
	];	
	[ tunnel setReferencedObject: service ];
	[ tunnel setSourcePort:  [[ NSNumber numberWithInt: localPortNumber ] stringValue ] ];
	[ tunnel setSourceLocation: [ AlmostVPNLocalhost sharedInstance ]];
	[ tunnel setUseHostNameAsIs: [ NSNumber numberWithBool: YES ]];
	
	#pragma unused ( localPortName )
}

+ (void) processRemoteTunnel: (NSString*) tunnelDefinition withSshServer: (AlmostVPNLocation*) sshServer andProfile: (AlmostVPNProfile*) profile {
	NSArray* definitionParts = [ tunnelDefinition componentsSeparatedByString: @":" ];
	NSString* remotePort = [ definitionParts objectAtIndex: 0 ];
	NSString* localHost = [ definitionParts objectAtIndex: 1 ];
	NSString* localPort = [ definitionParts objectAtIndex: 2 ];
	
	AlmostVPNHost* serviceHost = nil;
	if( [ @"localhost" isEqual: localHost ] || [ @"127.0.0.1" isEqual: localHost ] || 
		[ localHost isEqual: [[ AlmostVPNLocalhost sharedInstance ] name ]] ) {
		serviceHost = [ AlmostVPNLocalhost sharedInstance ];
	} else {
		serviceHost = (AlmostVPNHost*)[
			[ AlmostVPNLocalhost sharedInstance ]
				childOfClass: [ AlmostVPNHost class ]
				andName: localHost 
				createIfNeeded: YES
		];
	}
	
	int localPortNumber = [ LBService nameToNumber: localPort ];
	NSString* localPortName = [ LBService numberToName: localPortNumber ];	
	
	int remotePortNumber = [ LBService nameToNumber: remotePort ];
	NSString* remotePortName = [ LBService numberToName: remotePortNumber ];
	
	AlmostVPNService* service = (AlmostVPNService*)[
		serviceHost
			childOfClass: [ AlmostVPNService class ]
			andName: localPortName
			createIfNeeded: YES				
	];
	[ service setPort: [[ NSNumber numberWithInt: localPortNumber ] stringValue ]];
	
	AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*)[ profile
		childOfClass: [ AlmostVPNTunnel class ] 
		andName: [ NSString stringWithFormat: @"%@@%@", remotePortName, localHost ]
		createIfNeeded: YES
	];	
	[ tunnel setReferencedObject: service ];	
	[ tunnel setSourcePort: [[ NSNumber numberWithInt: remotePortNumber ] stringValue ] ];
	[ tunnel setSourceLocation: sshServer ];
	
	#pragma unused ( remotePortName )
}

+ (void) processRemoteCommand: (NSString*) commandString withSshServer: (AlmostVPNLocation*) sshServer andProfile: (AlmostVPNProfile*) profile {
	NSArray* commandParts = [ commandString componentsSeparatedByString: @" " ];
	
	AlmostVPNFile* command = (AlmostVPNFile*)[ sshServer
		childOfClass: [ AlmostVPNFile class ]
		andName: [ commandParts objectAtIndex: 0 ]
		createIfNeeded: YES
	];
	[ command setPath: commandString ];
	[ command setFileKind: [ NSNumber numberWithInt: 2 ]]; // script
	[ command setConsole: [ NSNumber numberWithBool: YES ]];
	[ command setX11: [ NSNumber numberWithBool: YES ]];
	
	AlmostVPNFileRef* commandRef = (AlmostVPNFileRef*)[ profile
		childOfClass: [ AlmostVPNFileRef class ]
		andName: [ NSString stringWithFormat: @"%@@%@", [ commandParts objectAtIndex: 0 ], [ sshServer name ]]
		createIfNeeded: YES
	];
	[ commandRef setReferencedObject: command ];
	[ commandRef setDoAfterStart: [ NSNumber numberWithInt: 0 ]];
	[ commandRef setDoThis: [ NSNumber numberWithInt: 3 ]];
	[ commandRef setAndExecute: [ NSNumber numberWithBool: YES ]];
	[ commandRef setDestinationLocation: sshServer ];
	[ commandRef setDestinationPath: commandString ];
}

+ (NSMutableDictionary*) processCommandLine: (NSMutableDictionary*) dict intoProfile: (AlmostVPNProfile*) profile {
	NSDictionary* parsedCommandLine = [ dict objectForKey: @"parsedCommandLine" ];
	NSArray* normalizedOptions = [ parsedCommandLine objectForKey: @"normalizedOptions" ];
	
	NSEnumerator* optionsAndArgs = [ normalizedOptions objectEnumerator ];
	NSString*	null = (NSString*)[ NSNull null ];
	NSString*	option;
	NSString*	arg;
	
	NSString*	userAndHostName = nil;
	NSString*	userName = nil;
	NSString*	hostName = nil;
	NSString*	remoteCommand = nil;
	BOOL		doCompression = NO;
	NSString*	identityFile = nil;
	
	NSMutableArray* localTunnels = [ NSMutableArray array ];
	NSMutableArray* remoteTunnels = [ NSMutableArray array ];
	
	NSString* sshPort = @"22";
	
	while(( option = [ optionsAndArgs nextObject ]) != nil ) {
		arg = [ optionsAndArgs nextObject ];
		// NSLog( @"%@ - %@", option, arg );
		
		if( option == null ) { 
			if( userAndHostName == nil ) {// this must be user[@hostname]
				userAndHostName = arg;
			} else {
				remoteCommand = arg;
			}
		} else {
			if( [ @"-L" isEqual: option ] ) {
				[ localTunnels addObject: arg ];
			} else if ( [ @"-R" isEqual: option ] ) {
				[ remoteTunnels addObject: arg ];
			} else if( [ @"-l" isEqual: option ] ) {
				userName = arg;
			} else if( [ @"-C" isEqual: option ] ) {
				doCompression = YES;
			} else if( [ @"-i" isEqual: option ] ) {
				identityFile = arg;
			} else if( [ @"-p" isEqual: option ] ) {
				sshPort = arg;
			}
		}
	}
	
	NSArray* userAndHostNameParts = [ userAndHostName componentsSeparatedByString: @"@" ];
	switch( [ userAndHostNameParts count ] ) {
		case 1 : // just a host name
			hostName = userAndHostName;
			break;
		case 2 : // user namd + host name
			userName = userName == nil ? [ userAndHostNameParts objectAtIndex: 0 ] : userName ;
			hostName = [ userAndHostNameParts objectAtIndex: 1 ];
	}
	userName = userName == nil ? [[ AlmostVPNConfiguration sharedInstance ] userName ] : userName;
	[ dict setObject: hostName forKey: @"sshServerHostName" ];
	[ dict setObject: userName forKey: @"sshServerUserName" ];
	
	AlmostVPNIdentity* identity = (AlmostVPNIdentity*)[ AlmostVPNObject findObjectOfClass: [ AlmostVPNIdentity class ] withProperty: @"path" equalTo: identityFile ];
	if( identity != nil ) {
		[ dict setObject: identity forKey: @"sshServerIdentity" ]; 
	}
	
	AlmostVPNLocation*	sshServer = [ self processSshServer: dict ];	
	[ sshServer setPort: sshPort ];
	
	NSString* secretWord = [ dict objectForKey: @"commandLineSecretWord" ];
	if( [ secretWord length ] > 0 ) {
		[[ sshServer account ] setPassword: secretWord ];
	}

	NSEnumerator* lTunnels = [ localTunnels objectEnumerator ];
	NSString* tunnelDefinition;
	
	while(( tunnelDefinition = [ lTunnels nextObject ] ) != nil ) {
		[ self processLocalTunnel: tunnelDefinition withSshServer: sshServer andProfile: profile ];
	}
	
	NSEnumerator* rTunnels = [ remoteTunnels objectEnumerator ];
	while(( tunnelDefinition = [ rTunnels nextObject ] ) != nil ) {
		[ self processRemoteTunnel: tunnelDefinition withSshServer: sshServer andProfile: profile ];
	}
	
	if( remoteCommand != nil ) {
		[ self processRemoteCommand: remoteCommand withSshServer: sshServer andProfile: profile ];
	}
	
	return dict;
}

#pragma mark -
#pragma mark Process Import
+ (BOOL)importSSHAgentTunnel: (NSMutableDictionary*) dict intoProfile: (AlmostVPNProfile*) profile {
	NSString* tunnelFilePath = [ dict objectForKey: @"path" ];
	[ dict setObject: [ NSNumber numberWithBool: NO ] forKey: @"checked" ];
	
	NSData* tunnelData = [ NSData dataWithContentsOfFile: tunnelFilePath ];
	SSHTunnel* sshTunnel = [NSUnarchiver unarchiveObjectWithData: tunnelData];

	BOOL warnings = NO;
	NSString* command = [ NSString stringWithFormat:
		@"ssh -L %d:%@:%d -p %d %@@%@",
		[ sshTunnel localPort ],
		[ sshTunnel remoteHost ],
		[ sshTunnel remotePort ],
		[ sshTunnel tunnelPort ],
		[ sshTunnel hostAccount ],
		[ sshTunnel tunnelHost ]
	];

	[ dict setObject: [ self parseCommandLine: command ] forKey: @"parsedCommandLine" ];
	dict = [ self processCommandLine: dict intoProfile: profile ];

	warnings = [[ dict objectForKey: @"warnings" ] boolValue ];
	
	return warnings;
}

/*
0		<string>Schnitzel</string>
1		<string>schnitzel</string>
2		<string>us</string>
3		<string>SSH 2</string>
4		<string>3des</string>
5		<string>80</string>
6		<string>40</string>
7		<string>1</string>
8		<string>0</string>
9		<string>0</string>
10		<string>0</string>
11		<string>1</string>
12		<string>1</string>
13		<string>1</string>
14		<string>1</string>
15		<string>22</string>
16		<string>Monaco</string>
17		<string>10</string>
18		<string>/bin/bash</string>
19		<string>custom options</string>
20		<string></string>
21		<string></string>
22		<string></string>
23		<string>0</string>
24		<string></string>
25		<string>0</string>
26		<string>Unicode (UTF-8)</string>
27		<string>1</string>
28		<string>Main</string>
29		<string>0</string>
30		<array>
			<array>
	0			<string>web</string>
	1			<string>8080</string>
	2			<string>www.cnn.com</string>
	3			<string>80</string>
			</array>
		</array>
31		<string>0</string>
32		<string>theCommand</string>
*/
		
+ (BOOL)importJellyfiSSH: (NSMutableDictionary*) dict intoProfile: (AlmostVPNProfile*) profile {
	NSString* pListPath = [ dict objectForKey: @"path" ];
	[ dict setObject: [ NSNumber numberWithBool: NO ] forKey: @"checked" ];
	NSArray* bookmarks = [ NSArray arrayWithContentsOfFile: [ pListPath stringByExpandingTildeInPath ]];
	
	BOOL warnings = NO;
	for( int i = 0; i < [ bookmarks count ]; i++ ) {
		NSArray* bookmark = [ bookmarks objectAtIndex: i ];
		NSMutableString* command = [ NSMutableString stringWithFormat: 
			@"ssh %@@%@ -p %@ %@", [ bookmark objectAtIndex: 2 ], [ bookmark objectAtIndex: 1 ], [ bookmark objectAtIndex: 15 ], [ bookmark objectAtIndex: 19 ]
		];
		NSArray* tunnels = [ bookmark objectAtIndex: 30 ];
		for( int j = 0; j < [ tunnels count ]; j++ ) {
			NSArray* tunnel = [ tunnels objectAtIndex: j ];
			if( [[ tunnel objectAtIndex: 1 ] length ] == 0 ) {
				continue;
			}
			[ command appendFormat: @" -L %@:%@:%@", [ tunnel objectAtIndex: 1 ], [ tunnel objectAtIndex: 2 ], [ tunnel objectAtIndex: 3 ]];
		}
		if( [[ bookmark objectAtIndex: 32 ] length ] == 0 ) {
			[ command appendFormat: @" %@", [ bookmark objectAtIndex: 18 ]];
		} else {
			[ command appendFormat: @" %@", [ bookmark objectAtIndex: 32 ]];
		}
		[ dict setObject: [ self parseCommandLine: command ] forKey: @"parsedCommandLine" ];
		[ self processCommandLine: dict intoProfile: profile ];
	}
	
	warnings = [[ dict objectForKey: @"warnings" ] boolValue ];
	
	return warnings;
}

+ (BOOL)importSSHTunnelManager: (NSMutableDictionary*) sshtDict intoProfile: (AlmostVPNProfile*) profile {
	NSString* pListPath = [ sshtDict objectForKey: @"path" ];
	[ sshtDict setObject: [ NSNumber numberWithBool: NO ] forKey: @"checked" ];
	NSDictionary* preferences = [ NSDictionary dictionaryWithContentsOfFile: [ pListPath stringByExpandingTildeInPath ]];
	
	NSArray* sshtmAccounts = [ preferences objectForKey: @"tunnels" ];
		
	BOOL warnings = NO;
	BOOL useProfilePerAccount = [ profile isDefault ];
	
	for( int i = 0; i < [ sshtmAccounts count ]; i++ ) {
		NSDictionary* sshtmAccount = [ sshtmAccounts objectAtIndex: i ];
		BOOL autoStart = useProfilePerAccount & [[ sshtmAccount objectForKey: @"autoConnect" ] boolValue ];
		NSString* sshServerHostName = [ sshtmAccount objectForKey: @"connHost" ];
		
		profile = ( ! useProfilePerAccount ) ? 
			profile : 
			(AlmostVPNProfile*)[[ AlmostVPNConfiguration sharedInstance ] 
				childOfClass: [ AlmostVPNProfile class ]
				andName: [ NSString stringWithFormat: @"%@ (SSHTM)", sshServerHostName ]
				createIfNeeded: YES
			];
			
		if( autoStart ) {
			[ profile setRunMode: _RUN_AT_START_ ];
		}
		
		NSString* sshServerUserName = [ sshtmAccount objectForKey: @"connUser" ];
		NSString* sshServerPort = [ sshtmAccount objectForKey: @"connPort" ];
		
		BOOL doCompression = [[ sshtmAccount objectForKey: @"compression" ] boolValue ];
		#pragma unused (doCompression)
				
		if( [[ sshtmAccount objectForKey: @"v1" ] boolValue ] ) {
			warnings = YES;
			[AlmostVPNConfigurationController logMessage: @"from SSHTM : ssh v 1 is not supported" from: @"import" atLevel: @"900" ];
		}
		
		if( [[ sshtmAccount objectForKey: @"socks4" ] boolValue ] ) {
			NSString* socks4p = [ sshtmAccount objectForKey: @"socks4p" ];
			#pragma unused( socks4p )
//			warnings = YES;
//			[AlmostVPNConfigurationController logMessage: @"from SSHTM : dynamic proxy (-D) functionality not supported yet" from: @"import" atLevel: @"900" ];
		}
		
		AlmostVPNLocation* sshServer = (AlmostVPNLocation*)[ [ AlmostVPNConfiguration sharedInstance ] 
			childOfClass: [ AlmostVPNLocation class ]
			andName: sshServerHostName
			createIfNeeded: YES
		];
		[[ sshServer account ] setUserName: sshServerUserName ];
		[ sshServer setPort: sshServerPort ];
					
		NSArray* sshtmTunnels = [ sshtmAccount objectForKey: @"tunnelsLocal" ];
		for( int j = 0; j < [ sshtmTunnels count ]; j++ ) {
			NSDictionary* sshtmTunnel = [ sshtmTunnels objectAtIndex: j ];
			NSString* localPort = [sshtmTunnel objectForKey: @"port" ];
			int localPortNumber = [ LBService nameToNumber: localPort ];
			NSString* localPortName = [ LBService numberToName: localPortNumber ];
			#pragma unused( localPortName )
			
			NSString* remoteHost = [ sshtmTunnel objectForKey: @"host" ];
			NSString* remotePort = [ sshtmTunnel objectForKey: @"hostport" ];
			int remotePortNumber = [ LBService nameToNumber: remotePort ];
			NSString* remotePortName = [ LBService numberToName: remotePortNumber ];
			
			AlmostVPNHost* serviceHost = [ self getHostWithName: remoteHost forSSHServer: sshServer ];
			
			AlmostVPNService* service = (AlmostVPNService*)[ serviceHost
				childOfClass: [ AlmostVPNService class ] 
				andName: remotePortName 
				createIfNeeded: YES
			];
			[ service setPort: [[ NSNumber numberWithInt: remotePortNumber ] stringValue ]];
			
			AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*) [ profile
				childOfClass: [ AlmostVPNTunnel class ]
				andName: [ NSString stringWithFormat: @"%@@%@", remotePortName, remoteHost ]
				createIfNeeded: YES
			];
			[ tunnel setReferencedObject: service ];
			[ tunnel setSourceLocation: [ AlmostVPNLocalhost sharedInstance ]];
			[ tunnel setSourcePort: [[ NSNumber numberWithInt: localPortNumber ] stringValue ]];
		}
		sshtmTunnels = [ sshtmAccount objectForKey: @"tunnelsRemote" ];
		for( int j = 0; j < [ sshtmTunnels count ]; j++ ) {
			NSDictionary* sshtmTunnel = [ sshtmTunnels objectAtIndex: j ];
			NSString* remotePort = [ sshtmTunnel objectForKey: @"port" ];
			int remotePortNumber = [ LBService nameToNumber: remotePort ];
			NSString* remotePortName = [ LBService numberToName: remotePortNumber ];
			#pragma unused( remotePortName )

			NSString* localPort = [sshtmTunnel objectForKey: @"hostport" ];
			int localPortNumber = [ LBService nameToNumber: localPort ];
			NSString* localPortName = [ LBService numberToName: localPortNumber ];
			
			NSString* localHost = [ sshtmTunnel objectForKey: @"host" ];
			
			AlmostVPNHost* serviceHost = [ self getHostWithName: localHost forSSHServer: [ AlmostVPNLocalhost sharedInstance ]];
			
			AlmostVPNService* service = (AlmostVPNService*)[ serviceHost
				childOfClass: [ AlmostVPNService class ] 
				andName: localPortName 
				createIfNeeded: YES
			];
			[ service setPort: [[ NSNumber numberWithInt: localPortNumber ] stringValue ]];
			
			AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*) [ profile
				childOfClass: [ AlmostVPNTunnel class ]
				andName: [ NSString stringWithFormat: @"%@@%@", localPortName, localHost ]
				createIfNeeded: YES
			];
			[ tunnel setReferencedObject: service ];
			[ tunnel setSourceLocation: sshServer ];
			[ tunnel setSourcePort: [[ NSNumber numberWithInt: remotePortNumber ] stringValue ]];
		}
	}
	
	return warnings;
}

+ (BOOL)importSSHKeychain: (NSMutableDictionary*) sshkcDict intoProfile: (AlmostVPNProfile*) profile {
	NSString* pListPath = [ sshkcDict objectForKey: @"path" ];
	[ sshkcDict setObject: [ NSNumber numberWithBool: NO ] forKey: @"checked" ];
	
	NSDictionary* preferences = [ NSDictionary dictionaryWithContentsOfFile: [ pListPath stringByExpandingTildeInPath ] ];
	
	NSArray* sshkcAccounts = [ preferences objectForKey: @"Tunnels" ];

	for( int i = 0; i < [ sshkcAccounts count ]; i++ ) {
		NSDictionary* sshkcAccount = [ sshkcAccounts objectAtIndex: i ];

		NSString* sshServerHostName = [ sshkcAccount objectForKey: @"TunnelHostname" ];
		NSString* sshServerUserName = [ sshkcAccount objectForKey: @"TunnelUser" ];
		NSString* sshServerPort = [ sshkcAccount objectForKey: @"TunnelPort" ];
		
		BOOL doCompression = [ @"YES" isEqual: [ sshkcAccount objectForKey: @"Compression" ]];
		#pragma unused( doCompression )
				
		AlmostVPNLocation* sshServer = (AlmostVPNLocation*)[ [ AlmostVPNConfiguration sharedInstance ] 
			childOfClass: [ AlmostVPNLocation class ]
			andName: sshServerHostName
			createIfNeeded: YES
		];
		[[ sshServer account ] setUserName: sshServerUserName ];
		[ sshServer setPort: sshServerPort ];

		NSArray* sshkcTunnels = [ sshkcAccount objectForKey: @"LocalPortForwards" ];
		for( int j = 0; j < [ sshkcTunnels count ]; j++ ) {
			NSDictionary* sshkcTunnel = [ sshkcTunnels objectAtIndex: j ];
			
			
			NSString* localPort = [sshkcTunnel objectForKey: @"LocalPort" ];
			int localPortNumber = [ LBService nameToNumber: localPort ];
			NSString* localPortName = [ LBService numberToName: localPortNumber ];
			#pragma unused( localPortName )
			
			NSString* remoteHost = [ sshkcTunnel objectForKey: @"RemoteHost" ];
			NSString* remotePort = [ sshkcTunnel objectForKey: @"RemotePort" ];
			int remotePortNumber = [ LBService nameToNumber: remotePort ];
			NSString* remotePortName = [ LBService numberToName: remotePortNumber ];
			
			AlmostVPNHost* serviceHost = [ self getHostWithName: remoteHost forSSHServer: sshServer ];
			
			AlmostVPNService* service = (AlmostVPNService*)[ serviceHost
				childOfClass: [ AlmostVPNService class ] 
				andName: remotePortName 
				createIfNeeded: YES
			];
			[ service setPort: [[ NSNumber numberWithInt: remotePortNumber ] stringValue ]];
			
			AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*) [ profile
				childOfClass: [ AlmostVPNTunnel class ]
				andName: [ NSString stringWithFormat: @"%@@%@", remotePortName, remoteHost ]
				createIfNeeded: YES
			];
			[ tunnel setReferencedObject: service ];
			[ tunnel setSourceLocation: [ AlmostVPNLocalhost sharedInstance ]];
			[ tunnel setSourcePort: [[ NSNumber numberWithInt: localPortNumber ] stringValue ]];			
		}
		sshkcTunnels = [ sshkcAccount objectForKey: @"RemotePortForwards" ];
		for( int j = 0; j < [ sshkcTunnels count ]; j++ ) {
			NSDictionary* sshkcTunnel = [ sshkcTunnels objectAtIndex: j ];

			NSString* remotePort = [ sshkcTunnel objectForKey: @"RemotePort" ];
			int remotePortNumber = [ LBService nameToNumber: remotePort ];
			NSString* remotePortName = [ LBService numberToName: remotePortNumber ];
			#pragma unused( remotePortName )

			NSString* localPort = [sshkcTunnel objectForKey: @"LocalPort" ];
			int localPortNumber = [ LBService nameToNumber: localPort ];
			NSString* localPortName = [ LBService numberToName: localPortNumber ];
			
			NSString* localHost = [ sshkcTunnel objectForKey: @"LocalHost" ];
			
			AlmostVPNHost* serviceHost = [ self getHostWithName: localHost forSSHServer: [ AlmostVPNLocalhost sharedInstance ]];
			
			AlmostVPNService* service = (AlmostVPNService*)[ serviceHost
				childOfClass: [ AlmostVPNService class ] 
				andName: localPortName 
				createIfNeeded: YES
			];
			[ service setPort: [[ NSNumber numberWithInt: localPortNumber ] stringValue ]];
			
			AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*) [ profile
				childOfClass: [ AlmostVPNTunnel class ]
				andName: [ NSString stringWithFormat: @"%@@%@", localPortName, localHost ]
				createIfNeeded: YES
			];
			[ tunnel setReferencedObject: service ];
			[ tunnel setSourceLocation: sshServer ];
			[ tunnel setSourcePort: [[ NSNumber numberWithInt: remotePortNumber ] stringValue ]];
		}
	}
	
	return NO;
}

#pragma mark Import : AlmostVPN 0.9	

+ (void) importKnownServices: (NSDictionary*) preferences {
	NSArray* knownServices = [ preferences objectForKey: @"known-services" ];
	[ LBService rememberFromPreferences: knownServices ];
}

+ (void) importKnownServers: (NSDictionary*) preferences {
	NSArray* knownServers = [ preferences objectForKey: @"known-servers" ];
	[ LBServer rememberFromPreferences: knownServers ];
}

+ (BOOL) importAlmostVPN09Accounts: (NSDictionary*) preferences {
	NSArray* accounts = [ preferences objectForKey: @"accounts" ];
	NSEnumerator* accountsEnumerator = [ accounts objectEnumerator ];
	NSDictionary* accountDict = nil;
	
	BOOL warnings = NO;
	while(( accountDict = [ accountsEnumerator nextObject ]) != nil ) {
		NSString* uuid = [ accountDict objectForKey: @"uuid" ];
		if( [ AlmostVPNObject findObjectWithUUID: uuid ] != nil ) {
			continue;
		}
		AlmostVPNLocation* sshServer = (AlmostVPNLocation*)[ AlmostVPNObject newObjectOfClass: [ AlmostVPNLocation class ] withUUID: uuid ];
		
		[[ AlmostVPNConfiguration sharedInstance ] addChild: sshServer ];
		
		[ sshServer setObject: [ accountDict objectForKey: @"hostName" ] forKey: @"name" ];
		if( ! [ @"noProxy" isEqual: [ accountDict objectForKey: @"proxy" ]] ) {
			warnings = YES;
			[AlmostVPNConfigurationController logMessage: [ NSString stringWithFormat: @"from AlmostVPN : account %@ : connection via proxy is not supported yet", [ sshServer name ]] from: @"import" atLevel: @"900" ];
		}
		[[ sshServer account ] setUserName: [ accountDict objectForKey: @"userName" ]];
		BOOL usePassword = [ @"true" isEqual: [ accountDict objectForKey: @"use-password" ]];
		[[ sshServer account ] setUsePassword: [ NSNumber numberWithBool: usePassword ]];
		if( usePassword ) {
			NSString* password = [ KeyChainAdapter retriveSSHPasswordForAccount: [[ sshServer account ] userName ] onServer: [ sshServer name ]];
			[[ sshServer account ] setPassword: password ];
		}
		
		NSDictionary* options = [ accountDict objectForKey: @"options" ];
		NSString* port = [ options objectForKey: @"-p" ];
		[ sshServer setPort: port == nil ? @"22" : port ];
		
//		if( [ options objectForKey: @"-D" ] != nil ) {
//			warnings = YES;
//			[AlmostVPNConfigurationController logMessage: [ NSString stringWithFormat: @"from AlmostVPN : account %@ : 'dynamic' port forwarding (-D) is not supported yet", [ sshServer name ]] from: @"import" atLevel: @"900" ];
//		}
		NSString* identityPath = [ options objectForKey: @"-i" ];

		if( identityPath != nil ) {
			identityPath = [ identityPath stringByAbbreviatingWithTildeInPath ];
			AlmostVPNIdentity* identity = (AlmostVPNIdentity*)[ AlmostVPNObject findObjectOfClass: [ AlmostVPNIdentity class ] withProperty: @"path" equalTo: identityPath ];
			if( identity == nil ) {
				warnings = YES;
				[AlmostVPNConfigurationController logMessage: [ NSString stringWithFormat: @"from AlmostVPN : account %@ : can not find identity file %@", [ sshServer name ], identityPath ] from: @"import" atLevel: @"900" ];
			} else {
				[ sshServer setIdentity: identity ];
			}
		}
		NSString* extraOptions = [ accountDict objectForKey: @"extraOptions" ];
		if( [ extraOptions rangeOfString: @"-1" ].location != NSNotFound ) {
			warnings = YES;
			[AlmostVPNConfigurationController logMessage: [ NSString stringWithFormat: @"from AlmostVPN : account %@ : SSH v 1 is not supported", [ sshServer name ]] from: @"import" atLevel: @"900" ];
		}		
	}
	
	return warnings;
}

+ (BOOL) importAlmostVPN09Connections: (NSDictionary*) properties {
	NSArray* connections = [ properties objectForKey: @"connections" ];
	NSEnumerator* connectionsEnumerator = [ connections objectEnumerator ];
	NSDictionary* connectionDict = nil;
	
	BOOL warnings = NO;
	while(( connectionDict = [ connectionsEnumerator nextObject ]) != nil ) {
		NSString* accountUuid = [ connectionDict objectForKey: @"accountUuid" ];
		NSString* serverName = [ connectionDict objectForKey: @"serverName" ];
		NSString* serviceName = [ connectionDict objectForKey: @"serviceName" ];
		
		AlmostVPNLocation* sshServer = (AlmostVPNLocation*)[ AlmostVPNObject findObjectWithUUID: accountUuid ];
		if( sshServer == nil ) {		
			warnings = YES;
			[AlmostVPNConfigurationController 
				logMessage: [ NSString stringWithFormat: @"from AlmostVPN : connection %@:%@: can not find the server", serverName, serviceName ] 
				from: @"import" atLevel: @"900" ];
		} else {
			AlmostVPNHost* serviceHost = [ self getHostWithName: serverName forSSHServer: sshServer ];
			int serviceNumber = [ LBService nameToNumber: serviceName ];
			serviceName = [ LBService numberToName: serviceNumber ];
			AlmostVPNService* service = (AlmostVPNService*)[AlmostVPNObject newObjectOfClass: [ AlmostVPNService class ] withUUID: [ connectionDict objectForKey: @"uuid" ]];
			[ serviceHost addChild: service ];
			[ service setName: serviceName ];
			[ service setPort: [[ NSNumber numberWithInt: serviceNumber ] stringValue ]];
		}
	}
	return warnings;
}

+ (BOOL) importAlmostVPN09Drives: (NSDictionary*) properties {
	NSArray* drives = [ properties objectForKey: @"drives" ];
	NSEnumerator* drivesEnumerator = [ drives objectEnumerator ];
	NSDictionary* driveDict = nil;
	
	BOOL warnings = NO;
	while(( driveDict = [ drivesEnumerator nextObject ]) != nil ) {
		NSString* accountUuid = [ driveDict objectForKey: @"accountUuid" ];
		NSString* uuid = [ driveDict objectForKey: @"uuid" ];
		NSString* serverName = [ driveDict objectForKey: @"serverName" ];
		NSString* type = [ driveDict objectForKey: @"type" ];
		NSString* path = [ driveDict objectForKey: @"path" ];
		NSString* userName = [ driveDict objectForKey: @"userName" ];
		
		AlmostVPNLocation* sshServer = (AlmostVPNLocation*)[ AlmostVPNObject findObjectWithUUID: accountUuid ];
		if( sshServer == nil ) {		
			warnings = YES;
			[AlmostVPNConfigurationController 
				logMessage: [ NSString stringWithFormat: @"from AlmostVPN : drive %@:%@/%@: can not find the server", type, serverName, path ] 
				from: @"import" atLevel: @"900" ];
		} else {
			AlmostVPNHost* driveHost = [ self getHostWithName: serverName forSSHServer: sshServer ];
			AlmostVPNDrive* drive = (AlmostVPNDrive*)[ AlmostVPNObject newObjectOfClass: [ AlmostVPNDrive class ] withUUID: uuid ];
			[ driveHost addChild: drive ];
			[ drive setDriveType: type ];
			[ drive setDrivePath: path ];
			if( userName != nil ) {
				[[ drive account ] setUserName: userName ];
				NSString* password = [ KeyChainAdapter 
					retrivePasswordOfType:   ( [ @"AFP" isEqual: type ] ? kSecProtocolTypeAFP : kSecProtocolTypeSMB ) 
					forAccount: userName 
					onServer: serverName 
					forPath: nil
				];
				if( password != nil ) {	
					[[ drive account ] setUsePassword: [ NSNumber numberWithBool: YES ]];
					[[ drive account ] setPassword: password ];
				}
			}
		}						
	}
	
	return warnings;
}

+ (BOOL) importAlmostVPN09Tunnels: (NSDictionary*) properties {
	NSArray* tunnels = [ properties objectForKey: @"tunnels" ];
	NSEnumerator* tunnelsEnumerator = [ tunnels objectEnumerator ];
	NSDictionary* tunnelDict = nil;
	
	BOOL warnings = NO;
	while(( tunnelDict = [ tunnelsEnumerator nextObject ]) != nil ) {
		NSString* accountUuid = [ tunnelDict objectForKey: @"accountUuid" ];
		NSString* targetHost = [ tunnelDict objectForKey: @"targetHost" ];
		NSString* fromPort = [ tunnelDict objectForKey: @"fromPort" ];
		NSString* toPort = [ tunnelDict objectForKey: @"toPort" ];
		BOOL outgoing = [ @"true" isEqual: [ tunnelDict objectForKey: @"outgoing" ]];
		
		AlmostVPNLocation* sshServer = (AlmostVPNLocation*)[ AlmostVPNObject findObjectWithUUID: accountUuid ];
		if( sshServer == nil ) {		
			warnings = YES;
			[AlmostVPNConfigurationController 
				logMessage: [ NSString stringWithFormat: @"from AlmostVPN : tunnel %@:%@:%@: can not find the server", fromPort, targetHost, toPort ] 
				from: @"import" atLevel: @"900" ];
		} else {
			AlmostVPNHost* serviceHost = outgoing ?
				[ self getHostWithName: targetHost forSSHServer: sshServer ] :
				[ AlmostVPNLocalhost sharedInstance ];
				
			int serviceNumber = [ LBService nameToNumber: toPort ];
			NSString* serviceName = [ LBService numberToName: serviceNumber ];
			
			AlmostVPNService* service = (AlmostVPNService*)[ serviceHost
				childOfClass: [ AlmostVPNService class ] andName: serviceName createIfNeeded: YES
			];
			[ service setPort: [[ NSNumber numberWithInt: serviceNumber ] stringValue ]];
				
			AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*)[ AlmostVPNObject newObjectOfClass: [ AlmostVPNTunnel class ] withUUID: [ tunnelDict objectForKey: @"uuid" ]];
			[ tunnel setReferencedObject: service ];
			[ tunnel setSourceLocation: outgoing ? [ AlmostVPNLocalhost sharedInstance ] : sshServer ];
			int fromPortNumber = [ LBService nameToNumber: fromPort ];
			[ tunnel setSourcePort: [[ NSNumber numberWithInt: fromPortNumber ] stringValue ]];			
			[ tunnel setUseHostNameAsIs: [ NSNumber numberWithBool: YES ]];
		}
	}
	return warnings;
}

+ (BOOL) importAlmostVPN09Profiles: (NSDictionary*) properties {
	NSArray* profiles = [ properties objectForKey: @"profiles" ];
	NSEnumerator* profilesEnumerator = [ profiles objectEnumerator ];
	NSDictionary* profileDict = nil;
	BOOL warnings = NO;
	
	while(( profileDict = [ profilesEnumerator nextObject ]) != nil ) {
		NSString* profileName = [ profileDict objectForKey: @"name" ];
		
		AlmostVPNProfile* profile = (AlmostVPNProfile*)[
			[ AlmostVPNConfiguration sharedInstance ] 
			childOfClass: [ AlmostVPNProfile class ]
			andName: profileName
			createIfNeeded: YES
		];
		
		[ profile setObject: profileName forKey: @"name" ];
		// process "connections"
			NSArray* connections = [ profileDict objectForKey: @"connections" ];
			NSEnumerator* connectionsEnumerator = [ connections objectEnumerator ];
			NSString* connectionUUID = nil;
			while(( connectionUUID = [ connectionsEnumerator nextObject ] ) != nil ) {
				AlmostVPNService* targetService = (AlmostVPNService*)[ AlmostVPNObject findObjectWithUUID: connectionUUID ];
				if( targetService == nil ) {
					warnings = YES;
					[ AlmostVPNConfigurationController 
						logMessage: [NSString stringWithFormat: @"from AlmostVPN : profile %@ : fail to locate connection %@", profileName, connectionUUID ] 
						from: @"import" atLevel: @"900" ];
				} else {
					AlmostVPNHost* targetHost = (AlmostVPNHost*)[ targetService parent ];
					AlmostVPNHostAlias* hostAlias = (AlmostVPNHostAlias*)[ profile childOfClass: [ AlmostVPNHostAlias class ] andName: [targetHost name] createIfNeeded: NO ];
					if( hostAlias != nil ) {
						continue;
					}
					hostAlias = (AlmostVPNHostAlias*)[ profile childOfClass: [ AlmostVPNHostAlias class ] andName: [targetHost name] createIfNeeded: YES ];
					[ hostAlias setReferencedObject: targetHost ];
					[ hostAlias setAliasName: [ targetHost name ]];
					[ hostAlias setAutoAliasAddress: [ NSNumber numberWithBool: YES ]];
				}
			}
		// process drives
			NSArray* drives = [ profileDict objectForKey: @"drives" ];
			NSEnumerator* drivesEnumerator = [ drives objectEnumerator ];
			NSString* driveUUID = nil;
			while(( driveUUID = [ drivesEnumerator nextObject ] ) != nil ) {									
				AlmostVPNDrive* drive = (AlmostVPNDrive*)[ AlmostVPNObject findObjectWithUUID: driveUUID ];
				if( drive == nil ) {
					warnings = YES;
					[ AlmostVPNConfigurationController 
						logMessage: [NSString stringWithFormat: @"from AlmostVPN : profile %@ : fail to locate drive %@", profileName, driveUUID ] 
						from: @"import" atLevel: @"900" ];
				} else {
					AlmostVPNDriveRef* driveRef = (AlmostVPNDriveRef*)[	profile
						childOfClass: [ AlmostVPNDriveRef class ]
						andName: [ NSString stringWithFormat: @"%@://%@/%@", [ drive driveType ], [[ drive parent ] name ], [drive drivePath ]] 
						createIfNeeded: YES
					];
					[ driveRef setReferencedObject: drive ];
					[ driveRef setUseBonjour: [ NSNumber numberWithBool: NO ]];
					[ driveRef setMountOnStart: [ NSNumber numberWithBool: YES ]];
				}
			}
		// process tunneles
			NSArray* tunnels = [ profileDict objectForKey: @"tunnels" ];
			NSEnumerator* tunnelsEnumerator = [ tunnels objectEnumerator ];
			NSString* tunnelUUID = nil;
			while(( tunnelUUID = [ tunnelsEnumerator nextObject ] ) != nil ) {
				
				AlmostVPNTunnel* tunnel = (AlmostVPNTunnel*)[ AlmostVPNObject findObjectWithUUID: tunnelUUID ];
				if( tunnel == nil ) {
					warnings = YES;
					[ AlmostVPNConfigurationController 
						logMessage: [NSString stringWithFormat: @"from AlmostVPN : profile %@ : fail to locate tunnel %@", profileName, tunnelUUID ] 
						from: @"import" atLevel: @"900" ];
				} else {
					if( [ tunnel parent ] != nil ) {
						tunnel = [ AlmostVPNObject objectWithObject: tunnel ];
					}
					[ profile addChild: tunnel ];
				}
			}
	}
	
	return warnings;
}

+ (BOOL)importAlmostVPN09: (NSMutableDictionary*) dict intoProfile: (AlmostVPNProfile*) profile {
	NSString* pListPath = [ dict objectForKey: @"path" ];
	NSDictionary* preferences = [ NSDictionary dictionaryWithContentsOfFile: [ pListPath stringByExpandingTildeInPath ] ];
	[ dict setObject: [ NSNumber numberWithBool: NO ] forKey: @"checked" ];
	
	BOOL warnings = NO;

	[ self importKnownServers: preferences ];
	[ self importKnownServices: preferences ];
	
	warnings = [ self importAlmostVPN09Accounts: preferences ] || warnings;
	warnings = [ self importAlmostVPN09Connections: preferences ] || warnings;
	warnings = [ self importAlmostVPN09Drives: preferences ] || warnings;
	warnings = [ self importAlmostVPN09Tunnels: preferences ] || warnings;
	warnings = [ self importAlmostVPN09Profiles: preferences ] || warnings;
	
	return warnings;
}

+ (SEL) guessImporter: (NSMutableDictionary*) dict {
	NSString* path = [ dict objectForKey: @"path" ];
	if( [ path rangeOfString: @"sshtunnelmanager" ].location != NSNotFound ) {
		return @selector(importSSHTunnelManager:intoProfile:);
	} else if ( [ path rangeOfString: @"SSHKeychain" ].location != NSNotFound ) {
		return @selector(importSSHKeychain:intoProfile:);
	} else if ( [ path rangeOfString: @"com.leapingbytes.AlmostVPN.plist" ].location != NSNotFound ) {
		return @selector(importAlmostVPN09:intoProfile:);
	} else if ( [ path rangeOfString: @"jellyfiSSHr12_bm.xml" ].location != NSNotFound ) {
		return @selector(importJellyfiSSH:intoProfile:);
	} else if ( [ path rangeOfString: @".tunnel" ].location != NSNotFound ) {
		return @selector(importSSHAgentTunnel:intoProfile:);
	} else {
		[AlmostVPNConfigurationController logMessage: [ NSString stringWithFormat: @"can not guess importer for %@", path ] from: @"import" atLevel: @"900" ];
		return nil;
	}
}

+ (NSMutableDictionary*) processImport: (NSMutableDictionary*) dict intoProfile: (AlmostVPNProfile*) profile {
	BOOL warnings = NO;
	NSArray* imports = nil;

	imports = [ dict objectForKey: @"imports" ];

	NSEnumerator* importsEnumerator = [ imports objectEnumerator ];
	NSMutableDictionary* importDescription;
	
	while(( importDescription = [ importsEnumerator nextObject ] ) != nil ) {
		if( [[ importDescription objectForKey: @"checked" ] boolValue ] ) {
			[ importDescription setObject: [ profile name ] forKey: @"profileName" ];
			SEL importer = [ self guessImporter: importDescription ];
			if( importer == nil ) {
				warnings = YES;
			} else {
				warnings = [ self performSelector: importer withObject: importDescription withObject: profile ] || warnings;				
			}
		}
	}
	
	if( warnings ) {
		NSRunAlertPanel( @"Problems with import", @"Look into Log file (Monitor/Log) for more information", @"OK", nil, nil );				
	}
	return dict;
}

#pragma mark -
#pragma mark Public 

+ (NSMutableDictionary*) processQuickConfigDictionary: (NSMutableDictionary*) dict {
	// NSLog( @"QuickConfig = \n%@", dict );

	AlmostVPNProfile*	profile = [ self processProfile: dict ];	
	
	NSString* selectedTab = [ dict objectForKey: @"selectedTab" ];
	selectedTab = selectedTab == nil ? @"popular" : selectedTab;
	
	if( [ @"popular" isEqual: selectedTab ] ) {
		dict = [ self processPopular: dict intoProfile: profile  ];
	} else if( [ @"command line" isEqual: selectedTab ] ) {
		dict = [ self processCommandLine: dict intoProfile: profile ];
	} else if( [ @"import" isEqual: selectedTab ] ) {
		dict = [ self processImport: dict intoProfile: profile  ];
	}
	
	[AlmostVPNConfigurationController refreshAll ];

	return dict;
}

@end
