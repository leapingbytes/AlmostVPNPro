package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import java.util.Hashtable;

import com.leapingbytes.almostvpn.model.Model;
import com.leapingbytes.almostvpn.path.PathLocator;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.BaseConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.impl.AliasAddress;
import com.leapingbytes.almostvpn.server.profile.item.impl.AliasHostName;
import com.leapingbytes.almostvpn.server.profile.item.impl.BonjourAd;
import com.leapingbytes.almostvpn.server.profile.item.impl.PostfixMarker;
import com.leapingbytes.almostvpn.server.profile.item.impl.PrefixMarker;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHPortForward;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHSession;
import com.leapingbytes.almostvpn.server.profile.item.impl.Script;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.almostvpn.util.Bonjour;
import com.leapingbytes.jcocoa.NSDictionary;

public class DriveConfigurator extends BaseConfigurator {
	private static final int	_DAV_PORT_NUMBER_	= 80;
	private static final int	_SMB_PORT_NUMBER_	= 139;
	private static final int	_AFP_PORT_NUMBER_	= 548;

	public DriveConfigurator() {
		super( Model.AVPNDriveRefClass );
	}

	public IProfileItem configure(NSDictionary definition) throws ProfileException {
		SSHPortForward	portForward = null;

		super.configure( definition );
		
		Model	driveRef = new Model( definition );
		Model 	driveRefParent = driveRef.parentModel();
		
		Model	drive = driveRef.referencedModel();
		Model	driveHost = drive.parentModel();
		Model 	driveLocation = driveHost.isLocation() || driveHost.isLocalhost() ?
			driveHost :
			driveHost.parentModel();
		/*
		 * Build the chain of profile items
		 */
		SSHSession session = (SSHSession) profile().configure( driveLocation.definition());			
	
		int lPort = localPort( drive );
		int rPort = remotePort( drive );
		portForward = new SSHPortForward( 
			session, 
			SSHPortForward.LOCAL, 
			lPort, 
			driveHost.isLocation() ? "127.0.0.1" : driveHost.address(), 
			rPort 
		);
		
		String portAddress;
		String driveName = null;
		if( driveRefParent.isProfile()) {
			AliasAddress	aliasAddress = (AliasAddress) add( new AliasAddress());
			aliasAddress.setPrerequisit( session );		
			portForward.setBindToAddress( portAddress = aliasAddress.ip());		
			portForward.setPrerequisit( aliasAddress );
			driveName = driveHost.name();
		} else { // Must be HostAlias
			portForward.setBindToAddress( portAddress = driveRefParent.aliasAddress());		
			driveName = driveRefParent.aliasName();
		}
		portForward = (SSHPortForward) add( portForward );

		lPort = portForward.srcPort();

		if( driveRef.useBonjour()) {
			BonjourAd bonjourAd = (BonjourAd) add( new BonjourAd( bonjourType(), driveName, portAddress, lPort,  null ));
			bonjourAd.setPrerequisit( PostfixMarker.marker());
		}
		
		if( driveRef.mountOnStart()) {
			if( drive.type().equalsIgnoreCase( Model.AVPNSMBDriveType )) {
				// SMB share should be addressed by name.
				AliasHostName aliasHostName = (AliasHostName) add( new AliasHostName( driveHost.name(), portAddress, false ));
				aliasHostName.setPrerequisit( PrefixMarker.marker() );
				portAddress = driveHost.name();
			}
			Script mountScript = (Script) add( new Script( 
				"mount" + drive.type() + " " + portAddress + " " + lPort + " " + drive.account().userName() + " " + drive.path(),
				"umountDrive \"" + Script._DO_RESULT_MARKER_ + "\"" 
			));
			mountScript.setEnv( new String[] { "PW=" + drive.account().password() });
			mountScript.setUser( PathLocator.sharedInstance().userName() );
			mountScript.setPrerequisit( PostfixMarker.marker() );
		}
		
		return portForward;
	
	}
	
	public String bonjourType() {
		//
		// It is strange, but it looks like AFP and SMB drives both get anounced as _afpovertcp.
		// see:http://darwinsource.opendarwin.org/10.4/mDNSResponder-107/Clients/DNSServiceBrowser.m
		//
		return Bonjour._AFPOVERTCP_TYPE_;
	}
	
//	public String bonjourName( Model drive ) {
//		return "AVPN " + drive.path() + "@" + drive.parentModel().name();
//	}
//	
	public int localPort( Model drive ) throws ProfileException {
		String type = drive.type();
		int drivePort = drive.drivePort();

		if( type.equalsIgnoreCase( Model.AVPNAFPDriveType )) {
			return 0; // port 0 will make SSHPortForward allocate port
		} else if( type.equalsIgnoreCase( Model.AVPNSMBDriveType )) {
			return drivePort;
		} else if( type.equalsIgnoreCase( Model.AVPNDAVDriveType )) {
			return drivePort;
		} else {
			throw new ProfileException( "Unknown drive type : " + type );
		}
	}
	
	public int remotePort( Model drive ) throws ProfileException {
		String type = drive.type();
		int drivePort = drive.drivePort();
		if( drivePort >0 ) {
			return drivePort;
		}
		if( type.equalsIgnoreCase( Model.AVPNAFPDriveType )) {
			return _AFP_PORT_NUMBER_;
		} else if( type.equalsIgnoreCase( Model.AVPNSMBDriveType )) {
			return _SMB_PORT_NUMBER_;
		} else if( type.equalsIgnoreCase( Model.AVPNDAVDriveType )) {
			return _DAV_PORT_NUMBER_;
		} else {
			throw new ProfileException( "Unknown drive type : " + type );
		}
	}
	
	public Hashtable bonjourProperties() {
		return null;
	}
	
	
}
