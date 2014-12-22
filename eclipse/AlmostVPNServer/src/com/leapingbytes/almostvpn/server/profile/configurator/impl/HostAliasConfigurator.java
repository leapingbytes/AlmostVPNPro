package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.model.AVPNConfiguration;
import com.leapingbytes.almostvpn.model.Model;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.BaseConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.impl.AliasHostName;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.jcocoa.NSDictionary;
import com.leapingbytes.jcocoa.NSMutableDictionary;

public class HostAliasConfigurator extends BaseConfigurator {
//	private String msg = null;
	private static final Log log = LogFactory.getLog( PrinterConfigurator.class );

	protected HostAliasConfigurator() {
		super("AlmostVPNHostAlias");
	}

	public IProfileItem configure(NSDictionary definition ) throws ProfileException {
		super.configure(definition);
		
		IProfileItem result = null;
		
		Model hostAlias = new Model( definition );
		Model realHost = hostAlias.referencedModel();
		
		String aliasAddress = hostAlias.aliasAddress();
		aliasAddress = Model.AVPNAutoAddressMarker.equals( aliasAddress ) ? null : aliasAddress;
		AliasHostName aliasHostName = (AliasHostName) add( new AliasHostName( hostAlias.aliasName(), aliasAddress, true ) );
		
		/*
		 * Make sure that hostAlias contains alias-address ( which could be auto-allocated )
		 */
		hostAlias.definition().put( Model.AVPNAliasAddressProperty, aliasHostName.address());
		hostAlias.definition().put( Model.AVPNAddressProperty, aliasHostName.address());
		
		NSDictionary[] children = Model.allChildren( realHost.definition());
		if( children.length == 0 ) {
			Model 	serviceLocation = realHost.isLocation() || realHost.isLocalhost() ?
					realHost :
					realHost.parentModel();
			//
			// SessionConfigurator will create SSHSession and add it to profile items
			//
			profile().configure( serviceLocation.definition());			
		} else {
			boolean isRecursive = hostAlias.recursiveHostAlias();
			
			for( int i = 0; i < children.length; i++ ) {
				Model child = new Model( children[ i ] );
				
				if( child.isOfClass( Model.AVPNLocationClass) || child.isOfClass( Model.AVPNHostClass )) {
					if( isRecursive ) {
						NSMutableDictionary recursiveHostAlias = AVPNConfiguration.createTemporaryObject();
						recursiveHostAlias.setObjectForKey( child.className(), Model.AVPNClassNameProperty );
						recursiveHostAlias.setObjectForKey( hostAlias.uuid(), Model.AVPNParentUUIDProperty );
						recursiveHostAlias.setObjectForKey( child.uuid(), Model.AVPNRefObjUUIDProperty );
						recursiveHostAlias.setObjectForKey( child.name(), Model.AVPNAliasNameProperty );
						recursiveHostAlias.setObjectForKey( "<auto>", Model.AVPNAliasAddressProperty );
						recursiveHostAlias.setObjectForKey( "true", Model.AVPNRecursiveHostAlias );
						
						configure( recursiveHostAlias );
						
						AVPNConfiguration.deleteTemporaryObject( recursiveHostAlias );
					}
					continue;
				}
				NSMutableDictionary childRef = new NSMutableDictionary();			
				childRef.setObjectForKey( hostAlias.uuid(), Model.AVPNParentUUIDProperty );
				childRef.setObjectForKey( child.uuid(), Model.AVPNRefObjUUIDProperty );
				
				if( child.isOfClass( Model.AVPNServiceClass )) {
					childRef.setObjectForKey( Model.AVPNTunnelClass, Model.AVPNClassNameProperty );
	
					childRef.setObjectForKey( "" + child.port(), Model.AVPNSourcePortProperty );
					childRef.setObjectForKey( Model.localhost().uuid(), Model.AVPNSourceLocationProperty );
					
				} else if( child.isOfClass( Model.AVPNPrinterClass )) {
					childRef.setObjectForKey( Model.AVPNPrinterRefClass, Model.AVPNClassNameProperty );
					childRef.setObjectForKey( "yes", Model.AVPNUseCUPSProperty );
					childRef.setObjectForKey( "yes", Model.AVPNUseBonjourProperty );
				} else if( child.isOfClass( Model.AVPNDriveClass )) {
					childRef.setObjectForKey( Model.AVPNDriveRefClass, Model.AVPNClassNameProperty );								
					if( child.path() != null && child.path().length() > 0 ) {
						childRef.setObjectForKey( "yes", Model.AVPNMountOnStartProperty );
						childRef.setObjectForKey( "no", Model.AVPNUseBonjourProperty );
					} else {
						childRef.setObjectForKey( "no", Model.AVPNMountOnStartProperty );
						childRef.setObjectForKey( "yes", Model.AVPNUseBonjourProperty );
					}
				} else if( child.isOfClass( Model.AVPNRemoteControlClass )) {
					childRef.setObjectForKey( Model.AVPNRemoteControlRefClass, Model.AVPNClassNameProperty );
					childRef.setObjectForKey( "yes", Model.AVPNUseBonjourProperty );
				} else if( child.isOfClass( Model.AVPNBonjourClass )) {
					childRef.setObjectForKey( Model.AVPNBonjourRefClass, Model.AVPNClassNameProperty );
					childRef.setObjectForKey( "" + child.port(), Model.AVPNLocalPortProperty );
				} else if( child.isOfClass( Model.AVPNFileClass )) {
					log.info( "File can not be accessed via host alias");
					continue;
				}
				ConfiguratorRepository.findConfigurator( childRef ).configure( childRef );
			}
		}
		
		return result;
	}
}
