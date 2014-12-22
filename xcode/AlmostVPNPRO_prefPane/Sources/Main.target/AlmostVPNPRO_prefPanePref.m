//
//  AlmostVPNPRO_prefPanePref.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 10/25/05.
//  Copyright (c) 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNPRO_prefPanePref.h"
#import "PathLocator.h"
#import "InstallManager.h"


@implementation AlmostVPNPRO_prefPanePref


- (id)initWithBundle:(NSBundle *) bundle {
	long osVersion = 0;
	Gestalt( gestaltSystemVersion, &osVersion );
	if( osVersion != 0 && (( osVersion & 0xfff0 ) <= 0x01030 )) {
		NSRunCriticalAlertPanel( 
			@"Fatal Problem", 
			@"AlmostVPN 1.0 require Tiger (10.4.x) or better.\n"
			"Last version of AlmostVPN which supports Panther is 0.9.15\n"
			"Will exit now.", 
			@"OK", nil, nil 
		);
		exit(1);
	}	
	
	[ PathLocator setPrefPaneBundle: bundle ];
	
	[ InstallManager ensureInstall ];
	
	return [ super initWithBundle: bundle ];
}

- (void) mainViewDidLoad {
}

@end
