//
//  AlmostVPNPrinter.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 12/10/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "AlmostVPNPrinter.h"
#import "AlmostVPNHost.h"

#define _TYPE_KEY_				@"type"
#define _QUEUE_KEY_				@"queue"

#define _ACCOUNT_KEY_			@"account"

#define _IS_POSTSCRIPT_KEY_		@"postscript"
#define _IS_FAX_KEY_			@"fax"
#define _IS_COLOR_KEY_			@"color"

#define _MODEL_KEY_				@"model"
#define _URI_KEY_				@"uri"

@implementation AlmostVPNPrinter
+ (void) initialize {
	[self 
		setKeys:[NSArray arrayWithObjects:@"printerType", @"printerQueue", @"account", nil ]	
		triggerChangeNotificationsForDependentKey:@"printerURI"
	];
	[self 
		setKeys:[NSArray arrayWithObjects:@"printerType", @"printerQueue", nil ]	
		triggerChangeNotificationsForDependentKey:@"name"
	];
	[self 
		setKeys:[NSArray arrayWithObjects:@"postscript", @"fax", nil ]	
		triggerChangeNotificationsForDependentKey:@"printerModel"
	];
}

//+ (PrinterType) typeStringToType: (NSString*) type {
//	if( [ @"ipp" isEqual: type ] ) return IPP_PRINTER;
//	if( [ @"lpd" isEqual: type ] ) return LPD_PRINTER;
//	if( [ @"hp-jet-direct" isEqual: type ] ) return HP_JET_DIRECT_PRINTER;
//	if( [ @"smb" isEqual: type ] ) return SMB_PRINTER;
//	
//	return IPP_PRINTER;
//}
//
//+ (NSString*) typeToTypeString: (PrinterType) type {
//	NSString* result = @"ipp";
//	switch( type ) {
//		case IPP_PRINTER : result = @"ipp"; break;
//		case LPD_PRINTER : result = @"lpd"; break;
//		case HP_JET_DIRECT_PRINTER : result = @"hp-jet-direct"; break;
//		case SMB_PRINTER : result = @"smb"; break;
//	}
//	
//	return result;
//}
//

+ (NSString*) typeToProtocol: (NSString*) type {
	if( [ _IPP_PRINTER_TYPE_ isEqual: type ] ) return _IPP_PRINTER_PROTOCOL_;
	if( [ _LPD_PRINTER_TYPE_ isEqual: type ] ) return _LPD_PRINTER_PROTOCOL_;
	if( [ _HP_JET_DIRECT_TYPE_ isEqual: type ] ) return _HP_JET_DIRECT_PROTOCOL_;
	if( [ _SMB_PRINTER_TYPE_ isEqual: type ] ) return _SMB_PRINTER_PROTOCOL_;
	return type;
}

static NSArray*	_printerTypes = nil;

+ (NSArray*) printerTypes {
	if( _printerTypes == nil ) {
		_printerTypes = [[ NSArray arrayWithObjects:
			_IPP_PRINTER_TYPE_,
			_LPD_PRINTER_TYPE_,
			_HP_JET_DIRECT_TYPE_,
			_SMB_PRINTER_TYPE_,
			nil
		] retain ];
	}
	
	return _printerTypes;
}


- (void) bootstrap {
	[ super bootstrap ];
	
	[ self setPrinterType: _IPP_PRINTER_TYPE_ ];
}

- (NSString*) protocol {
	return [ AlmostVPNPrinter typeToProtocol: [ self printerType ]];
}

- (NSString*) buildURI {
	NSMutableString* result = [ NSMutableString string ];
	
	AlmostVPNHost* host = (AlmostVPNHost*)[ self parent ];
	NSString* hostName = [ host name ];
	
	NSString* queue = [ self printerQueue ];
	
	if( hostName == nil || queue == nil ) {
		return @"<incomplete>";
	}
	
	[ result appendFormat: @"%@://", [ self protocol ]];
	
	AlmostVPNAccount* account = [ self account ];
	if( account == nil ) {
		[ result appendFormat: @"%@/", hostName == nil ? @"." : hostName ];
	} else {
		[ result appendFormat: @"%@:<password>@%@/", [ account userName ], hostName ];
	}
	
	if( [[ self printerType ] isEqual: _IPP_PRINTER_TYPE_ ] ) {
		[ result appendFormat: @"printers/%@", queue ];
	} else if ( [[ self printerType ] isEqual: _HP_JET_DIRECT_TYPE_ ] ) {
		[ result appendFormat: @"%@?bidi", queue ];
	} else {
		[ result appendString: queue ];
	}
	
	return result;
}

- (NSString*)defaultPrinterModel {
	if( [ self isFax ] ) {
		return @"(Fax Printer)";
	} else if( [ self isPostscript ] ) {
		return @"(Generic PostScript Printer)";
	} else {
		return @"( PLEASE ENTER VALID MODEL )";
	}
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	[ super initWithDictionary: aDictionary ];

	[ self setObject: [ AlmostVPNObject objectWithDictionary: [ aDictionary objectForKey: _ACCOUNT_KEY_ ]] forKey: _ACCOUNT_KEY_ ];
	
	[[ self account ] setOwner: self ];

	[ self setObject: [ aDictionary objectForKey: _TYPE_KEY_ ] forKey: _TYPE_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _QUEUE_KEY_ ] forKey: _QUEUE_KEY_ ];
	
	[ self setObject: [ aDictionary objectForKey: _IS_POSTSCRIPT_KEY_ ] forKey: _IS_POSTSCRIPT_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _IS_FAX_KEY_ ] forKey: _IS_FAX_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _IS_COLOR_KEY_ ] forKey: _IS_COLOR_KEY_ ];

	[ self setObject: [ aDictionary objectForKey: _MODEL_KEY_ ] forKey: _MODEL_KEY_ ];
	[ self setObject: [ aDictionary objectForKey: _URI_KEY_ ] forKey: _URI_KEY_ ];
	
	[ AlmostVPNPrinter performOnDelegate: OBJECT_WAS_INIT_WITH_DICTIONARY withObject: self ];	
	return self;
}

- (NSString*) name {
	NSString* result =  
		[ NSString stringWithFormat: 
			@"%@://./%@",
			[ self protocol ] ,
			[ self printerQueue ]
		];
	[ self setObject: result forKey: @"name" ];
	return result;
}

- (id) printerType {
	return [ self objectForKey: _TYPE_KEY_ ];
}

- (void) setPrinterType: (id) v {
	if( [[ self printerURI ] isEqual: [ self buildURI ]] ) {
		[ self removeObjectForKey: _URI_KEY_ ];
	}

	[ self setStringValue: v forKey: _TYPE_KEY_ ];
	
	[ self printerURI ];
}

- (NSString*) printerQueue {
	return [ self stringValueForKey: _QUEUE_KEY_ ];
}

- (void) setPrinterQueue: (NSString*) v {
	if( [[ self printerURI ] isEqual: [ self buildURI ]] ) {
		[ self removeObjectForKey: _URI_KEY_ ];
	}
	[ self setStringValue: v forKey: _QUEUE_KEY_ ];
	[ self printerURI ];
}

- (AlmostVPNAccount*) account {
	return [ self objectForKey: _ACCOUNT_KEY_ ];
}

- (void) setAccount: (AlmostVPNAccount*) v {
	if( [[ self printerURI ] isEqual: [ self buildURI ]] ) {
		[ self removeObjectForKey: _URI_KEY_ ];
	}
	[ self setObject: v forKey: _ACCOUNT_KEY_ ];
	[ self printerURI ];
	[ v setOwner: self ];
}


- (BOOL) isPostscript {
	return [[ self postscript ] boolValue ];
}
- (NSNumber*) postscript {
	return [ self booleanObjectForKey: _IS_POSTSCRIPT_KEY_ ];
}
- (void) setPostscript: (NSNumber*) v {
	if( [[ self printerModel ] isEqual: [ self defaultPrinterModel ]] ) {
		[ self removeObjectForKey: _MODEL_KEY_ ];
	}
	[ self setBooleanObject: v forKey: _IS_POSTSCRIPT_KEY_ ];
	[ self printerModel ];
}

- (BOOL) isFax {
	return [[ self fax ] boolValue ];
}
- (NSNumber*) fax {
	return [ self booleanObjectForKey: _IS_FAX_KEY_ ];
}
- (void) setFax: (NSNumber*) v {
	if( [[ self printerModel ] isEqual: [ self defaultPrinterModel ]] ) {
		[ self removeObjectForKey: _MODEL_KEY_ ];
	}
	[ self setBooleanObject: v forKey: _IS_FAX_KEY_ ];
	[ self printerModel ];
}

- (BOOL) isColor {
	return [[ self color ] boolValue ];
}
- (NSNumber*) color{
	return [ self booleanObjectForKey: _IS_COLOR_KEY_ ];
}

- (void) setColor: (NSNumber*) v {
	[ self setBooleanObject: v forKey: _IS_COLOR_KEY_ ];
}

- (NSString*) printerModel {
	NSString* result = [ self objectForKey: _MODEL_KEY_ ];
	if( result == nil ) {
		result = [ self defaultPrinterModel ];
		[ self setPrinterModel: result ];
	}	
	return result;
}
- (void) setPrinterModel: (NSString*)  v {
	[ self setObject: v forKey: _MODEL_KEY_ ];
}

- (NSString*) printerURI {
	NSString* result = [ self objectForKey: _URI_KEY_ ];
	if( result == nil ) {
		result = [ self buildURI ];
		[ self setPrinterURI: result ];
	}
	[ self setObject: result forKey: _URI_KEY_ ];
	return result;
}
- (void) setPrinterURI: (NSString*) v {
	[ self setObject: v forKey: _URI_KEY_ ];
}
@end
