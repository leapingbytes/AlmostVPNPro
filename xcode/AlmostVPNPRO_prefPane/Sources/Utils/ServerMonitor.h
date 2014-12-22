//
//  ServerMonitor.h
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 4/4/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@protocol ServerMonitorListener
	- (void) serverMonitorEvent: (NSString*) str;
@end

@interface ServerMonitor : NSObject {

	NSString*					_server;
	NSURL*						_url;
	
	NSInputStream*				_iStream;
	NSOutputStream*				_oStream;
	
	int							_errorCount;
	BOOL						_running;
	
	NSTimer*					_timer;
}

+ (ServerMonitor*) monitor:(NSString*) host;

-(void) start;

@end
