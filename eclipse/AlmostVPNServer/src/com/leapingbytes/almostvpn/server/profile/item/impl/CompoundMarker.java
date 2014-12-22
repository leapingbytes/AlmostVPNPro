package com.leapingbytes.almostvpn.server.profile.item.impl;

import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.jcocoa.NSMutableArray;

public class CompoundMarker extends Marker {

	private NSMutableArray	_items = new NSMutableArray();
	
	public CompoundMarker( String title ) {
		super( title );
	}
	public CompoundMarker() {
		this("::compound::");
	}
	
	public void addItem( IProfileItem item ) {
		if( ! _items.contains( item )) {
			_items.add( item );
		}
	}

	public boolean dependsOn(IProfileItem v) {
		for( int i = 0; i < _items.count(); i++ ) {
			if( ((IProfileItem) _items.objectAtIndex( i )).dependsOn( v )) {
				return true;
			}
		}
		return false;
	}
}
