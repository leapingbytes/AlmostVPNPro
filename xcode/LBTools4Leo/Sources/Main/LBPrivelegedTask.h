//
//  LBPrivelegedTask.h
//  LBToolbox
//
//  Created by andrei tchijov on 2/1/07.
//  Copyright 2007 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LBPrivelegedTask : NSTask {
	NSString*		_currentDirectoryPath;
	NSString*		_launchPath;
	NSArray*		_arguments;
	NSDictionary*	_env;
	
	id				_stdIn;
	id				_stdOut;
	id				_stdErr;

	int				_pipeFno;
	int				_stdInFno;
	int				_stdOutFno;
	
	NSMutableArray* _toClose;
}
@end
