/* LBArrayController */

#import <Cocoa/Cocoa.h>

@interface LBArrayController : NSArrayController {
	NSObject* delegate;
}
- (NSObject*) delegate;
- (void) setDelegate: (NSObject*) aDelegate;

- (IBAction)segmentedAction:(id)sender;
- (IBAction)rearangeObjects: (id)sender;

- (NSObject*)selectedObject;
@end
