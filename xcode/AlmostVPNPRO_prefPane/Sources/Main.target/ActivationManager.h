//
//  ActivationManager.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/15/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ActivationManager : NSObject {

	IBOutlet id		_forPayIndicator;
}
- (IBAction) buyNow: (id)sender ;
- (IBAction) buyAtKagi: (id)sender ;
- (IBAction) buyAtPayPal: (id)sender ;
- (IBAction) activate: (id)sender ;
- (IBAction) deactivate: (id)sender ;

- (void) setActivationFullName: (id) v;
- (void) setActivationEmail: (id) v;

- (id) activationKey;
- (void) setActivationKey: (id) v;

- (void) setActivationOk: (id) v;

- (id) activationLevel;
- (void) setActivationLevel: (id) v ;

- (id) activationOk;
@end
