package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import java.util.Hashtable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.model.Model;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.BaseConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.impl.AliasAddress;
import com.leapingbytes.almostvpn.server.profile.item.impl.BonjourAd;
import com.leapingbytes.almostvpn.server.profile.item.impl.CupsAd;
import com.leapingbytes.almostvpn.server.profile.item.impl.PostfixMarker;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHPortForward;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHSession;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.almostvpn.util.Bonjour;
import com.leapingbytes.jcocoa.NSDictionary;

public class PrinterConfigurator extends BaseConfigurator {
	private String msg = null;
	private static final Log log = LogFactory.getLog( PrinterConfigurator.class );

	protected PrinterConfigurator() {
		super( Model.AVPNPrinterRefClass );
	}

	public IProfileItem configure( NSDictionary definition) throws ProfileException {
		SSHPortForward	portForward = null;

		super.configure( definition );
		
		Model	printerRef = new Model( definition );
		Model 	printerRefParent = printerRef.parentModel();
		
		Model	printer = printerRef.referencedModel();
		Model	serviceHost = printer.parentModel();
		Model 	serviceLocation = serviceHost.isLocation() || serviceHost.isLocalhost() ?
			serviceHost :
			serviceHost.parentModel();
	
		int port = bonjourPort( printer );
		/*
		 * Build the chain of profile items
		 */
		SSHSession session = (SSHSession) profile().configure( serviceLocation.definition());			
		/*
		 * Need to allocate alias address to avoid conflict with 
		 * CUPS possibly running on this computer
		 */
		portForward = new SSHPortForward( session, SSHPortForward.LOCAL, port, serviceHost.address(), port );
		String portAddress;
		if( printerRefParent.isProfile()) {
			AliasAddress	aliasAddress = (AliasAddress) add( new AliasAddress());
			aliasAddress.setPrerequisit( session );		
			portForward.setBindToAddress( portAddress = aliasAddress.ip());		
			portForward.setPrerequisit( aliasAddress );
		} else { // Must be HostAlias
			portForward.setBindToAddress( portAddress = printerRefParent.aliasAddress());		
		}
		portForward = (SSHPortForward) add( portForward );
		
		if( printerRef.useCUPS()) {
			CupsAd cupsAd = (CupsAd) add( new CupsAd( cupsAdLine( printer, tunneledPrinterURI( printer, portForward ))));
			cupsAd.setPrerequisit( PostfixMarker.marker());
		}
		if( printerRef.useBonjour()) {
			BonjourAd bonjourAd = (BonjourAd) add( new BonjourAd( bonjourType( printer), bonjourName( printer ), portAddress, port,  bonjourProperties( printer )));
			bonjourAd.setPrerequisit( PostfixMarker.marker());
		}
		
		return portForward;
	}
	
	private String tunneledPrinterURI( Model printer, SSHPortForward tunnel ) throws ProfileException {
		String type = printer.type();
		String queue = fullQueueName( printer );
		
		String address = tunnel.bindToAddress();
		int port = tunnel.srcPort();
		
		if( Model.AVPNIPPPrinterType.equals( type )) {
			return "ipp://" + address + ":" + port + "/" + queue;
		} else if( Model.AVPNLPDPrinterType.equals( type )) {
			return "lpd://" + address + ":" + port + "/" + queue;
		} else if( Model.AVPNHPJetDirectPrinterType.equals( type )) {
			return "socket://" + address + ":" + port + "/" + queue ;
		} else {
			log.error( msg = "tunneledPrinterURI : unknown printer type = " + type );
			throw new ProfileException( msg );
		}
	}
	
	private String fullQueueName( Model printer ) throws ProfileException {
		String type = printer.type();
		String queue = printer.queue();
		
		if( Model.AVPNIPPPrinterType.equals( type )) {
			return "printers/" + queue;
		} else if( Model.AVPNLPDPrinterType.equals( type )) {
			return queue;
		} else if( Model.AVPNHPJetDirectPrinterType.equals( type )) {
			return queue + "?bidi";
		} else {
			log.error( msg = "tunneledPrinterURI : unknown printer type = " + type );
			throw new ProfileException( msg );
		}
	}
	/*
 		9006 3 ipp://buster.local:631/printers/psc_1310_series_ "buster" "psc 1310 series" "hp psc 1310 series"
		41006 3 ipp://schnitzel.local:631/printers/Internal_Modem "schnitzel" "Internal Modem" "Fax Printer"
	 */

	private String cupsAdLine(Model printer, String uri) {
		return 
			( printer.isFax() ? "41006" : "9006" ) + " " +
			"3" + " " +
			uri + " " +
			"\"" + printer.parentModel().name() + "\" " +
			"\"AVPN " + printer.printerModel() + "@" + printer.parentModel().name() + "\" " +
			"\"" + printer.printerModel() + "\"" + (char)10;
	}
	
	private String bonjourName( Model printer ) {
		return "AVPN " + printer.printerModel() + "@" + printer.parentModel().name();
	}
	
	private int bonjourPort( Model printer ) throws ProfileException {
		String type = printer.type();

		if( Model.AVPNIPPPrinterType.equals( type )) {
			return 631;
		} else if( Model.AVPNLPDPrinterType.equals( type )) {
			return 515;
		} else if( Model.AVPNHPJetDirectPrinterType.equals( type )) {
			return 9100;
		} else {
			log.error( msg = "configure : unknown printer type = " + type );
			throw new ProfileException( msg );			
		}		
	}
	private String bonjourType( Model printer ) {
		String type = printer.type();
		
		if( Model.AVPNIPPPrinterType.equals( type )) {
			return Bonjour._IPP_TYPE_;
		} else if( Model.AVPNLPDPrinterType.equals( type )) {
			return Bonjour._LPD_TYPE_;
		} else if( Model.AVPNHPJetDirectPrinterType.equals( type )) {
			return Bonjour._HP_JET_DIRECT_TYPE_;
		} else {
			return null;			
		}		
	}
	
	public Hashtable bonjourProperties( Model printer ) throws ProfileException {
		Hashtable result = new Hashtable();
			result.put( "txtvers", "1" );
			result.put( "qtotal", "1" );
			result.put( "rp", fullQueueName( printer ));
			result.put( "ty", bonjourName( printer ));
			result.put( "note", bonjourName( printer ));
			result.put( "product", printer.printerModel());
			result.put( "printer-state", "3" );
			result.put( "printer-type", bonjourType( printer ));
			result.put( "Transparent", "T" );
			result.put( "Binary", "T" );
			if( printer.isFax()) {
				result.put( "Fax", "T" );
				result.put( "pdl", "application/pdf,application/postscript,application/vnd.cups-raster,application/octet-stream,image/png" );
			} else {
				result.put( "pdl", "application/pdf,application/postscript,application/vnd.cups-raster,image/png" );
			}
			
		return result;
	}

}
