//
//  AlmostVPNPrinter.h
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 12/10/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlmostVPNResource.h"
#import "AlmostVPNAccount.h"

#define		_IPP_PRINTER_TYPE_		@"IPP"
#define 	_LPD_PRINTER_TYPE_		@"LPD"
#define		_HP_JET_DIRECT_TYPE_	@"HP Jet Direct"
#define		_SMB_PRINTER_TYPE_		@"SMB"

#define		_IPP_PRINTER_PROTOCOL_		@"ipp"
#define 	_LPD_PRINTER_PROTOCOL_		@"lpd"
#define		_HP_JET_DIRECT_PROTOCOL_	@"socket"
#define		_SMB_PRINTER_PROTOCOL_		@"smb"

@interface AlmostVPNPrinter : AlmostVPNResource {

}

+ (NSArray*) printerTypes;

- (id) printerType;
- (void) setPrinterType: (id) v;

- (NSString*) printerQueue;
- (void) setPrinterQueue: (NSString*) v;

- (AlmostVPNAccount*) account;
- (void) setAccount: (AlmostVPNAccount*) v;

- (BOOL) isPostscript;
- (NSNumber*) postscript;
- (void) setPostscript: (NSNumber*) v;

- (BOOL) isFax;
- (NSNumber*) fax;
- (void) setFax: (NSNumber*) v;

- (BOOL) isColor;
- (NSNumber*) color;
- (void) setColor: (NSNumber*) v;

- (NSString*) printerModel;
- (void) setPrinterModel: (NSString*)  v;

- (NSString*) printerURI;
- (void) setPrinterURI: (NSString*) v;
@end
