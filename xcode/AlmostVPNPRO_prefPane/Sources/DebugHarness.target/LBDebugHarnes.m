#import "LBDebugHarnes.h"
#import "LBAlmostVPNController.h"

//#import "libGandbug.h"

@implementation LBDebugHarnes

- (void) awakeFromNib {
	[ self showPane: self ];
}

- (IBAction)showPane:(id)sender {
	LBAlmostVPNController* controller = [[ LBAlmostVPNController alloc ] init ];
	id cWindow = [ controller window ];
	[ window setContentView: [ cWindow contentView ]];
	[ cWindow close ];	
}

@end
