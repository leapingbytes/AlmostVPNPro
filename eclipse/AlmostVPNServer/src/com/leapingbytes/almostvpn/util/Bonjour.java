package com.leapingbytes.almostvpn.util;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Hashtable;

import javax.jmdns.JmDNS;
import javax.jmdns.ServiceInfo;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class Bonjour {
	private static final Log log = LogFactory.getLog( Bonjour.class );
	
	public static final String _AFPOVERTCP_TYPE_ 		= "_afpovertcp._tcp.local.";
	public static final String _IPP_TYPE_				= "_ipp._tcp.local.";
	public static final String _LPD_TYPE_				= "_printer._tcp.local.";
	public static final String _HP_JET_DIRECT_TYPE_		= "_pdl-datastream._tcp.local.";
	public static final String _VNC_TYPE_				= "_vnc._tcp.local.";
	public static final String _RFB_TYPE_				= "_rfb._tcp.local.";
	
	static Object			_jmdnsLock = new Object();
	static Hashtable			_jmDNSByIP = new Hashtable();
	

	public static void announce( BonjourItem item) {
		try {
			ServiceInfo info = serviceInfoForItem( item );
			JmDNS jmDNS = getJmDNS( InetAddress.getByName( item.bonjourAddress() ));
			jmDNS.registerService(info );
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static void withdraw( BonjourItem item) {
		ServiceInfo info = serviceInfoForItem( item );
		JmDNS jmDNS;
		try {
			jmDNS = getJmDNS( InetAddress.getByName( item.bonjourAddress()));
			jmDNS.unregisterService(info );
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	static ServiceInfo serviceInfoForItem( BonjourItem item ) {
		ServiceInfo result = new ServiceInfo( 
			item.bonjourType(), 
			item.bonjourName(),
			item.bonjourPort(),
			0,
			0,
			item.bonjourProperties()
		);
		
		log.info( "serviceInfoForItem : item " + item );
		log.info( "serviceInfoForItem : result " + result );
		return result;
	}
	
	static JmDNS getJmDNS( InetAddress addr ) {
		synchronized( _jmdnsLock ) {
			JmDNS result = (JmDNS) _jmDNSByIP.get( addr.getHostAddress());
			if( result == null ) {
				try {
					result = new JmDNS( addr );
				} catch (IOException e) {
					return null;
				}
				_jmDNSByIP.put( addr.getHostAddress(), result );
			}
			return result;
		}
	}
}

//class MyServiceInfo extends ServiceInfo {
//
//	InetAddress	_myAddr;
//	
//	public MyServiceInfo(String type, String name, String address, int port, Hashtable properties ) {
//		super(type, name, port, 0, 0, properties );
//		try {
//			_myAddr = InetAddress.getByName( address );
//		} catch (UnknownHostException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		} 
//	}
//	
//    /**
//     * Get the host address of the service (ie X.X.X.X).
//     */
//    public String getHostAddress()
//    {
//        return (_myAddr != null ? _myAddr.getHostAddress() : "");
//    }
//
//    public InetAddress getAddress()
//    {
//        return _myAddr;
//    }
//
//    /**
//     * Get the InetAddress of the service.
//     */
//    public InetAddress getInetAddress()
//    {
//        return _myAddr;
//    }
//	
//}