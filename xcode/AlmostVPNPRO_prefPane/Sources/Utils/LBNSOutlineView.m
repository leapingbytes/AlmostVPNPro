//
//  LBNSOutlineView.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 12/5/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import "LBNSOutlineView.h"


@implementation LBNSOutlineView
- (void) keyDown: (NSEvent *)theEvent {
	int keyCode = [ theEvent keyCode ];
	switch( keyCode ) {
		case 51 : // delete key
			if( [[ self delegate ] respondsToSelector: @selector( deleteKeyDownInOutlineView: ) ] ) {
				[[ self delegate ] performSelector: @selector( deleteKeyDownInOutlineView: ) withObject: self ];
			}
		break;
		default :
			[ super keyDown: theEvent ];
	}
}

- (void) expandAndMakeVisibleItem: (id) anItem {
	id delegate = [ self delegate ];
	if( [ delegate respondsToSelector: @selector( outlineView:parentOfItem: ) ] ) {
		if ( [ self rowForItem: anItem ] < 0 ) {
			id parentItem = [ delegate performSelector: @selector( outlineView:parentOfItem: ) withObject: self withObject: anItem ];
			if( parentItem != nil ) {
				[ self expandAndMakeVisibleItem: parentItem ];
				[ self expandItem: parentItem ];
			} else {
				[ NSException raise: @"Error" format: @"Fail to get parent for : %@", anItem ];
			}
		}
		[ self scrollRowToVisible: [ self rowForItem: anItem ]];
		[ self selectRow: [ self rowForItem: anItem ] byExtendingSelection: NO ];
	} else {
		[ NSException raise: @"Error" format: @"Delegate should support 'outlineView:parentOfItem:'" ];
	}
}
@end
