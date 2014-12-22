//
//  LBCli.h
//  AlmostVPNPRO_bsd
//
//  Created by andrei tchijov on 12/16/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LBFile : NSObject {
	NSFileManager* _fm;
}
+(LBFile*) sharedInstance;

-(NSArray*) listFilesAt: (NSString*) path;

-(BOOL) fileExistsAtPath: (NSString*) path;

-(BOOL) copyFile: (NSString*) src to: (NSString*) dst;
-(BOOL) moveFile: (NSString*) src to: (NSString*) dst;
-(BOOL) deleteFile: (NSString*) path;
@end
