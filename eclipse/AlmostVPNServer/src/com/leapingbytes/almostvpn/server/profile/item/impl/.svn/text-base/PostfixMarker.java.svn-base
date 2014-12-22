package com.leapingbytes.almostvpn.server.profile.item.impl;

import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;

public class PostfixMarker extends Marker {
	private static final PostfixMarker _singleton = new PostfixMarker();
	
	private PostfixMarker() {
		super( "::postfix::");
		setPrerequisit( PrefixMarker.marker());
	}
	
	public static PostfixMarker marker() {
		return _singleton;
	}
	
	public static void addPosfixItem( IProfileItem item ) {
		((BaseProfileItem)item).setPrerequisit( _singleton );
	}
}
