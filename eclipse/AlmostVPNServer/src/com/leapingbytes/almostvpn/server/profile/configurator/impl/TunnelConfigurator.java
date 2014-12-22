package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import com.leapingbytes.almostvpn.model.Model;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.BaseConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHPortForward;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHSession;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHUdpPortForward;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.jcocoa.NSDictionary;

public class TunnelConfigurator extends BaseConfigurator {
	protected TunnelConfigurator() {
		super("AlmostVPNTunnel");
	}

	public IProfileItem configure( NSDictionary definition) throws ProfileException {
		IProfileItem	portForward = null;

		super.configure( definition );
		
		Model	tunnel = new Model( definition );
		Model 	tunnelParent = tunnel.parentModel();
		
		String bindToAddress = tunnelParent.isProfile() ? null : tunnelParent.aliasAddress();
		
		bindToAddress = tunnel.shareWithOthers() ? "0.0.0.0" : bindToAddress;
		
		Model	service = tunnel.referencedModel();
		Model	serviceHost = service.parentModel();
		Model 	serviceLocation = serviceHost.isLocation() || serviceHost.isLocalhost() ?
			serviceHost :
			serviceHost.parentModel();
		
		Model	sourceLocation = tunnel.modelReferencedBy( Model.AVPNSourceLocationProperty );
		int		sourcePort = tunnel.sourcePort();
		
		boolean sourceLocal = sourceLocation.isLocalhost();
		boolean sourceOverthere = sourceLocation.isOverthere();

		boolean serviceLocal = serviceHost.isLocalhost() || serviceHost.parentModel().isLocalhost();
		boolean serviceOverthere = serviceHost.isOverthere();
		
		boolean tunnelTCP = service.doTCP();
		boolean tunnelUDP = service.doUDP();
		
		if( sourceLocal && serviceOverthere ) { 			// Simple/multi-hope local tunnel
			SSHSession session = (SSHSession) profile().configure( serviceLocation.definition());			
			boolean useHostAsIs = tunnel.useHostAsIs();
			if( tunnelTCP ) {
				portForward = new SSHPortForward( 
					session, 
					SSHPortForward.LOCAL, 
					sourcePort, 
					useHostAsIs ? serviceHost.name() : serviceHost.address(), 
					service.port(), useHostAsIs 
				);
				if( bindToAddress != null ) {
					((SSHPortForward)portForward).setBindToAddress( bindToAddress );
				}
			}
			if( tunnelUDP ) {
				if( portForward != null ) {
					portForward = (SSHPortForward) add( portForward );		
				}
				portForward = new SSHUdpPortForward( 
						session, 
						SSHPortForward.LOCAL, 
						sourcePort, 
						useHostAsIs ? serviceHost.name() : serviceHost.address(), 
						service.port(), useHostAsIs 
					);
				if( bindToAddress != null ) {
					((SSHUdpPortForward)portForward).setBindToAddress( bindToAddress );
				}
			}
		} else if( serviceLocal && sourceOverthere ) { 		// Simple/muti-hope remote tunnel
			SSHSession session = (SSHSession) profile().configure( sourceLocation.definition());
			if( tunnelTCP ) {
				portForward = new SSHPortForward( session, SSHPortForward.REMOTE, sourcePort, serviceHost.address(), service.port());
			}
			if( tunnelUDP ) {
				if( portForward != null ) {
					portForward = (SSHPortForward) add( portForward );		
				}				
				portForward = new SSHUdpPortForward( session, SSHPortForward.REMOTE, sourcePort, serviceHost.address(), service.port(), false );
			}
		} else if( serviceOverthere && sourceOverthere ) {	// Compound tunnel
			SSHSession serviceSession = (SSHSession) profile().configure( serviceLocation.definition());
			if( tunnelTCP ) {
				SSHPortForward toServiceTunnel = new SSHPortForward( serviceSession, SSHPortForward.LOCAL, 0, serviceHost.address(), service.port());			
				if( bindToAddress != null ) {
					toServiceTunnel.setBindToAddress( bindToAddress );
				}
				toServiceTunnel = (SSHPortForward) add( toServiceTunnel );		
				
				SSHSession sourceSession = (SSHSession) profile().configure( sourceLocation.definition());
					sourceSession.setPrerequisit( toServiceTunnel );
				SSHPortForward toSourceTunnel = new SSHPortForward( sourceSession, SSHPortForward.REMOTE, sourcePort, "127.0.0.1", toServiceTunnel.srcPort());
				
				portForward = toSourceTunnel;
			}
			if( tunnelUDP ) {
				throw new ProfileException( "Can not tunnel UDP via compound tunnels" );
			}
		}
		portForward = add( portForward );		
		
		return portForward;
	}	
}
