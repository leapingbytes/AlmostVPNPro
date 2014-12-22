#import "LBTransparentOutlineView.h"

@implementation LBTransparentOutlineView
- (void)awakeFromNib {
	
    [[self enclosingScrollView] setDrawsBackground: NO];
}

- (BOOL)isOpaque {
	
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
	
    // don't draw a background rect
}
@end
