#import "LBNSTabView.h"

@implementation LBNSTabView

- (IBAction)takeSelectedTabViewItemFromSenderTitle:(id)sender {
	NSString* senderTitle = [ sender title ];
	
	[ self selectTabViewItemWithIdentifier: senderTitle ];
}

@end
