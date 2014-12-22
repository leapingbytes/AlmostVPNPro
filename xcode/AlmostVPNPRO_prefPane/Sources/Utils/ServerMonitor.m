//
//  ServerMonitor.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 4/4/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "ServerMonitor.h"
#import "ServerHelper.h"


NSMutableDictionary*	_monitors;
static int _tryCount = 0;
static int _maxTryCount = 5;
@implementation ServerMonitor
+(void) initialize {
	_monitors = [[ NSMutableDictionary alloc ] init ];
}

- (id) initWithServer: (NSString*) server {
	id result = [ _monitors objectForKey: server ];
	if( result != nil ) {
		return result;
	} 
	_server = server;
	_errorCount = 0;
	
	[ _monitors setObject: self forKey: server ];

	_timer = [ NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector( tryToStart: ) userInfo: nil repeats: YES ];
	
	return self;
}

- (void) tryToStart: (NSTimer*) t {	
	[ self start ];
}

- (void) start {
	@synchronized ( self ) {
		if( _running ) {
			return;
		}
		_tryCount++;
		if( _tryCount < _maxTryCount ) {
			return;
		}
		_maxTryCount = _maxTryCount < 5 ? _maxTryCount + 1 : _maxTryCount;		
		_tryCount = 0;
		
		if( _errorCount > 5  ){
			_errorCount = 0;
			[ ServerHelper setServerIsRunning: NO ];
			return;
		}
		_running = YES;
		_errorCount ++;
		
		NSHost *host = [NSHost hostWithAddress: @"127.0.0.1" ];

		_iStream = nil;
		_oStream = nil;
		[NSStream getStreamsToHost:host port: 1313 inputStream:&_iStream outputStream:&_oStream];
		if( _iStream == nil || _oStream == nil ) {
			[ ServerHelper setServerIsRunning: NO ];
			_errorCount = 0;
			_running = NO;
		} else {
			[_iStream retain];
			[_oStream retain];
			[_iStream setDelegate:self];
			[_oStream setDelegate:self];
			[_iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]	forMode:NSDefaultRunLoopMode];
			[_oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]	forMode:NSDefaultRunLoopMode];
			[_iStream open];
			[_oStream open];	
		}
	}
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            if (stream == _oStream) {
                const char* requestStr = [ @"GET /almostvpn/control/do?action=monitor HTTP/1.0\r\n\r\n" UTF8String ];
                [_oStream write: (unsigned char*)requestStr maxLength:strlen( requestStr )]; 
                [_oStream close];
            }
            break;
        }
		case kCFStreamEventHasBytesAvailable: {
			_errorCount = 0;
			UInt8 buf[ 64*1024 ];
			CFIndex lineStart = 0;
            CFIndex bytesRead = 0;
			CFIndex readSoFar = 0;
			while ( YES ) {
				bytesRead = CFReadStreamRead((CFReadStreamRef)_iStream, buf + readSoFar , sizeof( buf ) - readSoFar );
				if (bytesRead > 0) {			
					readSoFar += bytesRead;
					[ ServerHelper setServerIsRunning: YES ];
					
					for( int i = lineStart; i < readSoFar; i++ ) {
						if( buf[i] == '\n' ) { // new line
							NSString* line = [[ NSString alloc ] initWithBytes: buf + lineStart length: i - lineStart encoding: NSUTF8StringEncoding ];
								[[ NSNotificationCenter defaultCenter ] postNotificationName: @"ServerEvent" object: line ];		
							[ line release ];
							lineStart = i + 1;
						}
					}	
					
					if( lineStart < readSoFar ) { // incomplete last line 
						readSoFar = readSoFar - lineStart;
						memmove( buf, buf + lineStart, readSoFar );
						lineStart = 0;
					} else {
						lineStart = 0;
						readSoFar = 0;
					}					
					
					if( CFReadStreamHasBytesAvailable( (CFReadStreamRef)_iStream )) {
						continue;
					} else {
						break;
					}
				} else {
					break;
				}
			}
			break;
		}		
		case NSStreamEventErrorOccurred : 
		case NSStreamEventEndEncountered : {
//			NSError *theError = [stream streamError];
//            NSAlert *theAlert = [[NSAlert alloc] init]; // modal delegate releases
//            [theAlert setMessageText:@"Error reading stream!"];
//            [theAlert setInformativeText:[NSString stringWithFormat:@"Error %i: %@",
//                [theError code], [theError localizedDescription]]];
//            [theAlert addButtonWithTitle:@"OK"];
//            [theAlert beginSheetModalForWindow:[NSApp mainWindow]
//                modalDelegate:self
//                didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
//                contextInfo:nil];
		
			[ _iStream close ];
			[ _iStream release ];
			[ _oStream close ];
			[ _oStream release ];
			_running = NO;
			_maxTryCount = 1;
			[ self start ];
			break;
		}
    }
}


+(ServerMonitor*) monitor: (NSString*) server {
	ServerMonitor* monitor = [[ ServerMonitor alloc ] initWithServer: server ];
	[ monitor start ];
	return monitor;
}

@end
