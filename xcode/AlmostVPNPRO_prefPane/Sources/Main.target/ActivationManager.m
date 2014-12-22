//
//  ActivationManager.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 7/15/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "ActivationManager.h"
#import "ServerHelper.h"
#import "AlmostVPNModel.h"
#import "ForPayManager.h"
#import "ZonicKRM.h"

#define _KAGI_STORE_URL_	@"http://store.kagi.com/cgi-bin/store.cgi?storeID=6FCAB_LIVE"
#define _PAYPAL_STORE_URL_	@"http://www.leapingbytes.com/redirects/avpn1.0paypal.html"

static NSString*	KEY=nil;
static NSString*	FULL_NAME = nil;
static NSString*	EMAIL = nil;
static NSString*	DATE = nil;

static BOOL			ACTIVATED = NO;
static int			LEVEL=-1;

void GetDemoPriceExplicit(ZKRMParameters *theParameters);

@implementation ActivationManager

- (IBAction) buyNow: (id)sender  {
	ZKRMParameters		theParameters;
	ZKRMModuleStatus	theStatus;
	ZKRMResult			*theResult;

	GetDemoPriceExplicit( &theParameters );
	theParameters.moduleUserName = (CFStringRef)FULL_NAME;
	theParameters.moduleUserEmail = (CFStringRef)EMAIL;
	theParameters.moduleOptions |= kZKRMOptionModalPrintDialogs;

	// Invoke the KRM
	theStatus = [[ZonicKRMController sharedController] runModalKRMWithParameters:&theParameters toResult:&theResult];

	if( theStatus == kZKRMModuleNoErr && theResult->orderStatus == kZKRMOrderSuccess ) {
		[ self setActivationKey: (id)(theResult->acgRegCode) ];
		[ self activate: nil ];
	}

	// Clean up
	DisposeKRMResult(&theResult);

}

- (IBAction) buyAtKagi: (id)sender  {
	[[ NSWorkspace sharedWorkspace ] openURL: [ NSURL URLWithString: _KAGI_STORE_URL_ ]];
}

- (IBAction) buyAtPayPal: (id)sender  {
	[[ NSWorkspace sharedWorkspace ] openURL: [ NSURL URLWithString: _PAYPAL_STORE_URL_ ]];
}

- (void) checkLevel: (NSString*) level {
	if( [ @"ERROR" isEqual: level ] ) {
		ACTIVATED = NO;
		LEVEL=0;
	} else {
		ACTIVATED = YES;
		if( [ @"L1" isEqual: level ] ) {
			LEVEL=1;
		} else if( [ @"L2" isEqual: level ] ) {
			LEVEL=2;
		} else {
			ACTIVATED = NO;
			LEVEL=0;
		}
	}
	
	[ self setActivationOk: nil ];
	[ self setActivationKey: nil ];
	[ self setActivationLevel: nil ];
	[[ ForPayManager sharedInstance ] setForPayFeaturesUsed: nil ];
}

- (IBAction) activate: (id)sender {
	if( [ FULL_NAME length ] == 0 ) {
		NSRunCriticalAlertPanel( 
			@"Full Name is Empty", 
			@"Please enter Full Name\n"
			 "as it appear in activateion e-mail\n",
			 @"OK", nil, nil 
		);
		return;
	}
	if( [ EMAIL length ] == 0 ) {
		NSRunCriticalAlertPanel( 
			@"Email is Empty", 
			@"Please enter e-mail\n"
			 "as it appear in activateion e-mail\n",
			 @"OK", nil, nil 
		);
		return;
	}
	if( [ KEY length ] == 0 ) {
		NSRunCriticalAlertPanel( 
			@"Activation Key is Empty", 
			@"Please enter Activation Key\n"
			 "as it appear in activateion e-mail\n",
			 @"OK", nil, nil 
		);
		return;
	}
	
	NSString* level = [ ServerHelper saveRegistrationKey: KEY forUser: FULL_NAME withEMail: EMAIL ];
	[ self checkLevel: level ];
}

- (IBAction) deactivate: (id)sender {
	[ self setActivationKey: [ ServerHelper forgetRegistration ] ];

	ACTIVATED = NO;
	LEVEL=0;
	[ self setActivationOk: nil ];
	[ self setActivationLevel: nil ];
	[[ ForPayManager sharedInstance ] setForPayFeaturesUsed: nil ];
}

#pragma mark Bindings
- (id) activationKey {
	if( ACTIVATED ) {
		return KEY != nil ? KEY : [ NSString stringWithFormat: @"<ACTIVATED AT LEVEL %@>", ( LEVEL == 1 ? @"1.x" : @"2.x" )];
	} else {
		return @"";
	}
}

- (void) setActivationKey: (id) v {
	v = [ v copy ];
	[ KEY release ];
	KEY = v;
}

- (id) activationFullName {
	return FULL_NAME;
}

- (void) setActivationFullName: (id) v {
	if( v != nil ) {
		v = [ v copy ];
		[ FULL_NAME release ];
		FULL_NAME = v;
		
		[[ AlmostVPNConfiguration sharedInstance ] setFullName: v ];
		LEVEL = -1;
	}
}

- (id) activationDate {
	return DATE;
}

- (void) setActivationDate: (id) v {
}

- (id) activationEmail {
	return EMAIL;
}

- (void) setActivationEmail: (id) v {
	if( v != nil ) {
		v = [ v copy ];
		[ EMAIL release ];
		EMAIL = v;

		[[ AlmostVPNConfiguration sharedInstance ] setEmail: v ];
		LEVEL = -1;
	}
}

- (id) activationLevel {
	return [ NSNumber numberWithInt: LEVEL ];
}

- (void) setActivationLevel: (id) v {
}


- (id) activationOk {
	if( FULL_NAME != nil && EMAIL != nil && LEVEL == -1 ) {
		LEVEL=0;
		NSString* level = [ ServerHelper verifyRegistrationForUser: FULL_NAME withEMail: EMAIL ];
		[ self checkLevel: level ];
	} else if( LEVEL == -1 ) {
		ACTIVATED = NO;
	}
	
	return [ NSNumber numberWithBool: ACTIVATED ];
}

- (void) setActivationOk: (id) v {
	if(( v != nil ) && ([ v intValue ] == 3 )) {
		LEVEL = -1;
	}
}
@end

//=============================================================================
//		GetDemoPriceExplicit : Get the demo parameters with explicit pricing.
//-----------------------------------------------------------------------------
void GetDemoPriceExplicit(ZKRMParameters *theParameters) {
	// Prepare the KRM parameters
	//
	// The following information should be customised:
	//
	//		http://www.mywebsite.invalid/*.html		URLs to your web site
	//		UC9										Your vendor code    (as held by Kagi)
	//		KART_TEST_COMPLEX_ACG_UC9				Your product name   (as held by Kagi)
	//		"My Product"							Your product name   (as seen by user)
	//		<price>									Pricing information (e.g., explicit currency-specific prices)
	//		http://order.kagi.com/?UC9				URL to your store   (as held by Kagi)
	//		My_Affiliate							An affiliate code   (as held by Kagi)
	//
	// This example uses explicit currency-specific pricing.
	//
	// This example also demonstrates key-value pairs being passed to the ACG system,
	// a custom purchase order number, and a string to include in the TFYP email.
	InitKRMParameters(theParameters);
	
	theParameters->moduleLanguage  = kZKRMLanguageSystem;
	theParameters->moduleOptions   = kZKRMOptionOfferWebOrder;
//	theParameters->moduleUserName  = NULL;
//	theParameters->moduleUserEmail = NULL;
	theParameters->productInitXML  = CFSTR(
					"<krmData vendorID=\"6FCAB\">"
					"<transactionFailureURL>http://www.almostvpn.com/almostvpn/kagi/transactionFailure.html</transactionFailureURL>"
					"<connectionFailureURL>http://www.almostvpn.com/almostvpn/kagi/connectionFailure.html</connectionFailureURL>"
					"<products>"
						"<product partNo=\"7659-9791-1914\" dbName=\"AlmostVPN1_0\" supplierSKU=\"n/a\">"
							"<displayName lang=\"en\">AlmostVPN/1.0 Activation Key</displayName>"
							"<price currency=\"USD\">15.00</price>"
						"</product>"
					"</products>"
					"</krmData>");
	//theParameters->productStoreURL  = CFSTR("http://store.kagi.com/cgi-bin/store.cgi?storeID=6FCAB_LIVE&lang=en");
	theParameters->productStoreURL  = (CFStringRef)_KAGI_STORE_URL_;
	
//	theParameters->productTFYP      = CFSTR("Custom string to include in the TFYP email");
//	theParameters->productPO        = CFSTR("Custom string to use as a Purchase Order number");
//	theParameters->productAffiliate = CFSTR("My_Affiliate");	
//	theParameters->acgKeyValueCount = 2;
//	theParameters->acgKeyValueData  = acgData;
}



