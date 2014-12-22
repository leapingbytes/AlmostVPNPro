package com.leapingbytes.almostvpn.model;

import com.leapingbytes.almostvpn.util.SecureStorageProvider;
import com.leapingbytes.jcocoa.NSDictionary;
import com.leapingbytes.jcocoa.NSMutableDictionary;

public class Model {
	public static final String	AVPNConfigurationClass		= "AlmostVPNConfiguration";
	public static final String	AVPNLocalhostClass			= "AlmostVPNLocalhost";
	public static final String	AVPNHostClass				= "AlmostVPNHost";
	public static final String 	AVPNLocationClass			= "AlmostVPNLocation";
	public static final String 	AVPNProfileClass			= "AlmostVPNProfile";
	public static final String	AVPNServiceClass			= "AlmostVPNService";
	public static final String	AVPNTunnelClass				= "AlmostVPNTunnel";
	public static final String 	AVPNAccountClass			= "AlmostVPNAccount";
	public static final String 	AVPNIdentityClass			= "AlmostVPNIdentity";
	public static final String	AVPNPrinterClass			= "AlmostVPNPrinter";
	public static final String	AVPNPrinterRefClass			= "AlmostVPNPrinterRef";
	public static final String	AVPNDriveClass				= "AlmostVPNDrive";
	public static final String	AVPNDriveRefClass			= "AlmostVPNDriveRef";
	public static final String	AVPNFileClass				= "AlmostVPNFile";
	public static final String	AVPNFileRefClass			= "AlmostVPNFileRef";
	public static final String	AVPNBonjourClass			= "AlmostVPNBonjour";
	public static final String	AVPNBonjourRefClass			= "AlmostVPNBonjourRef";

	public static final String	AVPNRemoteControlClass		= "AlmostVPNRemoteControl";
	public static final String	AVPNRemoteControlRefClass	= "AlmostVPNRemoteControlRef";

	public static final String	AVPNUUIDProperty			= "uuid";
	public static final String	AVPNNameProperty			= "name";
	public static final String	AVPNClassNameProperty		= "class-name";
	public static final String	AVPNParentUUIDProperty		= "parent-uuid";
	public static final String	AVPNRefObjUUIDProperty		= "reference-object-uuid";
	public static final String	AVPNSourceLocationProperty	= "source-location-uuid";

	public static final String	AVPNChildrenProperty		= "children";
	
	public static final String	AVPNAliasNameProperty		= "alias-name";
	public static final String	AVPNAliasAddressProperty	= "alias-address";
	public static final String  AVPNRecursiveHostAlias		= "recursive";
	
	public static final String	AVPNIdentityProperty		= "identity";
	public static final String	AVPNPassphraseProperty		= "passphrase";
	public static final String	AVPNUsePassphraseProperty	= "use-passphrase";
	public static final String	AVPNAskPassphraseProperty	= "ask-passphrase";
	public static final String	AVPNPathProperty			= "path";

	public static final String	AVPNAddressProperty			= "address";
	public static final String	AVPNSourcePortProperty		= "source-port";
	public static final String	AVPNPortProperty			= "port";
	public static final String	AVPNProxyProperty			= "proxy";
	public static final String	AVPNProxyTypeProperty		= "proxy-type";
	public static final String	AVPNProxyHostProperty		= "proxy-host";
	public static final String	AVPNProxyPortProperty		= "proxy-port";
	public static final String	AVPNKeepAliveProperty		= "keep-alive";
	public static final String  AVPNTimeoutProperty			= "timeout";
	
	public static final String	AVPNServiceProtocolsProperty = "protocols";
	
	public static final String	AVPNServiceTCPType 			= "tcp";
	public static final String	AVPNServiceUDPType 			= "udp";
	public static final String	AVPNServiceTCPAndUDPType 		= "tcp+udp";
	
	public static final String	AVPNAccountProperty			= "account";
	public static final String	AVPNUserNameProperty		= "user-name";
	public static final String	AVPNPasswordProperty		= "password";
	public static final String	AVPNUsePasswordProperty		= "use-password";
	public static final String	AVPNAskPasswordProperty		= "ask-password";
	
	public static final String	AVPNTypeProperty			= "type";
	public static final String	AVPNFaxProperty				= "fax";
	public static final String	AVPNPostscriptProperty		= "postscript";
	public static final String	AVPNColorProperty			= "color";
	public static final String	AVPNURIProperty				= "uri";
	public static final String	AVPNModelProperty			= "model";
	public static final String	AVPNQueueProperty			= "queue";

	public static final String	AVPNUseCUPSProperty			= "use-cups";
	public static final String	AVPNUseBonjourProperty		= "use-bonjour";
	public static final String	AVPNStartToControlProperty	= "start-to-control";
	public static final String	AVPNControlCommandProperty	= "control-command";

	public static final String	AVPNMountOnStartProperty	= "mount-on-start";
	public static final String	AVPNDrivePortProperty		= "port";
	
	

	public static final String	AVPNDstLocationProperty		= "dst-location";
	public static final String	AVPNDstPathProperty			= "dst-path";
	public static final String	AVPNDoAfterStartProperty	= "do-after-start"; // opposite do-before-stop
	public static final String	AVPNDoThisProperty			= "do-this"; 
	public static final String	AVPNAndExecuteProperty		= "and-exec";
	public static final String	AVPNX11Property				= "x11";
	public static final String	AVPNConsoleProperty			= "console";

	public static final String	AVPNPropertiesProperty		= "properties";
	public static final String 	AVPNCustomPropertiesProperty= "custom-properties";
	public static final String	AVPNLocalPortProperty		= "local-port";
	
	public static final String	AVPNFireAndForgetProperty	= "fire-and-forget";
	
	public static final String	AVPNUseHostAsIsProperty		= "use-host-name-as-is";
	public static final String	AVPNShareWithOthersProperty	= "share-with-others";

	public static final String 	AVPNRunDynamicProxyProperty	= "run-dynamic-proxy";	
	public static final String 	AVPNShareDynamicProxyProperty	= "share-dynamic-proxy";	
	public static final String 	AVPNDynamicProxyPortProperty	= "dynamic-proxy-port";	

	public static final String 	AVPNCopyMarker				= "copy";
	public static final String 	AVPNMoveMarker				= "move";
	public static final String 	AVPNNopMarker				= "nop";
	
	public static final String 	AVPNAutoAddressMarker		= "<auto>";
	public static final String	AVPNAskMarker				= "@ask@";

	public static final String 	AVPNIPPPrinterType			= "IPP";
	public static final String 	AVPNLPDPrinterType			= "LPD";
	public static final String 	AVPNHPJetDirectPrinterType	= "HP Jet Direct";
		
	public static final String 	AVPNAFPDriveType			= "AFP";
	public static final String 	AVPNSMBDriveType			= "SMB";
	public static final String 	AVPNNFSDriveType			= "NFS";
	public static final String 	AVPNDAVDriveType			= "HTTP";	
		
	public static final String 	AVPNVNCType					= "VNC";	
	public static final String 	AVPNARDType					= "ARD";	
	public static final String 	AVPNRDCType					= "RDC";	
	public static final String 	AVPNShellType				= "Shell";	

	public static final String 	AVPNBindToLocalhostProperty	= "bind-to-localhost";	

	public static final String 	AVPNNoProxyMarker			= "No Proxy";	
	public static final String 	AVPNSOCKSProxyMarker		= "SOCKS";	
	public static final String 	AVPNHTTPSProxyMarker			= "HTTPS";	
	public static final String 	AVPNHTTPProxyMarker			= "HTTP";	
	public static final String 	AVPNAutomaticProxyMarker	= "Automatic";	

	
	private NSDictionary 		_definiton; 
	private NSMutableDictionary _properties;
	
	/* 
	 * Basic accessor methods
	 */
	
	public static Object	objectProperty( NSDictionary definition, String propertyName ) {
		return definition == null ? null : definition.objectForKey( propertyName );
	}

	public static  NSDictionary objectReferencedBy( NSDictionary definition, String propertyName ) {
		String referencedObjectUUID = (String) definition.objectForKey( propertyName );
		NSDictionary result = referencedObjectUUID == null ? null : AVPNConfiguration.objectForUuid( referencedObjectUUID );
		return result;
	}
	
	public static NSDictionary[] allChildren( NSDictionary definition ) {
		return (NSDictionary[]) definition.objectsAtPath( AVPNChildrenProperty + "/*", NSDictionary.class );
	}

	/* 
	 * Convinience accessors
	 */
	
	public Object objectProperty( String propertyName ) {
		Object result = _properties == null ? null : _properties.objectForKey( propertyName );
		return result != null ? result : _definiton.objectForKey( propertyName );
	}
	
	public void setOjectProperty( String propertyName, Object value ) {
		if( _properties == null ) {
			_properties = new NSMutableDictionary();
		}
		_properties.setObjectForKey( value, propertyName );
	}
	
	public static Model localhost() {
		return new Model( AVPNConfiguration.localhost());
	}
	
	public String toString() {
		return name() + "(" + className() + ")" + "[" + uuid() + "]";
	}
	
	public Model( NSDictionary definition ) {
		_definiton = definition;
	}
	
	public NSDictionary definition() {
		return _definiton;
	}
	
	public String uuid() {
		return (String) objectProperty( _definiton, AVPNUUIDProperty );
	}
	
	public String className() {
		return (String) objectProperty( _definiton, AVPNClassNameProperty );
	}
	
	public String name() {
		return (String) objectProperty( _definiton, AVPNNameProperty );
	}
	
	public String aliasName() {
		return (String) objectProperty( _definiton, AVPNAliasNameProperty );
	}
	
	public String address() {
		String result = (String) objectProperty( _definiton, AVPNAddressProperty );
		result = result != null ? result : name();
		return result;
	}

	public String aliasAddress() {
		return (String) objectProperty( _definiton, AVPNAliasAddressProperty );
	}

	public boolean recursiveHostAlias() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNRecursiveHostAlias ));
	}

	public int port() {
		Object property = objectProperty( _definiton, AVPNPortProperty );
		if( property == null ) {
			return 0;
		}else if( property instanceof String ) {
			return Integer.parseInt( (String) property );
		} else {
			return ((Number)property).intValue();
		}
	}		
	
	public int sourcePort() {
		String port = (String) objectProperty( _definiton, AVPNSourcePortProperty );
		return port == null ? 0 : Integer.parseInt( port );
	}		
	
	public Model account() {
		return new Model( (NSDictionary) objectProperty( _definiton, AVPNAccountProperty ));
	}
	
	public String userName() {
		return (String) objectProperty( _definiton, AVPNUserNameProperty );
	}
	
	public String password() {
		return SecureStorageProvider.retriveSecureObject( AVPNPasswordProperty, _definiton );
	}

	public boolean usePassword() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNUsePasswordProperty ));
	}
	
	public boolean askPassword() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNAskPasswordProperty ));
	}
	
	public Model identityModel() {
		return modelReferencedBy( AVPNIdentityProperty );
	}
	
	public String path() {
		return (String) objectProperty( _definiton, AVPNPathProperty );
	}

	public String passphrase() {
		return SecureStorageProvider.retriveSecureObject( AVPNPassphraseProperty, _definiton );
	}

	public boolean usePassphrase() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNUsePassphraseProperty ));
	}
	
	public boolean askPassphrase() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNAskPassphraseProperty ));
	}
			
	public NSDictionary parentObject() {
		return (NSDictionary) objectReferencedBy( _definiton, AVPNParentUUIDProperty );
	}
	
	public Model parentModel() {
		return new Model( parentObject());
	}
	
	public NSDictionary referencedObject() {
		return objectReferencedBy( _definiton, AVPNRefObjUUIDProperty );
	}

	public Model referencedModel() {
		return new Model( referencedObject());
	}
	
	public NSDictionary objectReferencedBy( String propertyName ) {
		return objectReferencedBy( _definiton, propertyName );
	}
	
	public Model modelReferencedBy( String propertyName ) {
		NSDictionary o = objectReferencedBy( _definiton, propertyName );
		return o == null ? null : new Model( o );
	}

	public boolean isConfiguration() {
		return isOfClass( AVPNConfigurationClass );
	}
	
	public boolean isLocation() {
		return isOfClass( AVPNLocationClass );
	}
	
	public boolean isLocalhost() {
		return isOfClass( AVPNLocalhostClass );
	}
	
	public boolean isProfile() {
		return isOfClass( AVPNProfileClass );
	}
	
	public boolean isOfClass( String v ) {
		return v.equals( className());
	}
	
	public boolean isOverthere() {
		if( isLocalhost() ) {
			return false;
		}else if( isConfiguration()) {
			return true;
		}
		return parentModel().isOverthere();
	}

	public boolean isOverhere() {
		if( isLocalhost() ) {
			return true;
		}else if( isConfiguration()) {
			return false;
		}
		return parentModel().isOverhere();
	}
	
	
	public String type() {
		return (String) objectProperty( _definiton, AVPNTypeProperty );
	}
	
	public String uri() {
		return (String) objectProperty( _definiton, AVPNURIProperty );
	}
	
	public String queue() {
		return (String) objectProperty( _definiton, AVPNQueueProperty );
	}
	
	public String printerModel() {
		String result = (String) objectProperty( _definiton, AVPNModelProperty );
		if( result.charAt(0) == '(' ) {
			result = result.substring( 1, result.length()-1);
		}
		return result;
	}
	
	public boolean isFax() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNFaxProperty ));		
	}

	public boolean isPostscript() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNPostscriptProperty ));		
	}

	public boolean isColor() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNColorProperty ));		
	}

	public boolean useCUPS() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNUseCUPSProperty ));		
	}

	public boolean useBonjour() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNUseBonjourProperty ));		
	}
	
	public boolean bindToLocalhost() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNBindToLocalhostProperty ));		
	}

	public boolean startToControl() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNStartToControlProperty ));		
	}
	public String controlCommand() {
		return (String) objectProperty( _definiton, AVPNControlCommandProperty );
	}

	public boolean mountOnStart() {
		return "yes".equalsIgnoreCase( (String) objectProperty( _definiton, AVPNMountOnStartProperty ));		
	}


	public Model dstLocation() {
		return modelReferencedBy( AVPNDstLocationProperty );
	}
	
	public String dstPath() {
		return (String) objectProperty( _definiton, AVPNDstPathProperty );
	}
	
	public boolean doAfterStart() {
		return "yes".equals( objectProperty( _definiton, AVPNDoAfterStartProperty ));
	}
	
	public String doThis() {
		return (String) objectProperty( _definiton, AVPNDoThisProperty );
	}

	public boolean andExecute() {
		return "yes".equals( objectProperty( _definiton, AVPNAndExecuteProperty ));
	}
	public boolean x11() {
		return "yes".equals( objectProperty( _definiton, AVPNX11Property ));
	}
	public boolean console() {
		return "yes".equals( objectProperty( _definiton, AVPNConsoleProperty ));
	}

	public NSDictionary properties() {
		return (NSDictionary) objectProperty( _definiton, AVPNPropertiesProperty );
	}
	
	public int localPort() {
		Object property = objectProperty( _definiton, AVPNLocalPortProperty );
		if( property instanceof String ) {
			return Integer.parseInt( (String) property );
		} else {
			return ((Number)property).intValue();
		}
	}

	public String proxy() {
		return (String) objectProperty( _definiton, AVPNProxyProperty );
	}

	public String proxyHost() {
		return (String) objectProperty( AVPNProxyHostProperty );
	}			
	
	public void setProxyHost( String v ) {
		setOjectProperty( AVPNProxyHostProperty, v );
	}

	public int proxyPort() {
		String port = (String) objectProperty( AVPNProxyPortProperty );
		return port == null ? 0 : Integer.parseInt( port );
	}		
	public void setProxyPort( int v ) {
		setOjectProperty( AVPNProxyPortProperty, "" + v );
	}

	public String proxyType() {
		return (String) objectProperty( AVPNProxyTypeProperty );
	}
	public void setProxyType( String v ) {
		setOjectProperty( AVPNProxyTypeProperty, v );
	}

	public int keepAlive() {
		String keepAlive = (String) objectProperty( AVPNKeepAliveProperty );
		if( keepAlive == null ) {
			return 0;
		} else {
			return Integer.parseInt(keepAlive);
		}
	}
	public void setKeepAlive( int v ) {
		setOjectProperty( AVPNKeepAliveProperty, "" + v );
	}

	public boolean useHostAsIs() {
		return "yes".equals( objectProperty( _definiton, AVPNUseHostAsIsProperty ));
	}

	public boolean shareWithOthers() {
		return "yes".equals( objectProperty( _definiton, AVPNShareWithOthersProperty ));
	}

	public int drivePort() {
		Object port = objectProperty( AVPNDrivePortProperty );
		return port == null ? 0 : Integer.parseInt( port.toString() );
	}

	public int timeout() {
		Object timeout = objectProperty( AVPNTimeoutProperty );
		return timeout == null ? 0 : Integer.parseInt( timeout.toString());
	}

	public boolean runDynamicProxy() {
		return "yes".equals( objectProperty( _definiton, AVPNRunDynamicProxyProperty ));
	}

	public boolean shareDynamicProxy() {
		return "yes".equals( objectProperty( _definiton, AVPNShareDynamicProxyProperty ));
	}

	public int dynamicProxyPort() {
		Object port = objectProperty( AVPNDynamicProxyPortProperty );
		return port == null ? 0 : Integer.parseInt( port.toString() );
	}

	public boolean doTCP() {
		Object v = objectProperty( _definiton, AVPNServiceProtocolsProperty );
		return v == null || v.equals( AVPNServiceTCPType ) || v.equals( AVPNServiceTCPAndUDPType );
	}

	public boolean doUDP() {
		Object v = objectProperty( _definiton, AVPNServiceProtocolsProperty );
		return v != null && ( v.equals( AVPNServiceUDPType ) || v.equals( AVPNServiceTCPAndUDPType ));
	}
}
