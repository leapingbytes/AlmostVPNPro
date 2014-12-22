#import "LBArrayController.h"

@implementation LBArrayController

- (NSObject*) delegate {
	return delegate;
}

- (void) setDelegate: (NSObject*) aDelegate {
	delegate = aDelegate;
}

- (NSObject*) selectedObject {
	NSIndexSet* selection = [ self selectionIndexes ];
	if( [ selection count ] == 0 ) {
		return nil;
	}
	int selectionIndex = [ selection firstIndex ];
	
	NSObject* selectedObject = [[ self arrangedObjects ] objectAtIndex: selectionIndex ];
	return selectedObject;
}

- (IBAction)segmentedAction:(id)sender {
	int selectedSegment = [ sender selectedSegment ];
	NSString* selectedLabel = [ sender labelForSegment: selectedSegment ];
	
	BOOL done = NO;
	
	if(( delegate != nil ) && [ delegate respondsToSelector: @selector( controller:askedToPerformSegmentedAction: ) ] ) {
		done = nil != [ delegate performSelector: @selector( controller:askedToPerformSegmentedAction: ) withObject: self withObject: selectedLabel ] ;
	}
	if( done ) {
		// We are done.
	} else if( [ @"+" isEqual: selectedLabel ] ) {
		[ self add: sender ];
	} else if( [ @"-" isEqual: selectedLabel ] ) {
		NSObject* selectedObject = [ self selectedObject ];
		if( [ selectedObject respondsToSelector: @selector( objectWillBeDeleted ) ] ) {
			int rc = NSRunAlertPanel( 
				@"Alert",
				@"Are you sure you want to delete\n%@?", 
				@"OK", nil, @"Cancel",
				[ selectedObject description ]
			);
			if( rc == 1 ) {
				[ selectedObject performSelector: @selector( objectWillBeDeleted ) ];
				[ self remove: sender ];
			}		
		} else {
			[ self remove: sender ];
		}
	} else if( [ @"x2" isEqual: selectedLabel ] ) {
		NSObject* selectedObject = [ self selectedObject ];
		NSObject* newObject = [[[ selectedObject class ] alloc ] init ];
		if( [ newObject respondsToSelector: @selector( copyFrom: ) ] ) {
			[ newObject performSelector: @selector( copyFrom: ) withObject: selectedObject ];
		}
		[ self addObject: newObject ];
//	} else if( [ @"/etc/hosts" isEqual: selectedLabel ] ) {
//		[ AlmostVPN importEtcHosts ];
	} else if( [ @"All" isEqual: selectedLabel ] ) {
		NSArray* arrangedObjects = [ self arrangedObjects ];
		for( int i = 0; i < [ arrangedObjects count ]; i++ ) {
			[[ arrangedObjects objectAtIndex: i ] performSelector: @selector( setActive: ) withObject: [ NSNumber numberWithBool: YES ]];
		}
	} else if( [ @"None" isEqual: selectedLabel ] ) {
		NSArray* arrangedObjects = [ self arrangedObjects ];
		for( int i = 0; i < [ arrangedObjects count ]; i++ ) {
			[[ arrangedObjects objectAtIndex: i ] performSelector: @selector( setActive: ) withObject: [ NSNumber numberWithBool: NO ]];
		}
	} else if( [ @"Toggle" isEqual: selectedLabel ] ) {
		NSArray* arrangedObjects = [ self arrangedObjects ];
		for( int i = 0; i < [ arrangedObjects count ]; i++ ) {
			[[ arrangedObjects objectAtIndex: i ] performSelector: @selector( toggleActive ) ];
		}
	}
}

- (IBAction)rearangeObjects: (id)sender {
	[ self rearrangeObjects ];
}
@end
