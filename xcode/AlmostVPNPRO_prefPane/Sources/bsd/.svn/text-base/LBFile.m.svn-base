//
//  LBCli.m
//  AlmostVPNPRO_bsd
//
//  Created by andrei tchijov on 12/16/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "LBFile.h"

@implementation LBFile
static LBFile* _sharedInstance = nil;

+(LBFile*) sharedInstance {
	@synchronized ( self ) {
		if( _sharedInstance == nil ) {
			_sharedInstance = [[ LBFile alloc ] init ];
		}
	}
	return _sharedInstance;
}

-(id) init {
	_fm = [ NSFileManager defaultManager ];
	
	return self;
}

-(NSArray*) listFilesAt: (NSString*) path {
	return [ _fm directoryContentsAtPath: path ];
}

-(BOOL) fileExistsAtPath: (NSString*) path {
	return [ _fm fileExistsAtPath: [ path stringByExpandingTildeInPath ]];
}

-(BOOL) copyFile: (NSString*) src to: (NSString*) dst {
	return [ _fm copyPath: src toPath: dst handler: nil ];
}

-(BOOL) moveFile: (NSString*) src to: (NSString*) dst {
	return [ _fm movePath: src toPath: dst handler: nil ];
}

-(BOOL) deleteFile: (NSString*) path {
	return [ _fm removeFileAtPath: path handler: nil ];
}

@end
