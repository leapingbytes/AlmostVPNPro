//
//  LBUtils.h
//  AlmostVPN
//
//  Created by andrei tchijov on 10/17/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSControl (AlmostVPN)
-(void) makeFirstResponder;
@end

@interface NSSegmentedControl (AlmostVPN)
-(void) setTooltip: (NSString*)tooltip forSegment: (int) segment;	
@end

@interface NSMutableArray (AlmostVPN) 
- (BOOL) addNewObject: (id) object;
@end

@interface NSView (AlmostVPN)
- (void)setEnabled: (BOOL) disabledFlag forAllSubviewsExcept: (NSArray*)someViews;
@end

@interface NSTextView (AlmostVPN) 
- (NSString*)stringValue;
- (NSRange)setStringValue: (NSString*) aString;
- (NSRange)appendString: (NSString*) aString;
- (NSRange)appendFormat: (NSString*) format, ...;
- (NSRange)appendString: (NSString*) aString withColor: (NSColor*)color andFont: (NSFont*) font;

- (void) setForegroundColor: (NSColor*) color forRange: (NSRange) range;
- (void) setBackgroundColor: (NSColor*) color forRange: (NSRange) range;
- (void) setFont: (NSFont*) font forRange: (NSRange) range;
@end