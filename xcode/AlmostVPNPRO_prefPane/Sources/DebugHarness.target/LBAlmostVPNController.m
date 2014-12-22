//
//  LBAlmostVPNController.m
//  AlmostVPN
//
//  Created by andrei tchijov on 8/22/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "LBAlmostVPNController.h"
#import "PathLocator.h"
#import "InstallManager.h"

@implementation LBAlmostVPNController

- (id) init {
	[ PathLocator setPrefPaneBundle: [ NSBundle mainBundle ]];
	[ PathLocator guessInstall ];
//	[ InstallManager ensureServer ];
	

	self = [ super initWithWindowNibName: @"AlmostVPNPRO_prefPanePref" ];
	return self;
}

@end
