package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import java.util.Hashtable;

import com.leapingbytes.almostvpn.model.Model;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.BaseConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.impl.BonjourAd;
import com.leapingbytes.almostvpn.server.profile.item.impl.PostfixMarker;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHPortForward;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHSession;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.jcocoa.NSDictionary;
import com.leapingbytes.jcocoa.NSMutableDictionary;

public class BonjourConfigurator extends BaseConfigurator {

	protected BonjourConfigurator() {
		super( Model.AVPNBonjourRefClass );
	}
	
	public IProfileItem configure( NSDictionary definition) throws ProfileException {
		SSHPortForward	portForward = null;
	
		super.configure( definition );
		
		Model	bonjourRef = new Model( definition );
		Model 	bonjourRefParent = bonjourRef.parentModel();
		
		String bindToAddress = bonjourRefParent.isProfile() ? null : bonjourRefParent.aliasAddress();
		
		Model	service = bonjourRef.referencedModel();
		Model	serviceHost = service.parentModel();
		Model 	serviceLocation = serviceHost.isLocation() || serviceHost.isLocalhost() ?
			serviceHost :
			serviceHost.parentModel();

		String serviceName = bonjourRef.name();
		serviceName = serviceName != null ? serviceName : service.name();
		int servicePort = bonjourRef.localPort();
	
		SSHSession session = (SSHSession) profile().configure( serviceLocation.definition());			
		portForward = new SSHPortForward( session, SSHPortForward.LOCAL, 0, serviceHost.address(), service.port());
		if( bindToAddress != null ) {
			portForward.setBindToAddress( bindToAddress );
		}
		portForward = (SSHPortForward) add( portForward );
		servicePort = portForward.srcPort();
		
		Hashtable serviceProperties = new Hashtable();
		serviceProperties.putAll(((NSMutableDictionary) service.properties()));
		
		BonjourAd bonjourAd = (BonjourAd) add( new BonjourAd( service.type() + "local.", serviceName, bindToAddress, servicePort,  serviceProperties ));
		bonjourAd.setPrerequisit( PostfixMarker.marker());
		
		
		return portForward;
	}
}
