#import "AlmostVPNConfigurationController.h"
#import "PathLocator.h"
#import "ImageAndTextCell.h"
#import "LBNSPanel.h"
#import "LBNSOutlineView.h"
#import "LBService.h"
#import "LBServer.h"
#import "LBIdentity.h"
#import "IconNameToImageConverter.h"
#import "ServerHelper.h"

#import "SecureStorageProvider.h"

#import "Utils/LogRecord.h"

#import "ForPayManager.h"

#import "LBNSTableView.h"

#import "QuickConfigHelper.h"

#import "LocationTester.h"

#import "PathLocator.h"

#import "InstallManager.h"

#import "AlmostVPNConfiguration.h"

#import <SM2DGraphView.h>

AlmostVPNConfigurationController*	_sharedInstance = nil;
NSFileManager*	_fm = nil;

@implementation AlmostVPNConfigurationController
+ (void) initialize {
	_fm = [ NSFileManager defaultManager ];
	
	[self 
		setKeys:[NSArray arrayWithObjects:@"showTransitionalStates", @"showExtraLogging", @"showUtilizationEvents", nil ]	
		triggerChangeNotificationsForDependentKey:@"logViewPredicate"
	];

	[self 
		setKeys:[NSArray arrayWithObjects:@"serverIsRunning", nil ]	
		triggerChangeNotificationsForDependentKey:@"serverState"
	];
	[self 
		setKeys:[NSArray arrayWithObjects:@"serverIsRunning", nil ]	
		triggerChangeNotificationsForDependentKey:@"serverStateIcon"
	];
	[self 
		setKeys:[NSArray arrayWithObjects:@"serverIsRunning", nil ]	
		triggerChangeNotificationsForDependentKey:@"startActionName"
	];

	NSValueTransformer* transformer = [[[IconNameToImageConverter alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"LBIconNameToImage"];	
}

+ (AlmostVPNConfigurationController*) sharedInstance {
	return _sharedInstance;
}

+ (void) refreshAll {
	[ _sharedInstance setConfiguration: nil ];

	[ _sharedInstance setLocations: nil ];
	[ _sharedInstance setHosts: nil ];
	[ _sharedInstance setProfiles: nil ];
	[ _sharedInstance setIdentities: nil ];
	
	[ _sharedInstance->objectsTree reloadItem: _sharedInstance->_profiles reloadChildren: YES ];
	[ _sharedInstance->objectsTree reloadItem: _sharedInstance->_locations reloadChildren: YES ];
	
	[ _sharedInstance setKnownServers: nil ];
	[ _sharedInstance setKnownServices: nil ];
	
	[ _sharedInstance setVersion: nil ];
}

- (void) awakeFromNib {
	_profilesTableLastSelectedIndex = -1;	
	_sharedInstance = self;
	
	[ self setTraficChartIsFrozen: [ NSNumber numberWithBool: YES ]];	
	[ self initializeChartPoints ];		

	_logRecords = [[ NSMutableArray alloc ] init ];
	
	//
	// Create Subordinate 
	// 

	[ self setBonjourManager: [[ BonjourManager alloc ] init ]];
	[ self setQuickConfig: [[ QuickConfigHelper sharedInstance] configDictionary ]];	
	
		
	//
	// Obtain configuration singletons
	//
	_configuration = [ AlmostVPNConfiguration sharedInstance ];
	
	_locations = [[ AlmostVPNLocations alloc ] init ];
	[ _locations setName: @"Locations" ];

	_profiles = [[ AlmostVPNProfiles alloc ] init ];
	[ _profiles setName: @"Profiles" ];	
	
	_trash = [[ AlmostVPNTrash alloc ] init ];
	[ _trash setName: @"Trash" ];
	
	if ( [ _fm fileExistsAtPath: [ PathLocator preferencesPath ]] ) {
		NSLog( @"AlmostVPN:loading configuration. plist = %@\n", [ PathLocator preferencesPath ] );
		[ _configuration loadFromFile: [ PathLocator preferencesPath ]];		
	} else {
		NSLog( @"AlmostVPN:bootstraping configuration. plist = %@\n", [ PathLocator preferencesPath ] );
		[ _configuration bootstrap ];
		[ self bootstrap ];		
	}
	_localhost = [ _configuration localHost ];
	
	[ self setupInitialConfiguration ];

	//
	// Deal with 0.9 import
	//
	if( 
		! [[[[ AlmostVPNConfiguration sharedInstance ] configuration ] objectForKey: @"avpn-0.9-imported" ] boolValue ] &&
		[ _fm fileExistsAtPath: [ @"~/Library/Preferences/com.leapingbytes.AlmostVPN.plist" stringByExpandingTildeInPath ]]
	) {
		[[[ QuickConfigHelper sharedInstance] configDictionary ] setObject: @"import" forKey: @"selectedTab" ];
		[self performSelector: @selector( showQuickConfig: ) withObject:  topTabView afterDelay: 1.0 ];
	} 
	[[[ AlmostVPNConfiguration sharedInstance ] configuration ] setObject: [ NSNumber numberWithBool: YES ] forKey: @"avpn-0.9-imported" ];
		
	//
	// Setup configuration providers/resolvers/delegates
	//	
	[ AlmostVPNObject setSecureStorageProvider: [[ SecureStorageProvider alloc ] init ]];
	[ AlmostVPNService setResolver: self ];
	[ AlmostVPNHost setResolver: self ];
	
	[ AlmostVPNIdentity setDelegate: (id<AlmostVPNObjectDelegate>)self ];
	[ AlmostVPNLocation setDelegate: (id<AlmostVPNObjectDelegate>)self ];
	[ AlmostVPNAccount setDelegate: (id<AlmostVPNObjectDelegate>)self ];	

	//
	// Deal with activation
	//
	[ _activationManager setActivationFullName: [ _configuration fullName ]];
	[ _activationManager setActivationEmail: [ _configuration email ]];	
	if( ! [ self activationOK ] ) {
		[ ForPayManager evalConfiguration ];
	}	
	
	//
	// Register GUI delegates
	//
	[[ NSApplication sharedApplication ] setDelegate: self ];
	
	[[ objectsTree window ] setDelegate: self ];		
    [ objectsTree registerForDraggedTypes:[NSArray arrayWithObjects: @"AlmostVPNObject", nil]];
	
	[ profileResourcesTable registerForDraggedTypes:[NSArray arrayWithObjects: @"AlmostVPNObject", nil]];
	
	[ LBNSTableView setDelegate: self ];
	[ LBNSTableView setAction: @selector( doTableViewClick: ) ];
	[ LBNSTableView setDoubleAction: @selector( doTableViewDoubleClick: ) ];
	
	[ objectsTree setDelegate: self ];
	[ objectsTree setDoubleAction: @selector( doObjectsTreeDoubleClick: ) ];
	[ objectsTree setAction: nil ];
		
	//
	// Register observers
	//
	[[ NSNotificationCenter defaultCenter ]
		addObserver: self selector: @selector( doServerEvent: ) name: @"ServerEvent" object: nil
	];
	[[ NSNotificationCenter defaultCenter ]
		addObserver: self selector: @selector( doServerStateEvent: ) name: @"ServerStateEvent" object: nil
	];

	[[ NSNotificationCenter defaultCenter ] 
		addObserver: self 
		selector: @selector( almostVPNObjectChanged: ) 
		name: _ALMOSTVPN_SET_VALUE_FOR_KEY_NOTIFICATION_ 
		object: nil
	];			

	//
	// Trigger all bindings
	//
	[ AlmostVPNConfigurationController refreshAll ];

	//
	// DONE
	//
	
	[ ServerMonitor monitor: @"127.0.0.1" ];	
	[ ServerHelper sendEvent: @"_AVPN_DID_STARTUP_" ];	
}

- (void) setupInitialConfiguration {
//	if( [ _configuration userName ] == nil ) [ _configuration setUserName: NSUserName() ];
//	if( [ _configuration userHome ] == nil ) [ _configuration setUserHome: [ PathLocator home ]];
//	if( [ _configuration applicationSupportPath ] == nil ) [ _configuration setApplicationSupportPath: [ PathLocator applicationSupportPath ]];
//	if( [ _configuration resourcesPath ] == nil ) [ _configuration setResourcesPath: [ PathLocator resourcePath ]];
//	if( [ _configuration preferencesPath ] == nil ) [ _configuration setPreferencesPath: [ PathLocator preferencesPath ]];
//	if( [ _configuration keychainPath ] == nil ) [ _configuration setKeychainPath: [ PathLocator keychainPath ]];

	[ _configuration setUserName: NSUserName() ];
	[ _configuration setUserHome: [ PathLocator home ]];
	[ _configuration setApplicationSupportPath: [ PathLocator applicationSupportPath ]];
	[ _configuration setResourcesPath: [ PathLocator resourcePath ]];
	[ _configuration setPreferencesPath: [ PathLocator preferencesPath ]];
	[ _configuration setKeychainPath: [ PathLocator keychainPath ]];
	[ _configuration setSecureStorePath: [ PathLocator sspPath ]];

	[ self setLogIsFrozen: [ _configuration logInitiallyFrozen ]];
	_maxLogRecords = [[_configuration maxLogSize ] intValue ];
	[ self setTraficChartIsFrozen: [_configuration trafficInitiallyFrozen ]];
}

- (BOOL) activationOK {
	return [[ _activationManager activationOk ] boolValue ];
}


- (ActivationManager*) activationManager {
	return _activationManager;
}

- (IBAction) openActivation: (id) sender {
	[ self setTopLevelTab: @"Preferences" ];
	[ self setPreferencesTab: @"Activation" ];
}

- (ForPayManager*) forPayManager {
	return [ ForPayManager sharedInstance ];
}

- (BonjourManager*)	bonjourManager {
	return _bonjourManager;
}

- (void) setBonjourManager: (BonjourManager*) v {
	_bonjourManager = v;
	[ AlmostVPNBonjour setDelegate: (id<AlmostVPNObjectDelegate>)v ];
}

- (void) adjustStartStopButton {
		NSIndexSet* selection = [ profilesTable selectedRowIndexes ];
		BOOL someRunning = NO;
		BOOL allRunning = YES;
		
		BOOL someIdle = NO;
		BOOL allIdle = YES;
		
		BOOL somePaused = NO;
		BOOL allPaused = YES;
				
		NSArray* profiles = [[ AlmostVPNConfiguration sharedInstance ] profiles ];
		BOOL emptySelection = [ selection count ] == 0;
		for( int i = 0; i < [ profiles count ] ; i++ ) {
			AlmostVPNProfile* profile =  [ profiles objectAtIndex: i ];
			
			if( ! emptySelection ) {
				if ( ! [ selection containsIndex: i ] ) {
					continue;
				}
			}
			
			if( [[ profile state ] isEqual: @"running" ] ||[[ profile state ] isEqual: @"fail" ] ||[[ profile state ] isEqual: @"starting" ]  ) {
				someRunning |= true;
				allIdle = NO;
				allPaused = NO;
			} else if(( [ profile state ] == nil ) || [[ profile state ] isEqual: @"idle" ] ) {
				someIdle |= true;
				allRunning = NO;
				allPaused = NO;
			} else if( [[ profile state ] isEqual: @"paused" ] ) {
				somePaused |= true;
				allRunning = NO;
				allIdle = NO;
			}
		}
		
		[ _startStopButton setEnabled: YES forSegment: 0 ]; // START
		[ _startStopButton setEnabled: YES forSegment: 1 ]; // STOP
		[ _startStopButton setEnabled: YES forSegment: 2 ]; // PAUSE

		[ _startStopButton setLabel: ( emptySelection ? @"start all" : @"start" ) forSegment: 0 ];
		[ _startStopButton setLabel: ( emptySelection ? @"stop all" : @"stop" ) forSegment: 2 ];
		if( somePaused || allPaused ) {
			[ _startStopButton setLabel: ( emptySelection ? @"resume all" : @"resume" ) forSegment: 1 ];
		} else if( someRunning || allRunning ) {
			[ _startStopButton setLabel: ( emptySelection ? @"pause all" : @"pause" ) forSegment: 1 ];
		}

		if( allIdle ) {			
			[ _startStopButton setLabel: ( emptySelection ? @"pause all" : @"pause" ) forSegment: 1 ];			
			[ _startStopButton setEnabled: NO forSegment: 1 ];

			return;
		} 
		if( allRunning ) {
			[ _startStopButton setEnabled: NO forSegment: 0 ];
			[ _startStopButton setLabel: ( emptySelection ? @"pause all" : @"pause" ) forSegment: 1 ];			

			return;
		} 
		if( allPaused ) {
			[ _startStopButton setLabel: ( emptySelection ? @"resume all" : @"resume" ) forSegment: 1 ];			
			[ _startStopButton setEnabled: NO forSegment: 2 ];
			return;
		} 
				
		if( someRunning ) {
			if( somePaused ) {
				[ _startStopButton setLabel: ( emptySelection ? @"resume all" : @"resume" ) forSegment: 1 ];
			} else {
				[ _startStopButton setLabel: ( emptySelection ? @"pause all" : @"pause" ) forSegment: 1 ];
			}
			return;
		} else {
			if ( somePaused ) {
				[ _startStopButton setEnabled: NO forSegment: 2 ];
			}
		}
		
}

- (void) doTableViewClick: (id) sender {
	if( sender == profilesTable ) {
		NSIndexSet* selection = [ profilesTable selectedRowIndexes ];
		
		if( [ selection count ] == 1 ) {
			if( _profilesTableLastSelectedIndex >= 0 && [ selection containsIndex: _profilesTableLastSelectedIndex ] ) {
				[ profilesTable selectRowIndexes: [ NSIndexSet indexSet ] byExtendingSelection: NO ];
				_profilesTableLastSelectedIndex = -1;
			} else {
				_profilesTableLastSelectedIndex = [ selection firstIndex ];
			}
		} else if( [ selection count ] == 0 ) {
			_profilesTableLastSelectedIndex = -1;
		}
		[ self adjustStartStopButton ];
	}
}

- (void) doTableViewDoubleClick: (id) sender {
	AlmostVPNObject* target = [ self selectedObjectFrom: sender ];
	if ( [ target isReference ] ) {
		target = [(AlmostVPNObjectRef*)target referencedObject ];
	}
	[ objectsTree expandAndMakeVisibleItem: target ];
}

- (void) doObjectsTreeDoubleClick: (id) sender {
	AlmostVPNObject* target = [ self selectedObjectFrom: sender ];
	if ( [ target isReference ] ) {
		target = [(AlmostVPNObjectRef*)target referencedObject ];
		[ objectsTree expandAndMakeVisibleItem: target ];
	}
}

#pragma mark AlmostVPNObjectDelegate
- (void) objectWasCreated: (AlmostVPNObject*) o {
}

- (void) objectWasInitWithDictionary: (AlmostVPNObject*) o {
//	NSLog( @"Object was init with dic : %@\n", o );
}

- (id) setValue: (id) aValue forProperty: (NSString*) aName ofObject: (AlmostVPNObject*) o {
	if( [ o isMemberOfClass: [ AlmostVPNAccount class ]] ) {
		o = [ (AlmostVPNAccount*) o owner ];
		if(  [ o isMemberOfClass: [ AlmostVPNLocation class ]] ) {
			[[ LocationTester testerForLocation: (AlmostVPNLocation*)o ] setValue: aValue forProperty: aName ofObject: o ];
		}
	} else if( [ o isMemberOfClass: [ AlmostVPNLocation class ]] ) {
		[[ LocationTester testerForLocation: (AlmostVPNLocation*)o ] setValue: aValue forProperty: aName ofObject: o ];
	}
	return IGNORE_DELEGATE;
}

-(void) bootstrap {
	[ self bootstrapIdentities ];
}

- (void) terminate {
	[ _configuration saveToFile: [ PathLocator preferencesPath ]];
}

#pragma mark Drag & Drop Support
- (unsigned int) draggingSourceOperationMaskForLocal: (BOOL) isLocal {
	return NSDragOperationEvery | NSDragOperationAll_Obsolete;
}

- (AlmostVPNObject*) getObjectFromPasteboard: (NSPasteboard*) pb {
	NSString* uuid = [ pb stringForType: @"AlmostVPNObject" ];
	AlmostVPNObject* result = uuid == nil ? nil : [ AlmostVPNObject findObjectWithUUID: uuid ];
	return result;
}

- (unsigned int)outlineView:(NSOutlineView*)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)childIndex {
	AlmostVPNObject* draggingObject = [ self getObjectFromPasteboard: [ info draggingPasteboard ]];
	NSString* draggingObjectKind = [[ draggingObject class ] kind ];
	
	if( [ item isKindOfClass: [ AlmostVPNProfile class ]] ) {
		return [ item canHaveChild: draggingObjectKind ] ? NSDragOperationMove : NSDragOperationNone;
	} else if( item != nil && [ item canHaveChild: draggingObjectKind ] ) {
		if(( [[[ NSApplication sharedApplication ] currentEvent ] modifierFlags ] & NSAlternateKeyMask ) != 0 ) {
			return NSDragOperationCopy;
		} else {
			return NSDragOperationMove;
		}
	} else {
		return NSDragOperationNone;
	}
}

- (BOOL)outlineView:(NSOutlineView*)olv acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(int)childIndex {
	AlmostVPNViewable* draggingObject = (AlmostVPNViewable*)[ self getObjectFromPasteboard: [ info draggingPasteboard ]];
	[ draggingObject retain ];
	if( [ targetItem isKindOfClass: [ AlmostVPNProfile class ]] ) {
		// do nothing
	} else if(( [[[ NSApplication sharedApplication ] currentEvent ] modifierFlags ] & NSAlternateKeyMask ) != 0 ) {
		[ draggingObject release ];
		draggingObject = [ AlmostVPNObject objectWithObject: draggingObject ];
		[ draggingObject retain ];
	} else {
		[(AlmostVPNContainer*)[ draggingObject parent ] removeChild: draggingObject ];
	}
	
	AlmostVPNViewable* addedObject = nil;
	
	if( targetItem == _locations || targetItem == _profiles ) {
		addedObject = [ _configuration addChild: draggingObject ];
		if( targetItem == _profiles ) {
			[ self setProfiles: nil ];
		}
	} else {
		addedObject = [ (AlmostVPNContainer*)targetItem addChild: draggingObject ];
	}
	[ draggingObject release ];
	[ objectsTree reloadData ];
	if( addedObject != nil ) {
		[ objectsTree expandAndMakeVisibleItem: addedObject ];
	}
	return YES;
}

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard {
	AlmostVPNObject* anObject = [ items objectAtIndex: 0 ];
	[ pboard declareTypes: [ NSArray arrayWithObject: @"AlmostVPNObject" ] owner: self ];
	[ pboard setString: [ anObject uuid ] forType: @"AlmostVPNObject" ];
	return YES;
}

- (void) deleteKeyDownInOutlineView: (NSOutlineView *)olv {
	[ self deleteSelectedObjectFrom: olv ];
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation {
	if( aTableView != profileResourcesTable ) {
		return NSDragOperationNone;
	}
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation {
	AlmostVPNViewable* draggingObject = (AlmostVPNViewable*)[ self getObjectFromPasteboard: [ info draggingPasteboard ]];
	[ draggingObject retain ];
	AlmostVPNProfile* targetItem = [ self selectedObject ];
	[ targetItem addChild: draggingObject ];
	[ draggingObject release ];
	[ objectsTree reloadData ];
	[ self setSelectedObject: nil ];
	return YES;	
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
	AlmostVPNObject* anObject = [ self selectedObjectFrom: aTableView ];
	[ pboard declareTypes: [ NSArray arrayWithObject: @"AlmostVPNObject" ] owner: self ];
	[ pboard setString: [ anObject uuid ] forType: @"AlmostVPNObject" ];
	return YES;
}
#pragma mark Control
- (NSString*) selectedProfileName {
	if( [ @"Control" isEqual: [ self topLevelTab ]] ) {
		NSArray* selectedProfiles = [ (NSArrayController*)profilesController selectedObjects ];
		
		if( [ selectedProfiles count ] > 0 ) {
			return [[ selectedProfiles objectAtIndex: 0 ] name ];
		} else {
			return nil;
		}
	} else {
		AlmostVPNObject* selectedObject = [ self selectedObject ];
		if( [ selectedObject isKindOfClass: [ AlmostVPNProfile class ]] ) {
			return [ selectedObject name ];
		} else {
			return nil;
		}
	}
}

- (void) startProfile {
	NSString* profileName = [ self selectedProfileName ];
	if( profileName != nil ) {
		[ _configuration saveToFile: [ PathLocator preferencesPath ]];
		[ ServerHelper startProfile: profileName ];
	}
}

- (void) stopProfile {
	NSString* profileName = [ self selectedProfileName ];
	if( profileName != nil ) {
		[ ServerHelper stopProfile: profileName ];
	}
}

- (void) stopAllProfiles {
	NSArray* profiles = [ self profiles ];
	for( int i = 0; i < [ profiles count ]; i++ ) {
		AlmostVPNProfile* profile = (AlmostVPNProfile*)[ profiles objectAtIndex: i ];
		NSString* profileName = [ profile name ];
		if( profileName != nil ) {
			[ ServerHelper stopProfile: profileName ];
		}
	}
}

- (void) startAllProfiles {
	NSArray* profiles = [ self profiles ];
	for( int i = 0; i < [ profiles count ]; i++ ) {
		AlmostVPNProfile* profile = (AlmostVPNProfile*)[ profiles objectAtIndex: i ];
		NSString* profileName = [ profile name ];
		if( profileName != nil ) {
			[ ServerHelper startProfile: profileName ];
		}
	}
}

- (NSArray*) logRecords {
	return _logRecords;
}

- (void) setLogRecords: (NSArray*) v {
}

- (void) doServerStateEvent: (NSNotification*) notification {
	NSNumber* v = [ notification object ];
	if( [ v boolValue ] != [[ self serverIsRunning ] boolValue ]) {
		[ self setServerIsRunning: [ notification object ]];
	} 
	if( ! [ v boolValue ] ) {
		NSArray* profiles = [ self profiles ];
		for( int i = 0; i < [ profiles count ]; i++ ) {
			AlmostVPNProfile* profile = (AlmostVPNProfile*)[ profiles objectAtIndex: i ];
			[ profile setState: nil ];
			[ profile setStateComment: @"" ];
		}
	}
	[ self setServerIsRunning: nil ];
	[ self setServerState: nil ];
	[ self setServerStateIcon: nil ];
	[ self setStartActionName: nil ];
}
/*
	STATE:<timestamp>|<profile uuid>|<profile state>|<profile state comment>
	LOG:<timestamp>|<source>|<level>|<message>
	UTIL:<timestamp>|<location uuid>|<in bytes>|<out bytes>
*/
- (void) logMessage: (NSString*) message from: (NSString*) source atLevel: (NSString*) level {
	[ self 
		addServerEvent: [ NSString stringWithFormat: @"LOG:%ud|%@|%@|%@", (long)([[NSDate date ] timeIntervalSince1970 ]) * 1000, source, level, message ]];
}

+ (void) logMessage: (NSString*) message from: (NSString*) source atLevel: (NSString*) level {
	[[ AlmostVPNConfigurationController sharedInstance ] logMessage: message from: source atLevel: level ];
}

- (BOOL) recordShouldBeIgnored: (LogRecord*) record {
	if( [ record isStateEvent ] ) {
		AlmostVPNProfile* profile = (AlmostVPNProfile*)[ AlmostVPNObject findObjectWithUUID: [ record profileUuid ]];
		if( profile != nil ) {
			return [[ record profileState ] isEqual: [ profile state ]] && [[ record profileStateComment ] isEqual: [ profile stateComment ]];
		} else {
			return YES;
		}
	} else if( [ record isUtilizationEvent ] ) {
		for( int i = 0; i < [ _logRecords count ]; i++ ) {
			LogRecord* aRecord = [ _logRecords objectAtIndex: i ];
			if( ! [ aRecord isUtilizationEvent ] ) {
				continue;
			}
			if( [[ aRecord source ] isEqual: [ record source ]] ) {
				return [ aRecord inBytes ] == [ record inBytes ] && [ aRecord outBytes ] == [ record outBytes ];
			}
		}
		return NO;
	} else {
		return NO;
	}
}

- (LogRecord*) addServerEvent: (NSString*) string {
	LogRecord* record = [ LogRecord parseServerEvent: string ];
	if( record != nil ) {
		if ( [ record isUtilizationEvent ] ) {
			if( [ @"_TOTAL_" isEqual: [ record source ]] ) {
				[ self addToChartIncomming: [ record inBytes ] outgoing: [ record outBytes ]];
			}
		}
		if ( [ self recordShouldBeIgnored: record ] ) {
			[ record release ];
			return nil;
		}
topLoop:		
		while( [ _logRecords count ] > _maxLogRecords ) {
			
			for( int i = [ _logRecords count ] -1 ; i >= 10; i-- ) {
				LogRecord* aRecord = [ _logRecords objectAtIndex: i ];
				if( [ aRecord isUtilizationEvent ] ) {
					[ _logRecords removeObjectAtIndex: i ];
					goto topLoop;
				}
			}
			[ _logRecords removeLastObject ];
		}
		[ _logRecords insertObject: record atIndex: 0 ];
		if(( ! _logFreezed ) && ([[ self topLevelTab ] isEqual: @"Monitor" ])) {
			[ self setLogRecords: _logRecords ];
		}
	}
	return record;
}

- (void) doServerEvent: (NSNotification*) notification {
	NSString* string = (NSString*)[ notification object ];
	
	if( [ string length ] == 0 ) {
		return;
	}

	LogRecord* record = [ self addServerEvent: string ];
	
	if( record == nil ) {
		return;
	}
	
	if ( [ record isStateEvent ] ) {
		NSString* uuid			= [ record profileUuid ];
		NSString* state			= [ record profileState ]; 
		NSString* stateComment	= [ record profileStateComment ];
		
		AlmostVPNProfile* profile = (AlmostVPNProfile*)[ AlmostVPNObject findObjectWithUUID: uuid ];
		if( profile != nil ) {
			[ profile setState: state ];
			[ profile setStateComment: stateComment ];
		}
		
		[ self adjustStartStopButton ];
	}
}

- (id) showTransitionalStates {
	if( _showTransitionalStates == nil ) {
		_showTransitionalStates = [[ NSNumber numberWithBool: NO ] retain ];
	}
	return _showTransitionalStates;
}

- (void) setShowTransitionalStates: (id) v {
	v = [ v copy ];
	[ _showTransitionalStates release ];
	_showTransitionalStates = v;
	if( _logFreezed ) {
		[ self setLogIsFrozen: [ NSNumber numberWithBool: NO ]];
		[ self performSelector: @selector( setLogIsFrozen: ) withObject: [ NSNumber numberWithBool: YES ] afterDelay: 0.1 ];
	}
}

- (id) showExtraLogging {
	if( _showExtraLogging == nil ) {
		_showExtraLogging = [[ NSNumber numberWithBool: NO ] retain ];
	}
	return _showExtraLogging;
}

- (void) setShowExtraLogging: (id) v {
	v = [ v copy ];
	[ _showExtraLogging release ];
	_showExtraLogging = v;
	if( _logFreezed ) {
		[ self setLogIsFrozen: [ NSNumber numberWithBool: NO ]];
		[ self performSelector: @selector( setLogIsFrozen: ) withObject: [ NSNumber numberWithBool: YES ] afterDelay: 0.1 ];
	}
}

- (id) showUtilizationEvents {
	if( _showUtilizationEvents == nil ) {
		_showUtilizationEvents = [[ NSNumber numberWithBool: NO ] retain ];
	}
	return _showUtilizationEvents;
}

- (void) setShowUtilizationEvents: (id) v {
	v = [ v copy ];
	[ _showUtilizationEvents release ];
	_showUtilizationEvents = v;
	if( _logFreezed ) {
		[ self setLogIsFrozen: [ NSNumber numberWithBool: NO ]];
		[ self performSelector: @selector( setLogIsFrozen: ) withObject: [ NSNumber numberWithBool: YES ] afterDelay: 0.1 ];
	}
}

- (NSPredicate*) logViewPredicate {
	NSString*	statePredicate;
	NSString*	logPredicate;
	NSString*	utilPredicate;
	
	if( [ _showTransitionalStates boolValue ] ) {
		statePredicate = @"(type = 1)";
	} else {
		statePredicate = @"(type = 1) AND (( profileState = 'running' ) OR ( profileState = 'idle' ) OR ( profileState = 'fail' ))";
	}
	
	if( [ _showExtraLogging boolValue ] ) {
		logPredicate = @"( type = 2 )";
	} else {
		logPredicate = @"( type = 2 ) AND ( level >= 900 )";
	}
	
	if( [ _showUtilizationEvents boolValue ] ) {
		utilPredicate = @"( type = 4 )";
	} else {
		utilPredicate = @" 1 = 2 ";
	}
	
	NSString* predicate = [ NSString stringWithFormat: 
		@"( type = 8 ) OR (%@) OR (%@) OR (%@)", statePredicate, logPredicate, utilPredicate
	];
	NSPredicate* result = [ NSPredicate predicateWithFormat: predicate ];
	return result;
}

- (void) copyLogRecordsToPastboard {
	NSMutableString*	logText = [ NSMutableString string ];
	for( int i = 0; i < [ _logRecords count ]; i++ ) {
		LogRecord* record = [ _logRecords objectAtIndex: i ];
		if( [ record isLogEvent ] ) {
			[ logText appendFormat: @"  LOG:%@|%@|%@|%@\n", [ record date ], [ record state ], [ record source ], [ record message ]];
		} else if( [ record isStateEvent ] ) {
			[ logText appendFormat: @"STATE:%@|%@|%@|%@\n", [ record date ], [ record profileState ], [ record logViewSource ], [ record profileStateComment ]];
		}
	}
	NSPasteboard* pboard = [ NSPasteboard generalPasteboard ];
	[ pboard declareTypes: [ NSArray arrayWithObject: NSStringPboardType ] owner: self ];
	[ pboard setString: logText forType: NSStringPboardType ];
}

#pragma mark Actions 
- (IBAction) startStopProfile: (id)sender {
	int selectedSegment = [ sender selectedSegment ];
	NSString* startOrStop = [ sender labelForSegment: selectedSegment ];

	NSMutableArray* selectedProfiles = [ NSMutableArray array ];

	if( [[ self  topLevelTab ] isEqual: @"Control" ] ) {	
		NSIndexSet* profileIndexes = [ profilesTable selectedRowIndexes ];
		NSArray* profiles = [[ AlmostVPNConfiguration sharedInstance] profiles ];
		for( int i = 0; i < [ profiles count ]; i++ ) {
			if( [ profileIndexes containsIndex: i ] || ([ profileIndexes count ] == 0 )) {
				[ selectedProfiles addObject: [ profiles objectAtIndex: i ]];
			}
		}
	} else {
		AlmostVPNProfile* selectedProfile = [ self selectedObject ];
		if( selectedProfile != nil ) {
			[ selectedProfiles addObject: selectedProfile ];
		} else {
			return;
		}		
	}
	
	if(  [ @"start all" isEqual: [ startOrStop lowercaseString ]  ] ) {
		[ _configuration saveToFile: [ PathLocator preferencesPath ]];
		[ self startAllProfiles ];		
	} else if(  [ @"stop all" isEqual: [ startOrStop lowercaseString ]  ] ) {
		[ self stopAllProfiles ];
	} else if ( [ @"pause all" isEqual:[ startOrStop lowercaseString ]  ] ) { 
		for( int i = 0; i < [ selectedProfiles count ]; i++ ) {
			NSString* profileName = [[ selectedProfiles objectAtIndex: i ] name ];
			if( [[((AlmostVPNProfile*)[ selectedProfiles objectAtIndex: i ]) state ] isEqual: @"running" ] ) {
				[ ServerHelper pauseProfile: profileName ];
			}
		}
	} else if ( [ @"resume all" isEqual:[ startOrStop lowercaseString ]  ] ) { 
		for( int i = 0; i < [ selectedProfiles count ]; i++ ) {
			NSString* profileName = [[ selectedProfiles objectAtIndex: i ] name ];
			if( [[((AlmostVPNProfile*)[ selectedProfiles objectAtIndex: i ]) state ] isEqual: @"paused" ] ) {
				[ ServerHelper resumeProfile: profileName ];
			}
		}
	} else {
		if( [ @"start" isEqual: [ startOrStop lowercaseString ] ] ) {
			[ _configuration saveToFile: [ PathLocator preferencesPath ]];
		}
		for( int i = 0; i < [ selectedProfiles count ]; i++ ) {
			NSString* profileName = [[ selectedProfiles objectAtIndex: i ] name ];
			if( [ @"start" isEqual: [ startOrStop lowercaseString ] ] ) {
				[ ServerHelper startProfile: profileName ];
			} else if( [ @"stop" isEqual: [ startOrStop lowercaseString ]  ] ) {
				[ ServerHelper stopProfile: profileName ];
			} else if( [ @"pause" isEqual: [ startOrStop lowercaseString ]  ] ) {
				[ ServerHelper pauseProfile: profileName ];
			} else if( [ @"resume" isEqual: [ startOrStop lowercaseString ]  ] ) {
				[ ServerHelper resumeProfile: profileName ];
			}			
		}
	}	
}

- (IBAction) controlLogView: (id)sender {
	int selectedSegment = [ sender selectedSegment ];
	NSString* action = [ sender labelForSegment: selectedSegment ];
	
	if( [ @"Freeze" isEqual: action ] ) {
		_logFreezed = ! _logFreezed;
		if( ! _logFreezed ) {
			[ self setLogRecords: nil ];
		}
		[ self setLogIsFrozen: [ NSNumber numberWithBool: _logFreezed ]];
	} else if( [ @"Copy" isEqual: action ] ) {
		[ self copyLogRecordsToPastboard ];
	} else if( [ @"Clear" isEqual: action ] ) {
		_logFreezed = NO;
		[ _logRecords removeAllObjects ];
		[ self setLogRecords: nil ];
	}

	[ self performSelector:  @selector( resetLogViewControl: ) withObject: sender afterDelay:0.2 ];
}

- (void) resetLogViewControl: (id) sender {
	if( _logFreezed ) {
		[ sender setSelected: YES forSegment: 0 ];
	} else {
		[ sender setSelected: NO forSegment: 0 ];
	}
	[ sender setSelected: NO forSegment: 1 ];
	[ sender setSelected: NO forSegment: 2 ];
}

- (IBAction) controlUtilizationChart: (id)sender {
	int selectedSegment = [ sender selectedSegment ];
	NSString* action = [ sender labelForSegment: selectedSegment ];
	
	if( [ @"Freeze" isEqual: action ] ) {
		_chartFreezed = ! _chartFreezed;
		if( ! _chartFreezed ) {
			[ _chartView refreshDisplay: self ];
		}
		[ self setTraficChartIsFrozen: [ NSNumber numberWithBool: _chartFreezed ]];
	} else if( [ @"Copy" isEqual: action ] ) {
		// [ self copyLogRecordsToPastboard ];
	} else if( [ @"Clear" isEqual: action ] ) {
		[ self initializeChartPoints ];
	}

	[ self performSelector:  @selector( resetUtilizationChartControl: ) withObject: sender afterDelay:0.2 ];
}

- (void) resetUtilizationChartControl: (id) sender {
	if( _chartFreezed ) {
		[ sender setSelected: YES forSegment: 0 ];
	} else {
		[ sender setSelected: NO forSegment: 0 ];
	}
	[ sender setSelected: NO forSegment: 1 ];
	[ sender setSelected: NO forSegment: 2 ];
}


#pragma mark Bindings 
- (id) widgetInstall {
	return [ InstallManager widgetInstall ];
}

- (void) setWidgetInstall: (id) v {
	return [ InstallManager setWidgetInstall: v ];
}

- (id) menuBarAppStartOnLogin {
	return [ InstallManager menuBarAppStartOnLogin ];
}

- (void) setMenuBarAppStartOnLogin: (id) v {
	return [ InstallManager setMenuBarAppStartOnLogin: v ];
}

- (id) traficChartIsFrozen {
	return [ NSNumber numberWithBool: _chartFreezed ];
}

- (void) setTraficChartIsFrozen: (id) v {
	_chartFreezed = [ v boolValue ];
}

- (id) logIsFrozen {
	return [ NSNumber numberWithBool: _logFreezed ];
}

- (void) setLogIsFrozen: (id) v {
	_logFreezed = [ v boolValue ];
}

- (id) configuration {
	return [ AlmostVPNConfiguration sharedInstance ];
}

- (void) setConfiguration: (id) v {
}

static NSArray* _PROXY_VALUES_ = nil;
- (NSArray*) proxyValues {
	if( _PROXY_VALUES_ == nil ) {
		_PROXY_VALUES_ = [[ NSArray alloc ] initWithObjects:
			@"No Proxy",
			@"SOCKS",
			@"HTTPS",
			@"HTTP",
			@"Automatic",
			nil
		];
	}
	return _PROXY_VALUES_;
}

- (void) setProxyValues: (NSArray*) v  {
}

static NSString* _topLevelTab = @"Control";

- (NSString*) topLevelTab {
	return _topLevelTab;
}

- (void) setTopLevelTab: (NSString*) v {
	v = [ v copy ];
	[ _topLevelTab release ];
	_topLevelTab = v;

	if( [ _topLevelTab isEqual: @"Monitor" ] ) {
		if(  ! _logFreezed ) {
			[ self setLogRecords: nil ];
		}
	
		if( ! _chartFreezed ) {
			[ _chartView refreshDisplay: self ];
		}	
	}
}

static NSString* _preferenceslTab = @"General";

- (NSString*) preferencesTab {
	return _preferenceslTab;
}

- (void) setPreferencesTab: (NSString*) v {
	v = [ v copy ];
	[ _preferenceslTab release ];
	_preferenceslTab = v;
}

- (NSNumber*) serverIsRunning {
	return [ NSNumber numberWithBool: [ ServerHelper serverIsRunning ]];
}

- (void) resetProfileStates {
	NSArray* profiles = [ self profiles ];
	NSEnumerator* profileEnum = [ profiles objectEnumerator ];
	AlmostVPNProfile* profile;
	while(( profile = [ profileEnum nextObject ] ) != nil ) {
		[ profile setState: nil ];
	}
}

- (void) setServerIsRunning: (NSNumber*) v {
	if( v == nil ) {
		return;
	}
	
	if( ! [ v boolValue ] ) {
		[ self resetProfileStates ];
	} else {
		[ _activationManager setActivationOk: [ NSNumber numberWithInt: 3 ]];
	}
}

- (NSString*) serverState {
	return [ ServerHelper serverIsRunning ] ? @"Running" : @"Stopped";
}

- (void) setServerState: (id) v {
}

- (NSString*) serverStateIcon {
	return [ ServerHelper serverIsRunning ] ? @"green" : @"grey";
}

- (void) setServerStateIcon: (id) v {
}

- (NSString*) version {
	return [ PathLocator version ];
}

- (void) setVersion: (NSString*) v {
	// dummy
}

- (NSArray*) profiles {
	return [ _configuration childrenKindOfClass: [ AlmostVPNProfile class ]];
}

- (void) setProfiles: (NSArray*) v {
}

- (void) almostVPNObjectChanged: (id) item {
	[ objectsTree reloadItem: item ];
	[ objectsTree setNeedsDisplay: YES ];
}

- (NSString*) tabLabelFromSubview: (id) start {
	id superview = [ start superview ];
	id subview = start;
	while (( superview != nil ) && ( ! [ superview isKindOfClass: [ NSTabView class ]] )) {
		subview = superview;
		superview = [ superview superview ];
	}
	if( superview == nil ) {
		return nil;
	}
	NSArray* tabViewItems = [ superview tabViewItems ];
	for( int i = 0; i < [ tabViewItems count ]; i++ ) {
		if( [[ tabViewItems objectAtIndex: i ] view ] == subview ) {
			subview = [ tabViewItems objectAtIndex: i ];
			break;
		}
	}
	
	NSString* label = [ subview label ];
	return label;
}

- (id) objectOfKind: (NSString*) kind atIndex: (int) index {
	if( [ @"Resources" isEqual: kind ] || [ @"Host" isEqual: kind ]) {
		return [[[ self selectedObject ] resources ] objectAtIndex: index ];
	} else if( [ @"Hosts" isEqual: kind ] ) {
		return [[[ self selectedObject ] hosts ] objectAtIndex: index ];
	} else if( [ @"Locations" isEqual: kind ] ) {
		return [[[ self selectedObject ] locations ] objectAtIndex: index ];
	} else if( [ @"Identities" isEqual: kind ] ) {
		return [[[ self selectedObject ] identities ] objectAtIndex: index ];
	} else if( [ @"Profile" isEqual: kind ] ) {
		return [[[ self selectedObject ] resources ] objectAtIndex: index ];
	} else if( [ @"HostAlias" isEqual: kind ] ) {
		return [[ (AlmostVPNHost*)[[ self selectedObject ] referencedObject ] resources ] objectAtIndex: index ];
	} else if( [ @"Control" isEqual: kind ] ) {
		[ topTabView selectNextTabViewItem: nil ];
		return [[ self profiles ] objectAtIndex: index ];
	} else {
		return nil;
	}						
}

- (id) selectedObjectFrom: (NSTableView*) table {
	if( _newObject != nil ) {
		return _newObject;
	}
	
	int selectedRow = [ table selectedRow ];
	if( selectedRow == -1 ) {
		return nil;
	} else {
		if( [ table respondsToSelector: @selector( itemAtRow: ) ] ) {
			return [ table performSelector: @selector( itemAtRow: ) withObject: (id)selectedRow ];
		} else {
			NSString* label = [ self tabLabelFromSubview: table ];
			id result = [ self objectOfKind: label atIndex: selectedRow ];
			return result;
		}
	}
}

- (id) selectedObject {
	id result = [ self selectedObjectFrom: objectsTree ];
	return result;
}

- (void) setSelectedObject: (id) anObject {
	// do nothing
}

- (NSArray*) identities {
	NSArray* result = [[ AlmostVPNLocalhost sharedInstance ] identities ];
	
//	[[ AlmostVPNObject objectsKindOfClass: [ AlmostVPNIdentity class ]] mutableCopy ];
	
	return result;
}

- (void) setIdentities: (NSArray*) dummy {
	// do nothing
}

- (NSArray*) locations {
	NSArray* result = [ AlmostVPNObject objectsKindOfClass: [ AlmostVPNLocation class ]];
	return result;
}

- (void) setLocations: (NSArray*) dummy {
	// do nothing
}

- (NSArray*) hosts {
	NSArray* result = [ AlmostVPNObject objectsKindOfClass: [ AlmostVPNHost class ]];
	return result;
}

- (void) setHosts: (NSArray*) dummy {
	// do nothing
}

- (IBAction) manageKnownServices: (id) sender {
	NSPanel* newObjectPanel = [ LBNSPanel panelWithTitle: @"ManageKnownServicesPanel" ];
	if( newObjectPanel != nil ) {
		NSApplication* NSApp = [ NSApplication sharedApplication ];
		[ NSApp 
			beginSheet: newObjectPanel
			modalForWindow: [ topTabView window ] 
			modalDelegate: self 
			didEndSelector:@selector( sheetDidEnd:returnCode:contextInfo: ) 
			contextInfo: nil
		];	
	} else {
	}
}

- (IBAction) addDeleteKnownService: (id) sender {
}

- (IBAction) manageKnownServers: (id) sender {
	NSPanel* newObjectPanel = [ LBNSPanel panelWithTitle: @"ManageKnownServersPanel" ];
	if( newObjectPanel != nil ) {
		NSApplication* NSApp = [ NSApplication sharedApplication ];
		[ NSApp 
			beginSheet: newObjectPanel
			modalForWindow: [ topTabView window ] 
			modalDelegate: self 
			didEndSelector:@selector( sheetDidEnd:returnCode:contextInfo: ) 
			contextInfo: nil
		];	
	} else {
	}
}

- (IBAction) addDeleteKnownServer: (id) sender {
}


- (NSMutableArray*) knownServices {
	return [ LBService knownServices ];
}

- (void) setKnownServices: (NSMutableArray*) v {
	if( v != nil ) {
		[ LBService setKnownServices: v ];
	}
}

- (NSMutableArray*) knownServers {
	return [ LBServer knownServers ];
}

- (void) setKnownServers: (NSMutableArray*) v {
	if( v != nil ) {
		[ LBServer setKnownServers: v ];
	}
}

- (NSArray*) printerTypes {
	return [ AlmostVPNPrinter printerTypes ];
}
- (NSArray*) rcTypes {
	return [ AlmostVPNRemoteControl rcTypes ];
}

- (IBAction) testLocation: (id) sender {
	AlmostVPNObject* selectedLocation = [ self selectedObject ];
	if( [ selectedLocation isKindOfClass: [ AlmostVPNLocation class ]] ) {
		[ LocationTester watchLocation: (AlmostVPNLocation*)selectedLocation ];
	}
}

#pragma mark Add Object Dialog
- (void) sheetDidEnd: (NSWindow*) sheet returnCode: (int) returnCode contextInfo: (void*) info {
}

- (IBAction)endSheet: (id) sender {
	NSApplication* NSApp = [ NSApplication sharedApplication ];
	[[ sender window ] orderOut: sender ];
	[ NSApp endSheet: [ sender window ] ]; 
	
	/*
		Need to reset tab view to make it show first tab
	*/
	NSArray* siblings = [[ sender superview ] subviews ];
	for( int i = 0 ; i < [ siblings count ]; i++ ) {
		if( [[ siblings objectAtIndex: i ] isKindOfClass: [ NSTabView class ]] ) {
			[(NSTabView*)[ siblings objectAtIndex: i ] selectFirstTabViewItem: sender ];
			break;
		}
	}
}

- (NSArray*) allOfNewObjectClass {
	return [ AlmostVPNObject objectsKindOfClass: _newObjectClass ]; 
}

- (void) setAllOfNewObjectClass: (id) v {
}

- (void) addObjectOfKind: (NSString*) kind {
	AlmostVPNContainer* parentObject = [ self selectedObject ];

	_newObjectKind = kind;
	_newObjectClass = NSClassFromString( [ NSString stringWithFormat: @"AlmostVPN%@", _newObjectKind ] );
	if( _newObjectClass != nil ) {
		[ self setAllOfNewObjectClass: nil ];
		if( [ parentObject isKindOfClass: [ AlmostVPNProfile class ]] ) {
			NSPanel* newObjectPanel = [ LBNSPanel panelWithTitle: @"AddToProfilePanel" ];
			if( newObjectPanel != nil ) {
				NSApplication* NSApp = [ NSApplication sharedApplication ];
				[ NSApp 
					beginSheet: newObjectPanel
					modalForWindow: [ objectsTree window ] 
					modalDelegate: self 
					didEndSelector:@selector( sheetDidEnd:returnCode:contextInfo: ) 
					contextInfo: nil
				];	
			} else {
			}
		} else {		
			SEL newObjectOfKind = NSSelectorFromString( [ NSString stringWithFormat: @"new%@Object", _newObjectKind ] );
			if( [ self respondsToSelector: newObjectOfKind ] ) {
				_newObject = [ self performSelector: newObjectOfKind ];
			} else {
				_newObject = [[ _newObjectClass alloc ] init ];		
				[ _newObject bootstrap ];
			}

			[[ AlmostVPNConfiguration sharedInstance ] setObject: _newObject forKey: @"NewObject" ];
			
			[ _newObject setParent: parentObject ];
			[ self setSelectedObject: nil ];
			NSPanel* newObjectPanel = [ LBNSPanel panelWithTitle: [ NSString stringWithFormat: @"New%@Panel", _newObjectKind ]];
			if( newObjectPanel != nil ) {
				NSApplication* NSApp = [ NSApplication sharedApplication ];
				[ NSApp 
					beginSheet: newObjectPanel
					modalForWindow: [ objectsTree window ] 
					modalDelegate: self 
					didEndSelector:@selector( sheetDidEnd:returnCode:contextInfo: ) 
					contextInfo: nil
				];	
			} else {
			}
		}
	}
}

- (void) addObject: (id) sender {
	NSString* kind = [ sender title ];
	if( [ @"SSH Server" isEqual: kind ] ) {
		kind = @"Location";
	}
	[ self addObjectOfKind: kind ];
}

- (IBAction)commitAddObject: (id) sender {
	[[ AlmostVPNConfiguration sharedInstance ] removeObjectForKey: @"NewObject" ];

	[[ sender window ] makeFirstResponder: sender ];
	[ self endSheet: sender ];

	AlmostVPNViewable* newObject = _newObject;
	_newObject = nil;		
	_newObjectClass = nil;
	
	if( newObject == nil ) { // this is true in case of adding to Profile
		newObject = [[ _allOfNewObjectClassController selectedObjects ] objectAtIndex: 0 ];
	}

	SEL commitAddOfNewObjectOfKind = NSSelectorFromString( [ NSString stringWithFormat: @"commitAddNew%@Object:", _newObjectKind ] );
	if ( [ self respondsToSelector: commitAddOfNewObjectOfKind ] ) {
		newObject = [ self performSelector: commitAddOfNewObjectOfKind withObject: newObject ];
	} else {	
		AlmostVPNContainer* parentObject = [ self selectedObject ];
		if( [ parentObject isKindOfClass: [ AlmostVPNGroup class ]] ) {
			[ _configuration addChild: newObject ];
		} else {
			newObject = [ parentObject addChild: newObject ];
		}
	}
	[ self setSelectedObject: nil ];

	if( [ newObject isKindOfClass: [ AlmostVPNLocation class ]] ) {
		[ self setLocations: nil ];
		[ self setHosts: nil ];
	} else if( [ newObject isKindOfClass: [ AlmostVPNHost class ]] ) {
		[ self setHosts: nil ];
	} else if( [ newObject isKindOfClass: [ AlmostVPNProfile class ]] ) {
		[ self setProfiles: nil ];
	}

	if( [ newObject isKindOfClass: [ AlmostVPNPrinter class ]] ) {
		[ ForPayManager forPayFeature: @"Printer" ];
	}
	[ newObject release ];
	[ objectsTree reloadData ];
//	[ objectsTree expandAndMakeVisibleItem: [ self selectedObject ]];
	[ objectsTree expandAndMakeVisibleItem: newObject ];
}

- (IBAction)cancelAddObject: (id) sender {
	[[ AlmostVPNConfiguration sharedInstance ] removeObjectForKey: @"NewObject" ];

	[ self endSheet: sender ];
	AlmostVPNViewable* newObject = _newObject;
	_newObject = nil;
	_newObjectClass =nil;
	[ self setSelectedObject: nil ];
	
	[ newObject release ];
}

- (id) getSender: (id) sender siblingOfKind: (id) clazz {
	id parent = [ sender superview ];
	NSArray* siblings = [ parent subviews ];
	for( int i = 0; i < [ siblings count ]; i++ ) {
		id sibling = [ siblings objectAtIndex: i ];
		if( sibling == sender ) {
			continue;
		}
		if([ sibling isKindOfClass: [ NSScrollView class ]] ) {		
			sibling = [ (NSScrollView*) sibling documentView ];
		}
		if([ sibling isKindOfClass: clazz ]) {
			return sibling;
		}
	}
	return  nil;
}

- (void) moveToTrash: (id) sender {
	[ self deleteSelectedObjectFrom: objectsTree ];
}

- (void) deleteSelectedObject: sender {
	id targetTable = [ self getSender: sender siblingOfKind: [ NSTableView class ]];
	[ self deleteSelectedObjectFrom: targetTable ];
}

- (void) deleteSelectedObjectFrom: (id) targetTable {
	int selectedRow = [ targetTable selectedRow ];
	
	AlmostVPNViewable* child = [ self selectedObjectFrom: targetTable ];
	
	if( [ child isKindOfClass: [ AlmostVPNGroup class ]] || [ child isKindOfClass: [ AlmostVPNLocalhost class ]] ) {
		return; // Can not return "Localhost", "Locations" or "Profiles"
	}
	
	AlmostVPNContainer* parent = (AlmostVPNContainer*)[ child parent ];
	selectedRow--;
	if( [ targetTable respondsToSelector: @selector( itemAtRow: ) ] ) {
		AlmostVPNViewable* newSelectedObject = [ targetTable itemAtRow: selectedRow ];
		if( [ newSelectedObject isKindOfClass: [ AlmostVPNGroup class ]] ) {
			selectedRow = 0;
			newSelectedObject = [ objectsTree itemAtRow: selectedRow ];
		}
	}
	[ objectsTree selectRow: selectedRow byExtendingSelection: NO ];

	[ child retain ];
	[ parent removeChild: child ];
	[ _trash addChild: child ];
	if ( [[ child kind ] isEqual: @"Profile" ] ) {
		[ self setProfiles: nil ];
	} else {
		// Find all profiles refering to this object and delete corresponding reference objects
		while( true ) {
			AlmostVPNObjectRef* ref = (AlmostVPNObjectRef*)[ AlmostVPNObject 
				findObjectKindOfClass: [AlmostVPNObjectRef class ] 
				withProperty: _REF_OBJECT_UUID_KEY_ 
				equalTo: [ child uuid ]
			];
			if( ref == nil ) {
				break;				
			}
			[ ref setReferencedObject: nil ];
			[(AlmostVPNContainer*)[ ref parent ] removeChild: ref ];
		}
	}
	[ child release ];

	[ objectsTree reloadData ];
	selectedRow = [ objectsTree selectedRow ];	
	[ objectsTree deselectRow: selectedRow	];
	[ objectsTree selectRow: selectedRow byExtendingSelection: NO ];
}

- (void) duplicateSelectedObject: (id) sender {
	id targetTable = [ self getSender: sender siblingOfKind: [ NSTableView class ]];
	
	AlmostVPNViewable* target = [ self selectedObjectFrom: targetTable ];
	
	AlmostVPNContainer* parent = (AlmostVPNContainer*)[ target parent ];
	
	AlmostVPNViewable* targetCopy = [[ target class ] objectWithObject: target ];
	
	[ parent addChild: targetCopy ];

	[ objectsTree reloadData ];

	[ objectsTree expandAndMakeVisibleItem: targetCopy ];
}

- (IBAction)duplicateOrDeleteObject: (id) sender {
	int selectedSegment = [ sender selectedSegment ];
	NSString* selectedLabel = [ sender labelForSegment: selectedSegment ];
	
	if( [ @"+" isEqual: selectedLabel ] ) {
		NSString* tabName = [self tabLabelFromSubview: sender ];
		if( [ @"Hosts" isEqual: tabName ] ) {
			[ self addObjectOfKind: @"Host" ];
		} else if( [ @"Identities" isEqual: tabName ] ) {
			[ self addObjectOfKind: @"Identity" ];
		}
	} else if( [ @"x2" isEqual: selectedLabel ] ) {
		[ self duplicateSelectedObject: sender ];		
	} else if ( [ @"-" isEqual: selectedLabel ] ) {
		[ self deleteSelectedObject: sender ];
	}
}

#pragma mark Custom New Object code
- (id) importIdentity: (NSString*) identityFile withPassphrase: (NSString*) passphrase {
		if( ! [[ NSFileManager defaultManager ] fileExistsAtPath: identityFile ] ) {
			NSRunAlertPanel( 
				@"Can not import identity", 
				[ NSString stringWithFormat: @"File '%@' does not exists.\n", identityFile ],
				@"OK", nil, nil 
			);
		}
		
		NSDictionary* identityProperties = [[ LBIdentity sharedInstance ] queryIdentityFile: identityFile withPassphrase: passphrase ];
		if( identityProperties == nil ){
			return nil;
		}
		AlmostVPNIdentity* newIdentity = [[ AlmostVPNIdentity alloc ] init ];
		NSString* name = [ identityFile lastPathComponent ];
		[ newIdentity setName: name ];
		[ newIdentity setPath: [ identityFile stringByAbbreviatingWithTildeInPath ]];
		[ newIdentity setMedia: @"file" ];
		[ newIdentity setType: [ identityProperties objectForKey: @"type" ]];
		[ newIdentity setBits: [ identityProperties objectForKey: @"bits" ]];
		[ newIdentity setFingerprint: [ identityProperties objectForKey: @"fingerprint" ]];
		[ newIdentity setDigest: [ identityProperties objectForKey: @"digest" ]];
		if( [ passphrase length ] != 0 ) {
			[ newIdentity setPassphrase: passphrase ];
		}
		return newIdentity;
}

- (id) importIdentity: (NSString*) identityFile {
	return [ self importIdentity: identityFile withPassphrase: nil ];
}

-(void) bootstrapIdentities {
	NSArray* identities = [[ LBIdentity sharedInstance ] identityFiles ];
	AlmostVPNIdentity* rsaIdentity = nil;
	AlmostVPNIdentity* dsaIdentity = nil;	

	for( int i = 0; i < [ identities count ]; i++ ) {
		NSString* identityFile = [ identities objectAtIndex: i ];
		AlmostVPNIdentity* newIdentity = [ self importIdentity: identityFile ];
		if( newIdentity == nil ) {
			continue;
		}
		
		if( [ @"rsa" isEqual: [ newIdentity name ]] ) {
			rsaIdentity = newIdentity;
		}
		if( [ @"dsa" isEqual: [ newIdentity name ]] ) {
			dsaIdentity = newIdentity;
		}
		
		[[ AlmostVPNLocalhost sharedInstance ] addChild: newIdentity ];
	}
	if( dsaIdentity != nil ) {
		[ dsaIdentity setIsDefaultIdentity: [ NSNumber numberWithBool: YES ]];
	} else if( rsaIdentity != nil ) {
		[ rsaIdentity setIsDefaultIdentity: [ NSNumber numberWithBool: YES ]];
	}
}

- (NSObject*) newIdentityObject {
	NSObject* anObject = [[ AlmostVPNIdentity alloc ] init ];
	[ anObject setValue: @"rsa" forKey: @"newIdentityType" ];
	[ anObject setValue: @"file" forKey: @"newIdentityMedia" ];	
	[ anObject setValue: @"1024" forKey: @"newIdentityBits" ];
	return anObject;
}

- (AlmostVPNViewable*) commitAddNewIdentityObject: (NSObject*) anObject {
	NSMutableDictionary* aDictionary = (NSMutableDictionary*)anObject;
	
	AlmostVPNIdentity* newIdentity = [[ AlmostVPNIdentity alloc ] init ];
	if( [ aDictionary valueForKey: @"newIdentityName" ] != nil ) { // Create new identity		
		[ newIdentity setName: [ aDictionary valueForKey: @"newIdentityName" ]];
		[ newIdentity setType: [ aDictionary valueForKey: @"newIdentityType" ]];
		[ newIdentity setBits: [ aDictionary valueForKey: @"newIdentityBits" ]];
		if( [[ aDictionary valueForKey: @"newIdentityPassphrase" ] length ] != 0 ) {
			[ newIdentity setPassphrase: [ aDictionary valueForKey: @"newIdentityPassphrase" ]];
		}
		NSDictionary* properties = [[ LBIdentity sharedInstance ] newIdentityFile: newIdentity ];
		if( properties != nil ) {
			[ newIdentity setPath: [ properties valueForKey: @"path" ]];
			[ newIdentity setDigest: [ properties valueForKey: @"digest" ]];
			[ newIdentity setFingerprint: [ properties valueForKey: @"fingerprint" ]];
		}
	} else if ( [aDictionary valueForKey: @"identityFileName" ] ) { // import identity	
		NSString* passphrase = [ aDictionary valueForKey: @"newIdentityPassphrase" ];
		newIdentity = [ self importIdentity: [aDictionary valueForKey: @"identityFileName" ] withPassphrase: passphrase ];
	}
	if( newIdentity != nil ) {
		[[ AlmostVPNLocalhost  sharedInstance ] addChild: newIdentity ];
	}
	
	return newIdentity;
}

#pragma mark Miscellaneous

- (IBAction) toggleLocationOptions: (id)sender {
	NSRect rect = [ locationAccountBox frame ];
	int delta = ( 236 - 111 );
	int newHeight;
	BOOL resourceAndHostsHidden;
	if( [ locationOptionsDisclouserButton state ] == NSOnState ) {
		newHeight = 236;
		delta = -delta;
		resourceAndHostsHidden=YES;
	} else {
		newHeight = 111;
		resourceAndHostsHidden=NO;
	}
	rect.size.height = newHeight;
	rect.origin.y += delta ;
	
	NSArray* children = [[ locationAccountBox contentView ] subviews ];	
	for( int i = 0; i< [ children count ]; i++ ) {
		NSRect frame = [[ children objectAtIndex: i ] frame ];
		frame.origin.y -= delta;
		[[ children objectAtIndex: i ] setFrame: frame ];
	}
	
	[ locationResourcesAndHosts setHidden: resourceAndHostsHidden ];
	[ locationAccountBox setFrame: rect ];
}

#pragma mark KeyValue support
- (id) valueForUndefinedKey: (NSString*)aKey {
	int selectedRow = [ objectsTree selectedRow ];
	if( selectedRow == -1 ) {
		return nil;
	} else {
		id item = [ objectsTree itemAtRow: selectedRow ];
		if( [ item isKindOfClass: [ AlmostVPNObject class ]] ) {
			return [ item valueForKey: aKey ];
		}
	}
	return nil;
}

- (void) setValue: (id) aValue forUndefinedKey: (NSString*) aKey {
	int selectedRow = [ objectsTree selectedRow ];
	if( selectedRow != -1 ) {
		NSObject* item = [ objectsTree itemAtRow: selectedRow ];
		if( [ item isKindOfClass: [ AlmostVPNObject class ]] ) {
			[ item setValue: aValue forKey: aKey ];
		}
	}
	return;
}

#pragma mark ServiceResolver
- (int) serviceNameToPort: (NSString*) name {
	return [ LBService nameToNumber: name ];
}

- (NSString*) portToServiceName: (int) port {
	return [ LBService numberToName: port ];
}

- (void) rememberServiceName: (NSString*)name withPort: (int) port {
	[ LBService rememberService: name withNumber: port ];
}

#pragma mark HostResolver
- (NSString*) hostNameToAddress: (NSString*) name {
	return [ LBServer nameToAddress: name ];
}

- (NSString*) addressToHostName: (NSString*) address {
	return [ LBServer addressToName: address ];
}

- (void) rememberHostName: (NSString*)name withAddress: (NSString*) address {
	[ LBServer rememberServer: name withAddress: address ];
}

#pragma mark NSOutlineViewDataSource
- (id)outlineView:(NSOutlineView *)outlineView parentOfItem: (id) item {
	id result = [ (AlmostVPNViewable*)item parent ];
	if( [ result isKindOfClass: [ AlmostVPNConfiguration class ]] ) {
		if( [ item isKindOfClass: [ AlmostVPNLocation class ]] ) {
			result = _locations;
		} else if( [ item isKindOfClass: [ AlmostVPNProfile class ]] ) {
			result = _profiles;
		}
	}
	return result;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	if( item == nil ) {
		switch( index ) {
			case 0 :
				return [ _configuration localHost ];
			case 1 :
				return _locations;
			case 2 :
				return _profiles;
			case 3 :
				return _trash;
			default :
				NSLog( @"AlmostVPNConfigurationController : incorrect top index = %d", index );
				return nil;
		}
	} else if ( _locations == item ) {
		return [[ _configuration locations ] objectAtIndex: index ];
	} else if ( _profiles == item ) {
		return [[ _configuration profiles ] objectAtIndex: index ];
	} else {
		return [[ (AlmostVPNContainer*)item children ] objectAtIndex: index ];
	}
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if ( [ item isKindOfClass: [ AlmostVPNGroup class ]] ) return YES;
	
	return [ item isKindOfClass: [ AlmostVPNContainer class ]] && [ item countChildren ] > 0;
}
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	NSArray* children = nil;
	if( item == nil ) {
		return 4;
	} else if ( _locations == item ) {
		children = [ _configuration locations ];
	} else if ( _profiles == item ) {
		children = [ _configuration profiles ];
	} else {
		children = [ item children ];
	}
	
	return [ children count ];
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	return item;
}
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	[ (AlmostVPNViewable*)item setName: object ];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {    
	ImageAndTextCell* customCell = (ImageAndTextCell*)cell;
	
	if( item == nil ) {
		return;
	} else if( [ item isKindOfClass: [ AlmostVPNViewable class ]] ) {
		[ customCell setStringValue: [ item name ]];
		[ customCell setImage: [ PathLocator imageNamed: [ (AlmostVPNViewable*)item icon ] ofSize: NSMakeSize( 16.0, 16.0 )] ];
	} else {
		[ customCell setStringValue: [ item description ]];
		[ customCell setImage: nil ];
	}
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {	
	AlmostVPNViewable* selectedObject = [ self selectedObject ];
	if( selectedObject == nil ) {
		return;
	}
	if( [ selectedObject isKindOfClass: [ AlmostVPNGroup class ]] ) {
		return;
	}
	NSString* objectKind = [ selectedObject kind ];
	if( [ objectEditors indexOfTabViewItemWithIdentifier: objectKind ] >= 0 ) {
		[ objectEditors selectTabViewItemWithIdentifier: objectKind ];
	}
	
	[ self setSelectedObject: nil ];
	
//	[ self setSelectedObject: [ self selectedObject ]];
}

#pragma mark NSMenu delegate 
- (int)numberOfItemsInMenu:(NSMenu *)menu {
	AlmostVPNViewable* selectedObject = [ self selectedObject ];
	if( selectedObject == _trash ) {
		return 0;
	} else {
		AlmostVPNContainer* parent = (AlmostVPNContainer*)[ selectedObject parent ];
		while ( parent != nil && parent != _trash ) {
			parent = (AlmostVPNContainer*)[ parent parent ];
		}
		return parent == nil ? 1 : 0;
	}
}

NSString* _containers[] = {
	@"Location",
	@"Host",
	@"Profile",
	nil
};
 
NSString* _containerTitles[] = {
	@"SSH Server",
	@"Host",
	@"Profile",
	nil
};
 
NSString* _resources[] = {
	@"Service",
	@"Drive",
	@"File",
	@"Printer",
	@"Bonjour",
	@"RemoteControl",
	nil
};
  
- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(int)index shouldCancel:(BOOL)shouldCancel {
	//[ menu removeItem: item ];
	BOOL addSeparator = NO;
	BOOL menuGotSomeItems = NO;
	AlmostVPNViewable* selectedObject = [ self selectedObject ];
	if( menu == addObjectMenu ) {
		for( int i = 0;  _containers[ i ] != nil; i++ ) {
			NSString* container = _containers[ i ];
			if( ! [ selectedObject canHaveChild: container ] ) {
				continue;
			}
			addSeparator = YES;
			item = [[ NSMenuItem alloc ] initWithTitle: _containerTitles[ i ] action: @selector( addObject: ) keyEquivalent: @"" ];
				[ item setTarget: self ]; [ item setEnabled: YES ];	[ menu addItem: item ];				
				[ item setImage: [ PathLocator imageNamed: container ofSize: NSMakeSize( 12.0, 12.0 )]];
			[ item release ];
			menuGotSomeItems = YES;
		}
		if( [ selectedObject canHaveChild: @"Identity" ] ) {
			if( addSeparator ) {
				[ menu addItem: [ NSMenuItem separatorItem ]];
				addSeparator = NO;
			}
			item = [[ NSMenuItem alloc ] initWithTitle: @"Identity" action: @selector( addObject: ) keyEquivalent: @"" ];
				[ item setTarget: self ]; [ item setEnabled: YES ];	[ menu addItem: item ];
				[ item setImage: [ PathLocator imageNamed: @"Identity" ofSize: NSMakeSize( 12.0, 12.0 )]];
			[ item release ];
			menuGotSomeItems = YES;
		}
	}
	for( int i = 0; _resources[ i ] != nil; i++ ) {
		if( ! [ selectedObject canHaveChild: _resources[i] ] ) {
			continue;
		}
		
		if( addSeparator ) {
			[ menu addItem: [ NSMenuItem separatorItem ]];
			addSeparator = NO;
		}
		item = [[ NSMenuItem alloc ] initWithTitle: _resources[i] action: @selector( addObject: ) keyEquivalent: @"" ];
			[ item setTarget: self ]; [ item setEnabled: YES ];	[ menu addItem: item ];
			[ item setImage: [ PathLocator imageNamed: _resources[i] ofSize: NSMakeSize( 12.0, 12.0 )]];
		[ item release ];
		menuGotSomeItems = YES;
	}
	if( selectedObject != _locations && selectedObject != _profiles && selectedObject != _trash && selectedObject != _localhost ) {
		if( menuGotSomeItems ) {
			[ menu addItem: [ NSMenuItem separatorItem ]];
		}
		item = [[ NSMenuItem alloc ] initWithTitle: @"Move to Trash" action: @selector( moveToTrash: ) keyEquivalent: @"" ];
			[ item setTarget: self ]; [ item setEnabled: YES ];	[ menu addItem: item ];
		[ item release ];
	}
	
	return NO;
}

#pragma mark NSWindow delegate
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	[ ServerHelper sendEvent:@"_AVPN_WILL_SHUTDOWN_" ];
	[ self terminate ];
	return NSTerminateNow;		
}

#pragma mark Quick Config 
+ (WebView*) avpnCommandLineView {
	return [ _sharedInstance avpnCommandLineView ];
}
- (WebView*) avpnCommandLineView {
	return _avpnCommandLineView;
}

- (IBAction) showQuickConfig: (id) sender {
	NSPanel* newObjectPanel = [ LBNSPanel panelWithTitle: @"QuickConfigPanel" ];
	if( newObjectPanel != nil ) {
		NSApplication* NSApp = [ NSApplication sharedApplication ];
		[ NSApp 
			beginSheet: newObjectPanel
			modalForWindow: [ sender window ] 
			modalDelegate: self 
			didEndSelector:@selector( sheetDidEnd:returnCode:contextInfo: ) 
			contextInfo: nil
		];	
	} else {
	}
}

- (IBAction) addFromQuickConfig: (id) sender {
	[[ sender window ] makeFirstResponder: sender ];
	[ self setQuickConfig: [ QuickConfigHelper processQuickConfigDictionary: _quickConfig ]];
}

- (id) quickConfig {
	return _quickConfig;
}

- (void) setQuickConfig: (id) v {
//	v = [ v mutableCopy ];
//	[ _quickConfig release ];
	_quickConfig = v;
}

- (IBAction) selectPlistForImport: (id) sender {
	NSOpenPanel* panel = [ NSOpenPanel openPanel ];
	[ panel setAllowsMultipleSelection: YES ];
	
	[ panel 
		beginSheetForDirectory: [ @"~/Library/Preferences" stringByExpandingTildeInPath ]
	    file: nil 
	    types: [ NSArray arrayWithObjects: @"plist", @"xml", @"tunnel", nil ] 
		modalForWindow: [ sender window ] 
	    modalDelegate: self 
	    didEndSelector: @selector(selectPListForImportDidEnd:returnCode:contextInfo:)
		contextInfo: nil
	];
}

- (void) selectPListForImportDidEnd: (NSOpenPanel*)panel returnCode: (int) returnCode contextInfo: (void*) x {
	if( returnCode == 0 ) {
		return;
	}
	
	NSArray* imports = [ _quickConfig objectForKey: @"imports" ];
	NSEnumerator* importsEnumerator = [ imports objectEnumerator ];
	
	NSMutableDictionary* import;	
	while(( import = [ importsEnumerator nextObject ] ) != nil ) {
		[ import setObject: [ NSNumber numberWithBool: NO ] forKey: @"checked" ];
	}
		
	NSArray* fileNames = [ panel filenames ];

	for( int i = 0; i < [ fileNames count]; i++ ) {
		[ QuickConfigHelper addFileToImports: [ fileNames objectAtIndex: i ]];
	}
}

#pragma mark -
#pragma mark ¥ SM2DGRAPHVIEW DATASOURCE METHODS
#define _NUMBER_OF_SAMPLES_ 60

- (void) initializeChartPoints {
	_inBytesPoints = [[ NSMutableArray alloc ] init ];
	_outBytesPoints = [[ NSMutableArray alloc ] init ];
	
	for( int i = 0; i < _NUMBER_OF_SAMPLES_; i++ ) {
		[ _inBytesPoints addObject:NSStringFromPoint( NSMakePoint( 1.0 * i, 0.0 ) ) ];
		[ _outBytesPoints addObject:NSStringFromPoint( NSMakePoint( 1.0 * i - 0.5, 0.0 ) ) ];		
	}
}

- (void) addToChartIncomming: (long) incomming outgoing: (long) outgoing {
	if(( _lastInBytes == 0 && _lastOutBytes == 0 ) || ( _lastInBytes > incomming ) || ( _lastOutBytes > outgoing )) {
		_lastInBytes = incomming;
		_lastOutBytes = outgoing;
	} else {
		long inDelta = incomming - _lastInBytes;
		long outDelta = outgoing - _lastOutBytes;

		_lastInBytes = incomming;
		_lastOutBytes = outgoing;
		
		// We sample utilization every 5 seconds
		// We plot approcimate bytes/sec.  So we need to devide delta by 5.
		
		inDelta = inDelta / 5;
		outDelta = outDelta / 5;
		
//NSLog( @"New point : in = %d ( %f ) out = %d ( %f )\n", 
//	inDelta, inDelta <= 1 ? 0.0 : log10( 1.0 * inDelta ),
//	outDelta, outDelta <= 1 ? 0.0 : log10( 1.0 * outDelta )
//);
		
		[ _inBytesPoints removeObjectAtIndex: 0 ];
		[ _outBytesPoints removeObjectAtIndex: 0 ];

		[ _inBytesPoints addObject:NSStringFromPoint( NSMakePoint( 1.0 * 61, inDelta <= 1 ? 0.0 : log10( 1.0 * inDelta )) ) ];		
		[ _outBytesPoints addObject:NSStringFromPoint( NSMakePoint( 1.0 * 61 - 0.8, outDelta <= 1 ? 0.0 : log10( 1.0 * outDelta )) ) ];		
		
		_maxValue = 2.0;
		
		for( int i = 0; i < [ _inBytesPoints count ]; i++ ) {
			NSPoint p = NSPointFromString( [ _inBytesPoints objectAtIndex: i ] );
			p.x -= 1.0;
			_maxValue = _maxValue < p.y ? p.y : _maxValue;
			[ _inBytesPoints replaceObjectAtIndex: i withObject:NSStringFromPoint( p )];

			p =  NSPointFromString( [ _outBytesPoints objectAtIndex: i ] );
			p.x -= 1.0;
			_maxValue = _maxValue < p.y ? p.y : _maxValue;
			[ _outBytesPoints replaceObjectAtIndex: i withObject:NSStringFromPoint( p )];
		}

		if(( ! _chartFreezed ) && [ _topLevelTab isEqual: @"Monitor" ]) {
			[ _chartView refreshDisplay: self ];
		}
	}
}

- (unsigned int)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView {
	return 2;
}

- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView dataForLineIndex:(unsigned int)inLineIndex
{
    NSMutableArray	*result = nil;

	if ( inLineIndex == 0 )	{
		result = _inBytesPoints;
	} else if ( inLineIndex == 1 ) {
		result = _outBytesPoints;
	}
    return result;
}

- (NSData *)twoDGraphView:(SM2DGraphView *)inGraphView dataObjectForLineIndex:(unsigned int)inLineIndex {
    NSData	*result = nil;

    return result;
}

- (double)twoDGraphView:(SM2DGraphView *)inGraphView maximumValueForLineIndex:(unsigned int)inLineIndex forAxis:(SM2DGraphAxisEnum)inAxis {
	if ( inAxis == kSM2DGraph_Axis_X )
		return _NUMBER_OF_SAMPLES_;
	else
		return _maxValue;
}

- (double)twoDGraphView:(SM2DGraphView *)inGraphView minimumValueForLineIndex:(unsigned int)inLineIndex forAxis:(SM2DGraphAxisEnum)inAxis {
    double	result;

    result = 0.0;

    return result;
}

- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView attributesForLineIndex:(unsigned int)inLineIndex
{
    NSDictionary	*result = nil;

    if ( inLineIndex == 0 )
    {
        // Make the cosine line red and don't anti-alias it.
        result = [ NSDictionary dictionaryWithObjectsAndKeys:
                    [ NSNumber numberWithBool:YES ], SM2DGraphBarStyleAttributeName,
                    [ NSColor redColor ], NSForegroundColorAttributeName,
                    nil ];
    }
    else 
    {
        // Make this a bar graph.
        // We could make it blue here if every bar was blue.
        // However, we use the delegate method below to make one of the bars yellow and the rest blue.
        result = [ NSDictionary dictionaryWithObjectsAndKeys:
                    [ NSNumber numberWithBool:YES ], SM2DGraphBarStyleAttributeName,
                    [ NSColor blueColor ], NSForegroundColorAttributeName,
                    nil ];
    }

    return result;
}

#pragma mark Service Actions
- (NSString*) startActionName {
	NSString* result =  [ ServerHelper serverIsRunning ] ? @"Restart" : @"Start";
	return result;
}
- (void) setStartActionName: (id) v {
}


- (IBAction) stopService: (id)sender  {
	[ ServerHelper stopService ];
}

- (IBAction) startService: (id)sender  {
	[ _configuration saveToFile: [ PathLocator preferencesPath ]];

	if ( [ ServerHelper serverIsRunning ] ) {
		[ ServerHelper restartService ];
	} else {
		[ ServerHelper startService ];
	}
}

- (IBAction) restartService: (id)sender  {
	[ _configuration saveToFile: [ PathLocator preferencesPath ]];
	[ ServerHelper restartService ];
}

@end
