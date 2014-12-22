#import "LBTransparentTableView.h"

@implementation LBTransparentTableView
- (void)awakeFromNib {
	
    [[self enclosingScrollView] setDrawsBackground: NO];
}

- (BOOL)isOpaque {
	
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
	
    // don't draw a background rect
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
	// do nothing
}


// TODO:
// See http://www.cocoabuilder.com/archive/message/cocoa/2006/5/31/164709
// 
- (id)_highlightColorForCell:(NSCell *)cell
{
   return nil;
}

@end
