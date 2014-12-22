/* AlmostVPNConfigurationController */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "LBNSOutlineView.h"
#import "AlmostVPNModel.h"
#import "ServerMonitor.h"
#import "BonjourManager.h"
#import "ActivationManager.h"
#import "Utils/LogRecord.h"

@interface AlmostVPNConfigurationController : NSObject <ServiceResolver,HostResolver>
{
    IBOutlet NSTabView*		topTabView;

    IBOutlet id				configurationController;
	IBOutlet id				profilesController;
	
    IBOutlet id				locationAccountBox;
    IBOutlet id				locationOptionsDisclouserButton;
	IBOutlet id				locationResourcesAndHosts;
	
	IBOutlet NSTableView*	profilesTable;
	int						_profilesTableLastSelectedIndex;
	
	IBOutlet NSTableView*	profileResourcesTable;
	
    IBOutlet NSTabView*		objectEditors;
    IBOutlet LBNSOutlineView* objectsTree;
	
	IBOutlet NSMenu*		addObjectMenu;
	IBOutlet NSMenu*		addResourceMenu;
	
	IBOutlet id				_chartView;
	IBOutlet id				_forPayIndicator;
	
	IBOutlet id				_allOfNewObjectClassController;
	
	IBOutlet ActivationManager*	_activationManager;
	
	IBOutlet NSSegmentedControl* _startStopButton;

	AlmostVPNConfiguration* _configuration;
	
	AlmostVPNLocalhost*		_localhost;
	AlmostVPNLocations*		_locations;
	AlmostVPNProfiles*		_profiles;
	AlmostVPNGroup*			_trash;
	
	NSString*				_newObjectKind;
	Class					_newObjectClass;
	AlmostVPNViewable*		_newObject;
	
	NSMutableArray*			_logRecords;
	BOOL					_logFreezed;	
	int						_maxLogRecords;
	
	id						_showTransitionalStates;
	id						_showExtraLogging;
	id						_showUtilizationEvents;
	
	BOOL					_chartFreezed;
	NSMutableArray*			_inBytesPoints;
	NSMutableArray*			_outBytesPoints;
	double					_maxValue;
	long					_lastInBytes;
	long					_lastOutBytes;	
	
			
	BonjourManager*			_bonjourManager;
	
	NSMutableDictionary*	_quickConfig;
	IBOutlet WebView*		_avpnCommandLineView;
}
+ (AlmostVPNConfigurationController*) sharedInstance;
+ (void) refreshAll;
+ (WebView*) avpnCommandLineView;

- (void) bootstrap;

- (IBAction) manageKnownServices: (id) sender;
- (IBAction) addDeleteKnownService: (id) sender;

- (IBAction) manageKnownServers: (id) sender;
- (IBAction) addDeleteKnownServer: (id) sender;

- (IBAction) duplicateOrDeleteObject: (id) sender;
- (IBAction) commitAddObject: (id) sender;
- (IBAction) cancelAddObject: (id) sender;
- (IBAction) endSheet: (id) sender;

- (IBAction) toggleLocationOptions: (id)sender;

- (IBAction) startStopProfile: (id)sender;
- (IBAction) controlLogView: (id)sender;
- (IBAction) controlUtilizationChart: (id)sender ;

- (IBAction) stopService: (id)sender ;
- (IBAction) startService: (id)sender ;
- (IBAction) restartService: (id)sender ;

- (IBAction) showQuickConfig: (id) sender;
- (IBAction) addFromQuickConfig: (id) sender;
- (IBAction) selectPlistForImport: (id) sender;

- (IBAction) testLocation: (id) sender;
- (IBAction) openActivation: (id) sender;

- (id) quickConfig;
- (void) setQuickConfig: (id) v;

- (WebView*) avpnCommandLineView;

- (void) initializeChartPoints;
- (void) addToChartIncomming: (long) incomming outgoing: (long) outgoing;

- (void) setBonjourManager: (BonjourManager*) bonjourManager;
- (BonjourManager*)	bonjourManager;

- (NSArray*) locations;
- (void) setLocations: (NSArray*) v;

- (NSArray*) hosts;
- (void) setHosts: (NSArray*) v;

- (NSArray*) profiles;
- (void) setProfiles: (NSArray*) v;

- (NSArray*) identities;
- (void) setIdentities: (NSArray*) v;
-(void) bootstrapIdentities;

- (id) selectedObjectFrom: (NSTableView*) table;
- (id) selectedObject;
- (void) setSelectedObject: (id) anObject;
- (void) deleteSelectedObject: (id) sender;
- (void) deleteSelectedObjectFrom: (id) targetTable;
- (void) duplicateSelectedObject: (id) sender;

- (NSNumber*) serverIsRunning;
- (void) setServerIsRunning: (NSNumber*) v;

- (void) logMessage: (NSString*) message from: (NSString*) source atLevel: (NSString*) level;
+ (void) logMessage: (NSString*) message from: (NSString*) source atLevel: (NSString*) level;

- (LogRecord*) addServerEvent: (NSString*) string;

- (NSString*) topLevelTab;
- (void) setTopLevelTab: (NSString*) v;

- (NSString*) preferencesTab;
- (void) setPreferencesTab: (NSString*) v;

- (id) traficChartIsFrozen;
- (void) setTraficChartIsFrozen: (id) v;

- (id) logIsFrozen;
- (void) setLogIsFrozen: (id) v;

- (id) configuration;
- (void) setConfiguration: (id) v;

- (BOOL) activationOK;

- (void) setupInitialConfiguration;

//
// Binding support
//

- (void) setVersion: (NSString*) v;
- (void) setServerState: (id) v;
- (void) setServerStateIcon: (id) v;
- (void) setStartActionName: (id) v;

- (NSMutableArray*) knownServers;
- (void) setKnownServers: (NSMutableArray*) v;

- (NSMutableArray*) knownServices;
- (void) setKnownServices: (NSMutableArray*) v;

//- (NSString*) forPayIndicator;
//- (void) setForPayIndicator: (NSString*) v;
@end
