//
//  LBUtils.m
//  AlmostVPN
//
//  Created by andrei tchijov on 10/17/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "LBUtils.h"


@implementation NSControl (AlmostVPN)
-(void) makeFirstResponder {
	[[ self window ] makeFirstResponder: self ];
}
@end

@implementation NSSegmentedControl (AlmostVPN)
-(void) setTooltip: (NSString*)tooltip forSegment: (int) segment {
	NSRect frame = [ self frame ];
	frame.origin.x = frame.origin.y = 0;
	frame.size.width = [ self widthForSegment: 0 ];
	for( int i = 1; i <= segment; i++ ) {
		frame.origin.x += frame.size.width;
		frame.size.width = [ self widthForSegment: i ];
	}
	[ self addToolTipRect: frame owner: tooltip userData: nil ];
}
@end


@implementation NSMutableArray (AlmostVPN) 
- (BOOL) addNewObject: (id) object {
	if( ! [ self containsObject: object ] ) {
		[ self addObject: object ];
		return YES;
	} else {
		return NO;
	}
}
@end

@implementation NSView (AlmostVPN)
- (void)setEnabled: (BOOL) yesNo forAllSubviewsExcept: (NSArray*)someViews {
	NSArray* subviews = [ self subviews ];
	if( [ subviews count ] == 0 ) {
		if( [ self isKindOfClass: [ NSControl class ]] ) {
			[ ((NSControl*)self) setEnabled: yesNo ];			
		}
		return;
	}
	for( int i = 0; i < [ subviews count ]; i++ ) {
		id view = [ subviews objectAtIndex: i ];
		if ( [ someViews containsObject: view ] ) {
			continue;
		}
		[ view setEnabled: yesNo forAllSubviewsExcept: someViews ];
	}
}
@end

@implementation NSTextView (AlmostVPN) 
- (NSString*) stringValue {
	return [[ self textStorage ] string ];
}

- (NSRange)setStringValue: (NSString*) aString {
    NSRange endRange;
    endRange.location = 0;
    endRange.length = [[self textStorage] length];
    [self replaceCharactersInRange:endRange withString:aString];
    [self scrollRangeToVisible:endRange];	
	return endRange;
}

- (NSRange)appendFormat: (NSString*) format, ... {
	va_list ap;
	
	va_start( ap, format );
	
	NSString* string = [[ NSString alloc ] initWithFormat: format arguments: ap ];
	return [ self appendString: string ];
}

- (NSRange)appendString: (NSString*) aString {
	return [ self appendString: aString withColor: nil andFont: nil ];
}

- (NSRange)appendString: (NSString*) aString withColor: (NSColor*)color andFont: (NSFont*) font {
    NSRange endRange;
    endRange.location = [[self textStorage] length];
    endRange.length = 0;
    [self replaceCharactersInRange:endRange withString:aString];	
    endRange.length = [aString length];
	NSMutableDictionary* attributes = [ NSMutableDictionary dictionary ];
	if( color != nil ) {
		[ attributes setObject: color forKey: NSForegroundColorAttributeName ];
	}
	if( font != nil ) {
		[ attributes setObject: font forKey: NSFontAttributeName ];
	}
	if( [ attributes count ] > 0 ) {
		[[ self textStorage ] setAttributes: attributes range: endRange ];				
	}
    [self scrollRangeToVisible:endRange];	
	return endRange;
}

- (void) setForegroundColor: (NSColor*) color forRange: (NSRange) range {
	NSDictionary* attributes = [ NSDictionary dictionaryWithObject: color forKey: NSForegroundColorAttributeName ];
	[[ self textStorage ] setAttributes: attributes range: range ];
}

- (void) setBackgroundColor: (NSColor*) color forRange: (NSRange) range {
	NSDictionary* attributes = [ NSDictionary dictionaryWithObject: color forKey: NSBackgroundColorAttributeName ];
	[[ self textStorage ] setAttributes: attributes range: range ];
}

- (void) setFont: (NSFont*) font forRange: (NSRange) range {
	NSDictionary* attributes = [ NSDictionary dictionaryWithObject: font forKey: NSFontAttributeName ];
	[[ self textStorage ] setAttributes: attributes range: range ];
}
@end